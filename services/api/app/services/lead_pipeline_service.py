from datetime import datetime

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.integrations.apollo_client import ApolloClient
from app.models.leads import Lead, LeadJob
from app.services.quota_service import can_reveal_more, get_org_plan, increment_verified_contacts_used
from app.services.scoring_service import score_lead


ENRICH_LEVEL_MAP = {
    "lite": "basic",
    "starter": "standard",
    "pro": "deep",
    "enterprise": "deep",
}


def run_lead_job(db: Session, job_id: str) -> None:
    job = db.scalar(select(LeadJob).where(LeadJob.id == job_id))
    if job is None:
        return

    job.status = "running"
    job.progress_json = {"stage": "initializing", "processed": 0, "verified": 0}
    job.updated_at = datetime.utcnow()
    db.add(job)
    db.commit()

    params = job.params_json or {}
    plan_usage = get_org_plan(db, job.org_id)
    requested_max = int(params.get("max_contacts", 25))
    target_verified = min(requested_max, plan_usage.remaining)

    if target_verified <= 0:
        job.status = "completed"
        job.error = "Monthly verified contact cap reached. Upgrade to continue."
        job.progress_json = {"stage": "quota_blocked", "processed": 0, "verified": 0}
        db.add(job)
        db.commit()
        return

    search_max = max(target_verified * 3, 25)
    apollo = ApolloClient(db=db, org_id=job.org_id, job_id=job.id)

    candidates = apollo.search_contacts({**params, "max_contacts": search_max})
    dedupe_ids = set()

    processed = 0
    verified_count = 0

    for idx, candidate in enumerate(candidates, start=1):
        db.refresh(job)
        if job.status == "cancel_requested":
            job.status = "cancelled"
            job.progress_json = {**(job.progress_json or {}), "stage": "cancelled", "processed": processed, "verified": verified_count}
            db.add(job)
            db.commit()
            return

        if verified_count >= target_verified or not can_reveal_more(db, job.org_id, 1):
            break

        apollo_contact_id = candidate.get("apollo_contact_id")
        if not apollo_contact_id or apollo_contact_id in dedupe_ids:
            continue
        dedupe_ids.add(apollo_contact_id)

        lead = db.scalar(
            select(Lead).where(Lead.org_id == job.org_id, Lead.apollo_contact_id == apollo_contact_id)
        )
        if lead is None:
            lead = Lead(
                org_id=job.org_id,
                job_id=job.id,
                apollo_contact_id=apollo_contact_id,
                verified_email_bool=False,
                verified_phone_bool=False,
            )

        was_verified = bool(lead.verified_email_bool or lead.verified_phone_bool)

        for field in ["first_name", "last_name", "title", "company", "website", "location", "company_size"]:
            if candidate.get(field):
                setattr(lead, field, candidate.get(field))

        if params.get("enrich", True):
            level = ENRICH_LEVEL_MAP.get(plan_usage.plan.code, "basic")
            enriched = apollo.enrich_contact(apollo_contact_id, level)
            for field in ["title", "company", "website", "location", "company_size"]:
                if enriched.get(field):
                    setattr(lead, field, enriched.get(field))

        if params.get("include_verified_email", True) and not lead.verified_email_bool:
            email = apollo.reveal_email(apollo_contact_id)
            if email:
                lead.email = email
                lead.verified_email_bool = True

        include_phone = bool(params.get("include_phone", False)) and bool(plan_usage.plan.allows_phone_bool)
        if include_phone and not lead.verified_phone_bool:
            phone = apollo.reveal_phone(apollo_contact_id)
            if phone:
                lead.phone = phone
                lead.verified_phone_bool = True

        is_verified = bool(lead.verified_email_bool or lead.verified_phone_bool)

        if is_verified and not was_verified:
            incremented = increment_verified_contacts_used(
                db,
                org_id=job.org_id,
                apollo_contact_id=apollo_contact_id,
                period_start=plan_usage.org_plan.period_start,
                n=1,
            )
            if incremented:
                verified_count += 1

        lead.score_int = score_lead(apollo_contact_id, lead.title, lead.company_size)
        lead.tags_json = [params.get("industry"), params.get("geo")]

        db.add(lead)
        processed += 1

        if idx % 10 == 0:
            job.progress_json = {
                "stage": "processing",
                "processed": processed,
                "verified": verified_count,
                "target_verified": target_verified,
            }
            job.updated_at = datetime.utcnow()
            db.add(job)
            db.commit()

    job.status = "completed"
    job.progress_json = {
        "stage": "completed",
        "processed": processed,
        "verified": verified_count,
        "target_verified": target_verified,
    }
    job.updated_at = datetime.utcnow()
    db.add(job)
    db.commit()
