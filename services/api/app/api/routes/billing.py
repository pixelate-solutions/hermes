from fastapi import APIRouter, Body, Depends, Header, HTTPException, Request
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import ActorContext, get_current_actor
from app.db.session import get_db
from app.integrations.stripe_client import verify_webhook
from app.models.billing import StripeCustomer
from app.schemas.billing import BillingSummary, CheckoutSessionIn, CheckoutSessionOut, PortalSessionIn, PortalSessionOut
from app.schemas.common import PlanSnapshot
from app.services.billing_service import apply_subscription_event, create_checkout_session, create_portal_session
from app.services.quota_service import get_org_plan

router = APIRouter(prefix="/billing", tags=["billing"])


@router.get("/summary", response_model=BillingSummary)
def billing_summary(actor: ActorContext = Depends(get_current_actor), db: Session = Depends(get_db)) -> BillingSummary:
    plan_usage = get_org_plan(db, actor.org_id)
    stripe_customer = db.scalar(select(StripeCustomer).where(StripeCustomer.org_id == actor.org_id))
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
    return BillingSummary(plan=plan, renewal_date=plan_usage.org_plan.period_end, stripe_status=stripe_customer.status if stripe_customer else None)


@router.post("/create-checkout-session", response_model=CheckoutSessionOut)
def create_checkout(
    payload: CheckoutSessionIn,
    actor: ActorContext = Depends(get_current_actor),
    db: Session = Depends(get_db),
) -> CheckoutSessionOut:
    if payload.plan_code == "enterprise":
        raise HTTPException(status_code=400, detail="Enterprise is sales-assisted")
    stripe_customer = db.scalar(select(StripeCustomer).where(StripeCustomer.org_id == actor.org_id))
    checkout_url = create_checkout_session(
        db,
        org_id=actor.org_id,
        plan_code=payload.plan_code,
        customer_id=stripe_customer.customer_id if stripe_customer else None,
        platform=payload.platform,
    )
    return CheckoutSessionOut(checkout_url=checkout_url)


@router.post("/portal-session", response_model=PortalSessionOut)
def create_portal(
    payload: PortalSessionIn | None = Body(default=None),
    actor: ActorContext = Depends(get_current_actor),
    db: Session = Depends(get_db),
) -> PortalSessionOut:
    stripe_customer = db.scalar(select(StripeCustomer).where(StripeCustomer.org_id == actor.org_id))
    if stripe_customer is None:
        raise HTTPException(status_code=404, detail="No billing customer found")
    platform = payload.platform if payload else "web"
    return PortalSessionOut(portal_url=create_portal_session(stripe_customer.customer_id, platform=platform))


@router.post("/webhook")
async def stripe_webhook(
    request: Request,
    stripe_signature: str = Header(alias="Stripe-Signature"),
    db: Session = Depends(get_db),
) -> dict:
    payload = await request.body()
    event = verify_webhook(payload, stripe_signature)
    event_type = event.get("type", "")
    if event_type in {"customer.subscription.created", "customer.subscription.updated", "customer.subscription.deleted"}:
        apply_subscription_event(db, event)
    return {"received": True}
