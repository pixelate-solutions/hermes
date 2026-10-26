from app.core.logging import get_logger
from app.db.session import SessionLocal
from app.services.lead_pipeline_service import run_lead_job as run_lead_job_pipeline

logger = get_logger("worker.tasks")


def run_lead_job(job_id: str) -> None:
    db = SessionLocal()
    try:
        logger.info("job.start", job_id=job_id)
        run_lead_job_pipeline(db, job_id)
        logger.info("job.complete", job_id=job_id)
    except Exception as exc:  # noqa: BLE001
        logger.error("job.failed", job_id=job_id, error=str(exc))
        db.rollback()
        raise
    finally:
        db.close()
