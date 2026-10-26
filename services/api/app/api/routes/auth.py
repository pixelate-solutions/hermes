from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import ActorContext, get_current_actor
from app.db.session import get_db
from app.schemas.common import MeResponse, PlanSnapshot
from app.services.quota_service import get_org_plan

router = APIRouter(tags=["auth"])


@router.get("/me", response_model=MeResponse)
def me(actor: ActorContext = Depends(get_current_actor), db: Session = Depends(get_db)) -> MeResponse:
    plan_usage = get_org_plan(db, actor.org_id)
    plan = PlanSnapshot(
        code=plan_usage.plan.code,
        name=plan_usage.plan.name,
        monthly_contact_cap=plan_usage.plan.monthly_contact_cap_int,
        verified_contacts_used=plan_usage.org_plan.verified_contacts_used_int,
        verified_contacts_remaining=plan_usage.remaining,
        allows_phone=plan_usage.plan.allows_phone_bool,
        recipes_limit=plan_usage.plan.recipes_limit_int,
        ai_mode=plan_usage.plan.ai_mode,
        period_start=plan_usage.org_plan.period_start,
        period_end=plan_usage.org_plan.period_end,
    )
    return MeResponse(user_id=actor.user_id, email=actor.email, org_id=actor.org_id, org_name=actor.org_name, plan=plan)
