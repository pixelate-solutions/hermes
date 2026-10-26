from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import Response
from sqlalchemy.orm import Session

from app.api.deps import ActorContext, get_current_actor
from app.db.session import get_db
from app.schemas.leads import JobListOut, LeadJobCreateIn, LeadJobOut, LeadListOut
from app.services.csv_service import leads_to_csv
from app.services.lead_service import create_job, get_job, get_job_leads, list_jobs, list_results
from app.services.quota_service import get_org_plan

router = APIRouter(prefix="/leads", tags=["leads"])


@router.post("/jobs", response_model=LeadJobOut)
def create_lead_job(
    payload: LeadJobCreateIn,
    actor: ActorContext = Depends(get_current_actor),
    db: Session = Depends(get_db),
) -> LeadJobOut:
    plan_usage = get_org_plan(db, actor.org_id)

    if payload.include_phone and not plan_usage.plan.allows_phone_bool:
        raise HTTPException(status_code=403, detail="Phone reveal is not available on your current plan")

    if payload.max_contacts > plan_usage.remaining:
        raise HTTPException(status_code=400, detail=f"Requested contacts exceed remaining monthly cap ({plan_usage.remaining})")

    if payload.include_ai:
        raise HTTPException(status_code=403, detail="AI research is temporarily disabled")

    job = create_job(db, org_id=actor.org_id, user_id=actor.user_id, payload=payload)
    return LeadJobOut.model_validate(job, from_attributes=True)


@router.get("/jobs", response_model=JobListOut)
def get_jobs(
    limit: int = Query(default=25, ge=1, le=100),
    cursor: str | None = None,
    status: str | None = None,
    actor: ActorContext = Depends(get_current_actor),
    db: Session = Depends(get_db),
) -> JobListOut:
    jobs, next_cursor = list_jobs(db, actor.org_id, limit=limit, cursor=cursor, status=status)
    return JobListOut(
        items=[LeadJobOut.model_validate(job, from_attributes=True) for job in jobs],
        next_cursor=next_cursor,
    )


@router.get("/jobs/{job_id}", response_model=LeadJobOut)
def get_job_detail(job_id: str, actor: ActorContext = Depends(get_current_actor), db: Session = Depends(get_db)) -> LeadJobOut:
    job = get_job(db, actor.org_id, job_id)
    if job is None:
        raise HTTPException(status_code=404, detail="Job not found")
    return LeadJobOut.model_validate(job, from_attributes=True)


@router.post("/jobs/{job_id}/cancel")
def cancel_job(job_id: str, actor: ActorContext = Depends(get_current_actor), db: Session = Depends(get_db)) -> dict:
    job = get_job(db, actor.org_id, job_id)
    if job is None:
        raise HTTPException(status_code=404, detail="Job not found")
    job.status = "cancel_requested"
    db.add(job)
    db.commit()
    return {"ok": True}


@router.get("/results", response_model=LeadListOut)
def get_results(
    limit: int = Query(default=100, ge=1, le=100),
    cursor: str | None = None,
    job_id: str | None = None,
    q: str | None = None,
    actor: ActorContext = Depends(get_current_actor),
    db: Session = Depends(get_db),
) -> LeadListOut:
    items, next_cursor = list_results(db, actor.org_id, limit=limit, cursor=cursor, job_id=job_id, q=q)
    return LeadListOut(items=[
        {
            "id": lead.id,
            "job_id": lead.job_id,
            "apollo_contact_id": lead.apollo_contact_id,
            "first_name": lead.first_name,
            "last_name": lead.last_name,
            "title": lead.title,
            "company": lead.company,
            "website": lead.website,
            "location": lead.location,
            "company_size": lead.company_size,
            "verified_email_bool": lead.verified_email_bool,
            "verified_phone_bool": lead.verified_phone_bool,
            "email": lead.email,
            "phone": lead.phone,
            "score_int": lead.score_int,
            "tags_json": lead.tags_json,
            "ai_json": lead.ai_json,
        }
        for lead in items
    ], next_cursor=next_cursor)


@router.get("/jobs/{job_id}/results", response_model=LeadListOut)
def get_job_results(job_id: str, actor: ActorContext = Depends(get_current_actor), db: Session = Depends(get_db)) -> LeadListOut:
    _ = get_job_detail(job_id, actor, db)
    leads = get_job_leads(db, actor.org_id, job_id)
    return LeadListOut(items=[
        {
            "id": lead.id,
            "job_id": lead.job_id,
            "apollo_contact_id": lead.apollo_contact_id,
            "first_name": lead.first_name,
            "last_name": lead.last_name,
            "title": lead.title,
            "company": lead.company,
            "website": lead.website,
            "location": lead.location,
            "company_size": lead.company_size,
            "verified_email_bool": lead.verified_email_bool,
            "verified_phone_bool": lead.verified_phone_bool,
            "email": lead.email,
            "phone": lead.phone,
            "score_int": lead.score_int,
            "tags_json": lead.tags_json,
            "ai_json": lead.ai_json,
        }
        for lead in leads
    ])


@router.get("/jobs/{job_id}/export.csv")
def export_job_csv(job_id: str, actor: ActorContext = Depends(get_current_actor), db: Session = Depends(get_db)) -> Response:
    job = get_job(db, actor.org_id, job_id)
    if job is None:
        raise HTTPException(status_code=404, detail="Job not found")
    csv_data = leads_to_csv(get_job_leads(db, actor.org_id, job_id))
    headers = {"Content-Disposition": f'attachment; filename="job-{job_id}.csv"'}
    return Response(content=csv_data, media_type="text/csv", headers=headers)
