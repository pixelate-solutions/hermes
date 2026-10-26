from datetime import date, datetime
from uuid import uuid4

from sqlalchemy import Date, DateTime, ForeignKey, Index, Integer, String, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class LeadJob(Base):
    __tablename__ = "lead_jobs"

    id: Mapped[str] = mapped_column(UUID(as_uuid=False), primary_key=True, default=lambda: str(uuid4()))
    org_id: Mapped[str] = mapped_column(UUID(as_uuid=False), ForeignKey("orgs.id"), index=True)
    created_by_user_id: Mapped[str] = mapped_column(UUID(as_uuid=False), ForeignKey("users.id"), index=True)
    params_json: Mapped[dict] = mapped_column(JSONB)
    status: Mapped[str] = mapped_column(String(32), default="queued", index=True)
    progress_json: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    error: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)


class Lead(Base):
    __tablename__ = "leads"
    __table_args__ = (UniqueConstraint("org_id", "apollo_contact_id", name="uq_leads_org_apollo_contact"),)

    id: Mapped[str] = mapped_column(UUID(as_uuid=False), primary_key=True, default=lambda: str(uuid4()))
    org_id: Mapped[str] = mapped_column(UUID(as_uuid=False), ForeignKey("orgs.id"), index=True)
    job_id: Mapped[str] = mapped_column(UUID(as_uuid=False), ForeignKey("lead_jobs.id"), index=True)
    apollo_contact_id: Mapped[str] = mapped_column(String(255))
    first_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    last_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    title: Mapped[str | None] = mapped_column(String(255), nullable=True)
    company: Mapped[str | None] = mapped_column(String(255), nullable=True)
    website: Mapped[str | None] = mapped_column(String(255), nullable=True)
    location: Mapped[str | None] = mapped_column(String(255), nullable=True)
    company_size: Mapped[str | None] = mapped_column(String(80), nullable=True)
    verified_email_bool: Mapped[bool] = mapped_column(default=False)
    verified_phone_bool: Mapped[bool] = mapped_column(default=False)
    email: Mapped[str | None] = mapped_column(String(320), nullable=True)
    phone: Mapped[str | None] = mapped_column(String(80), nullable=True)
    score_int: Mapped[int | None] = mapped_column(Integer, nullable=True)
    tags_json: Mapped[list | None] = mapped_column(JSONB, nullable=True)
    ai_json: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow)


class LeadAction(Base):
    __tablename__ = "lead_actions"
    __table_args__ = (UniqueConstraint("org_id", "unique_key", name="uq_lead_actions_org_unique_key"),)

    id: Mapped[str] = mapped_column(UUID(as_uuid=False), primary_key=True, default=lambda: str(uuid4()))
    org_id: Mapped[str] = mapped_column(UUID(as_uuid=False), ForeignKey("orgs.id"), index=True)
    apollo_contact_id: Mapped[str] = mapped_column(String(255), index=True)
    action_type: Mapped[str] = mapped_column(String(64), index=True)
    unique_key: Mapped[str] = mapped_column(String(255))
    succeeded_bool: Mapped[bool] = mapped_column(default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow)


class VendorCall(Base):
    __tablename__ = "vendor_calls"

    id: Mapped[str] = mapped_column(UUID(as_uuid=False), primary_key=True, default=lambda: str(uuid4()))
    org_id: Mapped[str] = mapped_column(UUID(as_uuid=False), ForeignKey("orgs.id"), index=True)
    job_id: Mapped[str | None] = mapped_column(UUID(as_uuid=False), ForeignKey("lead_jobs.id"), nullable=True, index=True)
    vendor: Mapped[str] = mapped_column(String(64), index=True)
    endpoint: Mapped[str] = mapped_column(String(255))
    request_hash: Mapped[str] = mapped_column(String(128), index=True)
    status_code: Mapped[int | None] = mapped_column(Integer, nullable=True)
    credits_estimated_int: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow)
    meta_json: Mapped[dict | None] = mapped_column(JSONB, nullable=True)


class VendorUsage(Base):
    __tablename__ = "vendor_usage"
    __table_args__ = (Index("ix_vendor_usage_org_month", "org_id", "month", unique=True),)

    org_id: Mapped[str] = mapped_column(UUID(as_uuid=False), ForeignKey("orgs.id"), primary_key=True)
    month: Mapped[date] = mapped_column(Date, primary_key=True)
    apollo_credits_used_int: Mapped[int] = mapped_column(Integer, default=0)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
