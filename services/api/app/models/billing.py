from datetime import date, datetime
from uuid import uuid4

from sqlalchemy import Date, DateTime, ForeignKey, Integer, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class StripeCustomer(Base):
    __tablename__ = "stripe_customers"

    org_id: Mapped[str] = mapped_column(UUID(as_uuid=False), ForeignKey("orgs.id"), primary_key=True)
    customer_id: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    subscription_id: Mapped[str | None] = mapped_column(String(255), nullable=True)
    price_id: Mapped[str | None] = mapped_column(String(255), nullable=True)
    status: Mapped[str | None] = mapped_column(String(64), nullable=True)
    current_period_start: Mapped[date | None] = mapped_column(Date, nullable=True)
    current_period_end: Mapped[date | None] = mapped_column(Date, nullable=True)


class Plan(Base):
    __tablename__ = "plans"

    id: Mapped[str] = mapped_column(UUID(as_uuid=False), primary_key=True, default=lambda: str(uuid4()))
    code: Mapped[str] = mapped_column(String(32), unique=True, index=True)
    name: Mapped[str] = mapped_column(String(80))
    monthly_contact_cap_int: Mapped[int] = mapped_column(Integer)
    allows_phone_bool: Mapped[bool]
    recipes_limit_int: Mapped[int] = mapped_column(Integer)
    ai_mode: Mapped[str] = mapped_column(String(16))


class OrgPlan(Base):
    __tablename__ = "org_plan"

    org_id: Mapped[str] = mapped_column(UUID(as_uuid=False), ForeignKey("orgs.id"), primary_key=True)
    plan_code: Mapped[str] = mapped_column(String(32), ForeignKey("plans.code"), index=True)
    period_start: Mapped[date] = mapped_column(Date)
    period_end: Mapped[date] = mapped_column(Date)
    verified_contacts_used_int: Mapped[int] = mapped_column(Integer, default=0)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
