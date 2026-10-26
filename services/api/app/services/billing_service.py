from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.integrations.stripe_client import get_stripe_client
from app.models.billing import OrgPlan, StripeCustomer


PRICE_ID_TO_PLAN = {}


def _price_to_plan_map() -> dict[str, str]:
    settings = get_settings()
    return {
        settings.stripe_price_id_lite: "lite",
        settings.stripe_price_id_starter: "starter",
        settings.stripe_price_id_pro: "pro",
    }


def _return_url(platform: str, path: str) -> str:
    settings = get_settings()
    if platform == "ios":
        return f"{settings.hermes_ios_return_url}{path}"
    if platform == "android":
        return f"{settings.hermes_android_return_url}{path}"
    return f"{settings.hermes_flutter_web_url}{path}"


def create_checkout_session(db: Session, org_id: str, plan_code: str, customer_id: str | None, platform: str = "web") -> str:
    stripe = get_stripe_client()
    settings = get_settings()
    price_map = {
        "lite": settings.stripe_price_id_lite,
        "starter": settings.stripe_price_id_starter,
        "pro": settings.stripe_price_id_pro,
    }
    price_id = price_map.get(plan_code)
    if not price_id:
        raise ValueError("Stripe price is not configured for requested plan")

    kwargs = {
        "mode": "subscription",
        "line_items": [{"price": price_id, "quantity": 1}],
        "success_url": _return_url(platform, "/app/billing?checkout=success"),
        "cancel_url": _return_url(platform, "/app/billing?checkout=cancel"),
        "metadata": {"org_id": org_id, "plan_code": plan_code, "platform": platform},
    }
    if customer_id:
        kwargs["customer"] = customer_id

    session = stripe.checkout.Session.create(**kwargs)
    return str(session.url)


def create_portal_session(customer_id: str, platform: str = "web") -> str:
    stripe = get_stripe_client()
    session = stripe.billing_portal.Session.create(customer=customer_id, return_url=_return_url(platform, "/app/billing"))
    return str(session.url)


def apply_subscription_event(db: Session, event: dict) -> None:
    obj = event.get("data", {}).get("object", {})
    customer_id = obj.get("customer")
    if not customer_id:
        return

    stripe_customer = db.scalar(select(StripeCustomer).where(StripeCustomer.customer_id == customer_id))
    if stripe_customer is None:
        metadata = obj.get("metadata", {}) or {}
        org_id = metadata.get("org_id")
        if not org_id:
            return
        stripe_customer = StripeCustomer(org_id=org_id, customer_id=customer_id)
        db.add(stripe_customer)

    stripe_customer.subscription_id = obj.get("id")
    stripe_customer.price_id = (((obj.get("items") or {}).get("data") or [{}])[0].get("price") or {}).get("id")
    stripe_customer.status = obj.get("status")

    start_ts = obj.get("current_period_start")
    end_ts = obj.get("current_period_end")
    if start_ts:
        stripe_customer.current_period_start = datetime.fromtimestamp(start_ts, tz=timezone.utc).date()
    if end_ts:
        stripe_customer.current_period_end = datetime.fromtimestamp(end_ts, tz=timezone.utc).date()

    plan_map = _price_to_plan_map()
    plan_code = plan_map.get(stripe_customer.price_id or "")
    if plan_code:
        org_plan = db.scalar(select(OrgPlan).where(OrgPlan.org_id == stripe_customer.org_id))
        if org_plan:
            should_reset = org_plan.period_start != stripe_customer.current_period_start
            org_plan.plan_code = plan_code
            if stripe_customer.current_period_start:
                org_plan.period_start = stripe_customer.current_period_start
            if stripe_customer.current_period_end:
                org_plan.period_end = stripe_customer.current_period_end
            if should_reset:
                org_plan.verified_contacts_used_int = 0
            db.add(org_plan)

    db.add(stripe_customer)
    db.commit()
