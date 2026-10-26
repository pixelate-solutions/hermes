from datetime import date

from sqlalchemy import and_, select
from sqlalchemy.orm import Session

from app.models.leads import VendorCall, VendorUsage


CREDIT_COSTS = {
    "REVEAL_EMAIL": 1,
    "REVEAL_PHONE": 8,
    "ENRICH_BASIC": 1,
    "ENRICH_STANDARD": 3,
    "ENRICH_DEEP": 8,
    "AI_RESEARCH_JOB": 1,
    "AI_RESEARCH_CONTACT": 1,
    "DIALER": 2,
}


def record_vendor_call(
    db: Session,
    *,
    org_id: str,
    job_id: str | None,
    vendor: str,
    endpoint: str,
    request_hash: str,
    status_code: int | None,
    credits_estimated_int: int,
    meta_json: dict | None = None,
) -> None:
    db.add(
        VendorCall(
            org_id=org_id,
            job_id=job_id,
            vendor=vendor,
            endpoint=endpoint,
            request_hash=request_hash,
            status_code=status_code,
            credits_estimated_int=credits_estimated_int,
            meta_json=meta_json,
        )
    )


def increment_vendor_usage(db: Session, org_id: str, credits: int) -> None:
    month = date.today().replace(day=1)
    usage = db.scalar(select(VendorUsage).where(and_(VendorUsage.org_id == org_id, VendorUsage.month == month)))
    if usage is None:
        usage = VendorUsage(org_id=org_id, month=month, apollo_credits_used_int=0)
        db.add(usage)
    usage.apollo_credits_used_int += credits
