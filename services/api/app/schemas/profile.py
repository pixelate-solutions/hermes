from datetime import datetime

from pydantic import BaseModel


class ProfileIn(BaseModel):
    company: str | None = None
    role: str | None = None
    geo_json: dict | None = None
    industries_json: list | None = None
    outreach_tone: str | None = None
    what_we_sell: str | None = None


class ProfileOut(ProfileIn):
    user_id: str
    org_id: str
    created_at: datetime
    updated_at: datetime


class AcceptTermsIn(BaseModel):
    ip_hash: str | None = None


class AcceptTermsOut(BaseModel):
    accepted: bool
    accepted_at: datetime
