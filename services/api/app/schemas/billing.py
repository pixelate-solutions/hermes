from datetime import date
from typing import Literal

from pydantic import BaseModel

from app.schemas.common import PlanSnapshot


class BillingSummary(BaseModel):
    plan: PlanSnapshot
    renewal_date: date
    stripe_status: str | None


class CheckoutSessionIn(BaseModel):
    plan_code: Literal["lite", "starter", "pro"]
    platform: Literal["web", "ios", "android"] = "web"


class CheckoutSessionOut(BaseModel):
    checkout_url: str


class PortalSessionIn(BaseModel):
    platform: Literal["web", "ios", "android"] = "web"


class PortalSessionOut(BaseModel):
    portal_url: str
