from datetime import datetime

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.public import EnterpriseLead
from app.schemas.common import HealthResponse
from app.schemas.public import EnterpriseLeadIn, EnterpriseLeadOut

router = APIRouter(tags=["public"])


@router.get("/health", response_model=HealthResponse)
def healthcheck() -> HealthResponse:
    return HealthResponse(ok=True, timestamp=datetime.utcnow())


@router.post("/public/enterprise-lead", response_model=EnterpriseLeadOut)
def create_enterprise_lead(payload: EnterpriseLeadIn, db: Session = Depends(get_db)) -> EnterpriseLeadOut:
    lead = EnterpriseLead(**payload.model_dump())
    db.add(lead)
    db.commit()
    db.refresh(lead)
    return EnterpriseLeadOut(id=lead.id, message="Thanks, our team will reach out soon.")
