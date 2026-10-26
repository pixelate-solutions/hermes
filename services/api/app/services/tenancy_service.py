from datetime import date, timedelta

from sqlalchemy import and_, select
from sqlalchemy.orm import Session

from app.models.auth import Membership, Org, User
from app.models.billing import OrgPlan, Plan
from app.models.enums import MembershipRole, PlanCode


def _default_period() -> tuple[date, date]:
    start = date.today().replace(day=1)
    end = start + timedelta(days=31)
    end = end.replace(day=1) - timedelta(days=1)
    return start, end


def get_or_create_user_org(
    db: Session,
    *,
    clerk_user_id: str,
    email: str,
    clerk_org_id: str | None,
    org_name_hint: str | None = None,
) -> tuple[User, Org]:
    user = db.scalar(select(User).where(User.clerk_user_id == clerk_user_id))
    if user is None:
        user = User(clerk_user_id=clerk_user_id, email=email)
        db.add(user)
        db.flush()

    org = None
    if clerk_org_id:
        org = db.scalar(select(Org).where(Org.clerk_org_id == clerk_org_id))

    if org is None:
        if clerk_org_id:
            org = Org(clerk_org_id=clerk_org_id, name=org_name_hint or f"{email.split('@')[0]} Org")
        else:
            org = db.scalar(
                select(Org)
                .join(Membership, Membership.org_id == Org.id)
                .where(and_(Membership.user_id == user.id, Org.clerk_org_id.is_(None)))
            )
            if org is None:
                org = Org(clerk_org_id=None, name=org_name_hint or f"{email.split('@')[0]} Personal")
        db.add(org)
        db.flush()

    membership = db.scalar(
        select(Membership).where(and_(Membership.user_id == user.id, Membership.org_id == org.id))
    )
    if membership is None:
        membership = Membership(user_id=user.id, org_id=org.id, role=MembershipRole.admin.value)
        db.add(membership)

    org_plan = db.scalar(select(OrgPlan).where(OrgPlan.org_id == org.id))
    if org_plan is None:
        start, end = _default_period()
        org_plan = OrgPlan(org_id=org.id, plan_code=PlanCode.lite.value, period_start=start, period_end=end, verified_contacts_used_int=0)
        db.add(org_plan)

    has_plans = db.scalar(select(Plan.id).limit(1))
    if not has_plans:
        db.add_all(
            [
                Plan(code=PlanCode.lite.value, name="Lite", monthly_contact_cap_int=100, allows_phone_bool=False, recipes_limit_int=1, ai_mode="off"),
                Plan(code=PlanCode.starter.value, name="Starter", monthly_contact_cap_int=300, allows_phone_bool=False, recipes_limit_int=3, ai_mode="job"),
                Plan(code=PlanCode.pro.value, name="Pro", monthly_contact_cap_int=2000, allows_phone_bool=True, recipes_limit_int=999999, ai_mode="contact"),
                Plan(code=PlanCode.enterprise.value, name="Enterprise", monthly_contact_cap_int=1000000, allows_phone_bool=True, recipes_limit_int=999999, ai_mode="contact"),
            ]
        )

    db.commit()
    db.refresh(user)
    db.refresh(org)
    return user, org
