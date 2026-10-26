from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class LeadJobCreateIn(BaseModel):
    industry: str
    geo: str
    roles: list[str]
    company_size: str | None = None
    max_contacts: int = Field(ge=1, le=5000)
    include_verified_email: bool = True
    include_phone: bool = False
    include_ai: bool = False
    recipe_name: str | None = None


class LeadJobOut(BaseModel):
    id: str
    status: str
    params_json: dict
    progress_json: dict | None
    error: str | None
    created_at: datetime
    updated_at: datetime


class LeadOut(BaseModel):
    id: str
    job_id: str
    apollo_contact_id: str
    first_name: str | None
    last_name: str | None
    title: str | None
    company: str | None
    website: str | None
    location: str | None
    company_size: str | None
    verified_email_bool: bool
    verified_phone_bool: bool
    email: str | None
    phone: str | None
    score_int: int | None
    tags_json: list | None
    ai_json: dict | None


class JobProgressPatch(BaseModel):
    status: Literal["cancel_requested"]


class JobListOut(BaseModel):
    items: list[LeadJobOut]
    next_cursor: str | None = None


class LeadListOut(BaseModel):
    items: list[LeadOut]
    next_cursor: str | None = None
