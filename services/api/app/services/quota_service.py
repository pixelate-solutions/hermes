from dataclasses import dataclass
from datetime import date, timedelta

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models.billing import OrgPlan, Plan
from app.models.enums import ActionType
from app.models.leads import LeadAction


@dataclass
class OrgPlanUsage:
    org_plan: OrgPlan
    plan: Plan

    @property
    def remaining(self) -> int:
        return max(0, self.plan.monthly_contact_cap_int - self.org_plan.verified_contacts_used_int)


def _roll_if_needed(db: Session, org_plan: OrgPlan) -> OrgPlan:
    today = date.today()
    if org_plan.period_end < today:
        start = today.replace(day=1)
        end = (start + timedelta(days=31)).replace(day=1) - timedelta(days=1)
        org_plan.period_start = start
        org_plan.period_end = end
        org_plan.verified_contacts_used_int = 0
        db.add(org_plan)
        db.flush()
    return org_plan


def get_org_plan(db: Session, org_id: str) -> OrgPlanUsage:
    org_plan = db.scalar(select(OrgPlan).where(OrgPlan.org_id == org_id))
    if org_plan is None:
        raise ValueError("Org plan not configured")
    org_plan = _roll_if_needed(db, org_plan)
    plan = db.scalar(select(Plan).where(Plan.code == org_plan.plan_code))
    if plan is None:
        raise ValueError("Plan record missing")
    return OrgPlanUsage(org_plan=org_plan, plan=plan)


def can_reveal_more(db: Session, org_id: str, n: int = 1) -> bool:
    plan_usage = get_org_plan(db, org_id)
    return plan_usage.remaining >= n


def increment_verified_contacts_used(
    db: Session,
    *,
    org_id: str,
    apollo_contact_id: str,
    period_start: date,
    n: int = 1,
) -> bool:
    plan_usage = get_org_plan(db, org_id)
    unique_key = f"{org_id}:{apollo_contact_id}:{ActionType.count_verified_contact.value}:{period_start.isoformat()}"
    action = LeadAction(
        org_id=org_id,
        apollo_contact_id=apollo_contact_id,
        action_type=ActionType.count_verified_contact.value,
        unique_key=unique_key,
        succeeded_bool=True,
    )

    try:
        with db.begin_nested():
            db.add(action)
            db.flush()
    except IntegrityError:
        return False

    plan_usage.org_plan.verified_contacts_used_int += n
    db.add(plan_usage.org_plan)
    db.flush()
    return True
