from datetime import date, datetime
from typing import Literal

from pydantic import BaseModel


class PlanSnapshot(BaseModel):
    code: Literal["lite", "starter", "pro", "enterprise"]
    name: str
    monthly_contact_cap: int
    verified_contacts_used: int
    verified_contacts_remaining: int
    allows_phone: bool
    recipes_limit: int
    ai_mode: Literal["off", "job", "contact"]
    period_start: date
    period_end: date


class MeResponse(BaseModel):
    user_id: str
    email: str
    org_id: str
    org_name: str
    plan: PlanSnapshot


class ErrorResponse(BaseModel):
    detail: str


class HealthResponse(BaseModel):
    ok: bool
    timestamp: datetime
