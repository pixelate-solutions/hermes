from datetime import datetime
from typing import Any

from sqlalchemy import desc, or_, select
from sqlalchemy.orm import Session

from app.models.leads import Lead, LeadJob
from app.worker.queue import get_queue


def _to_params(payload: Any) -> dict:
    if isinstance(payload, dict):
        return payload
    if hasattr(payload, "model_dump"):
        return payload.model_dump()
    raise ValueError("Unsupported payload for lead job")


def create_job(db: Session, *, org_id: str, user_id: str, payload: Any) -> LeadJob:
    job = LeadJob(
        org_id=org_id,
        created_by_user_id=user_id,
        params_json=_to_params(payload),
        status="queued",
        progress_json={"stage": "queued", "processed": 0, "verified": 0},
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )
    db.add(job)
    db.commit()
    db.refresh(job)

    queue = get_queue()
    queue.enqueue("hermes_worker.tasks.run_lead_job", job.id)
    return job


def _offset(cursor: str | None) -> int:
    if cursor is None:
        return 0
    try:
        return max(0, int(cursor))
    except ValueError:
        return 0


def _limit(limit: int) -> int:
    return min(max(limit, 1), 100)


def list_jobs(db: Session, org_id: str, *, limit: int = 25, cursor: str | None = None, status: str | None = None) -> tuple[list[LeadJob], str | None]:
    offset = _offset(cursor)
    page_size = _limit(limit)
    stmt = select(LeadJob).where(LeadJob.org_id == org_id)
    if status:
        stmt = stmt.where(LeadJob.status == status)
    rows = list(
        db.scalars(
            stmt.order_by(desc(LeadJob.created_at))
            .offset(offset)
            .limit(page_size + 1)
        ).all()
    )
    next_cursor = str(offset + page_size) if len(rows) > page_size else None
    return rows[:page_size], next_cursor


def get_job(db: Session, org_id: str, job_id: str) -> LeadJob | None:
    return db.scalar(select(LeadJob).where(LeadJob.org_id == org_id, LeadJob.id == job_id))


def get_job_leads(db: Session, org_id: str, job_id: str) -> list[Lead]:
    return list(db.scalars(select(Lead).where(Lead.org_id == org_id, Lead.job_id == job_id).order_by(desc(Lead.created_at))).all())


def list_results(
    db: Session,
    org_id: str,
    *,
    limit: int = 100,
    cursor: str | None = None,
    job_id: str | None = None,
    q: str | None = None,
) -> tuple[list[Lead], str | None]:
    offset = _offset(cursor)
    page_size = _limit(limit)
    stmt = select(Lead).where(Lead.org_id == org_id)
    if job_id:
        stmt = stmt.where(Lead.job_id == job_id)
    if q:
        like = f"%{q}%"
        stmt = stmt.where(
            or_(
                Lead.first_name.ilike(like),
                Lead.last_name.ilike(like),
                Lead.title.ilike(like),
                Lead.company.ilike(like),
                Lead.email.ilike(like),
                Lead.phone.ilike(like),
            )
        )
    rows = list(
        db.scalars(
            stmt.order_by(desc(Lead.created_at))
            .offset(offset)
            .limit(page_size + 1)
        ).all()
    )
    next_cursor = str(offset + page_size) if len(rows) > page_size else None
    return rows[:page_size], next_cursor
