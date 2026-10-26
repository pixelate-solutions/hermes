"""initial schema

Revision ID: 0001_initial
Revises:
Create Date: 2026-02-18 00:00:00
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision = "0001_initial"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", postgresql.UUID(as_uuid=False), primary_key=True),
        sa.Column("clerk_user_id", sa.String(255), nullable=False),
        sa.Column("email", sa.String(320), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_users_clerk_user_id", "users", ["clerk_user_id"], unique=True)
    op.create_index("ix_users_email", "users", ["email"])

    op.create_table(
        "orgs",
        sa.Column("id", postgresql.UUID(as_uuid=False), primary_key=True),
        sa.Column("clerk_org_id", sa.String(255), nullable=True),
        sa.Column("name", sa.String(255), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_orgs_clerk_org_id", "orgs", ["clerk_org_id"], unique=True)

    op.create_table(
        "memberships",
        sa.Column("user_id", postgresql.UUID(as_uuid=False), sa.ForeignKey("users.id"), primary_key=True),
        sa.Column("org_id", postgresql.UUID(as_uuid=False), sa.ForeignKey("orgs.id"), primary_key=True),
        sa.Column("role", sa.String(20), nullable=False),
    )

    op.create_table(
        "plans",
        sa.Column("id", postgresql.UUID(as_uuid=False), primary_key=True),
        sa.Column("code", sa.String(32), nullable=False),
        sa.Column("name", sa.String(80), nullable=False),
        sa.Column("monthly_contact_cap_int", sa.Integer(), nullable=False),
        sa.Column("allows_phone_bool", sa.Boolean(), nullable=False),
        sa.Column("recipes_limit_int", sa.Integer(), nullable=False),
        sa.Column("ai_mode", sa.String(16), nullable=False),
    )
    op.create_index("ix_plans_code", "plans", ["code"], unique=True)

    op.create_table(
        "org_plan",
        sa.Column("org_id", postgresql.UUID(as_uuid=False), sa.ForeignKey("orgs.id"), primary_key=True),
        sa.Column("plan_code", sa.String(32), sa.ForeignKey("plans.code"), nullable=False),
        sa.Column("period_start", sa.Date(), nullable=False),
        sa.Column("period_end", sa.Date(), nullable=False),
        sa.Column("verified_contacts_used_int", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_org_plan_plan_code", "org_plan", ["plan_code"])

    op.create_table(
        "stripe_customers",
        sa.Column("org_id", postgresql.UUID(as_uuid=False), sa.ForeignKey("orgs.id"), primary_key=True),
        sa.Column("customer_id", sa.String(255), nullable=False),
        sa.Column("subscription_id", sa.String(255), nullable=True),
        sa.Column("price_id", sa.String(255), nullable=True),
        sa.Column("status", sa.String(64), nullable=True),
        sa.Column("current_period_start", sa.Date(), nullable=True),
        sa.Column("current_period_end", sa.Date(), nullable=True),
    )
    op.create_index("ix_stripe_customers_customer_id", "stripe_customers", ["customer_id"], unique=True)

    op.create_table(
        "profiles",
        sa.Column("user_id", postgresql.UUID(as_uuid=False), sa.ForeignKey("users.id"), primary_key=True),
        sa.Column("org_id", postgresql.UUID(as_uuid=False), sa.ForeignKey("orgs.id"), primary_key=True),
        sa.Column("company", sa.String(255), nullable=True),
        sa.Column("role", sa.String(255), nullable=True),
        sa.Column("geo_json", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column("industries_json", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column("outreach_tone", sa.Text(), nullable=True),
        sa.Column("what_we_sell", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )

    op.create_table(
        "terms_acceptance",
        sa.Column("user_id", postgresql.UUID(as_uuid=False), sa.ForeignKey("users.id"), primary_key=True),
        sa.Column("org_id", postgresql.UUID(as_uuid=False), sa.ForeignKey("orgs.id"), primary_key=True),
        sa.Column("accepted_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("ip_hash", sa.String(128), nullable=True),
    )

    op.create_table(
        "lead_jobs",
        sa.Column("id", postgresql.UUID(as_uuid=False), primary_key=True),
        sa.Column("org_id", postgresql.UUID(as_uuid=False), sa.ForeignKey("orgs.id"), nullable=False),
        sa.Column("created_by_user_id", postgresql.UUID(as_uuid=False), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("params_json", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("status", sa.String(32), nullable=False),
        sa.Column("progress_json", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column("error", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_lead_jobs_org_id", "lead_jobs", ["org_id"])
    op.create_index("ix_lead_jobs_created_by_user_id", "lead_jobs", ["created_by_user_id"])
    op.create_index("ix_lead_jobs_status", "lead_jobs", ["status"])

    op.create_table(
        "leads",
        sa.Column("id", postgresql.UUID(as_uuid=False), primary_key=True),
        sa.Column("org_id", postgresql.UUID(as_uuid=False), sa.ForeignKey("orgs.id"), nullable=False),
        sa.Column("job_id", postgresql.UUID(as_uuid=False), sa.ForeignKey("lead_jobs.id"), nullable=False),
        sa.Column("apollo_contact_id", sa.String(255), nullable=False),
        sa.Column("first_name", sa.String(255), nullable=True),
        sa.Column("last_name", sa.String(255), nullable=True),
        sa.Column("title", sa.String(255), nullable=True),
        sa.Column("company", sa.String(255), nullable=True),
        sa.Column("website", sa.String(255), nullable=True),
        sa.Column("location", sa.String(255), nullable=True),
        sa.Column("company_size", sa.String(80), nullable=True),
        sa.Column("verified_email_bool", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("verified_phone_bool", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("email", sa.String(320), nullable=True),
        sa.Column("phone", sa.String(80), nullable=True),
        sa.Column("score_int", sa.Integer(), nullable=True),
        sa.Column("tags_json", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column("ai_json", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.UniqueConstraint("org_id", "apollo_contact_id", name="uq_leads_org_apollo_contact"),
    )
    op.create_index("ix_leads_org_id", "leads", ["org_id"])
    op.create_index("ix_leads_job_id", "leads", ["job_id"])

    op.create_table(
        "lead_actions",
        sa.Column("id", postgresql.UUID(as_uuid=False), primary_key=True),
        sa.Column("org_id", postgresql.UUID(as_uuid=False), sa.ForeignKey("orgs.id"), nullable=False),
        sa.Column("apollo_contact_id", sa.String(255), nullable=False),
        sa.Column("action_type", sa.String(64), nullable=False),
        sa.Column("unique_key", sa.String(255), nullable=False),
        sa.Column("succeeded_bool", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.UniqueConstraint("org_id", "unique_key", name="uq_lead_actions_org_unique_key"),
    )
    op.create_index("ix_lead_actions_org_id", "lead_actions", ["org_id"])
    op.create_index("ix_lead_actions_action_type", "lead_actions", ["action_type"])
    op.create_index("ix_lead_actions_apollo_contact_id", "lead_actions", ["apollo_contact_id"])

    op.create_table(
        "vendor_calls",
        sa.Column("id", postgresql.UUID(as_uuid=False), primary_key=True),
        sa.Column("org_id", postgresql.UUID(as_uuid=False), sa.ForeignKey("orgs.id"), nullable=False),
        sa.Column("job_id", postgresql.UUID(as_uuid=False), sa.ForeignKey("lead_jobs.id"), nullable=True),
        sa.Column("vendor", sa.String(64), nullable=False),
        sa.Column("endpoint", sa.String(255), nullable=False),
        sa.Column("request_hash", sa.String(128), nullable=False),
        sa.Column("status_code", sa.Integer(), nullable=True),
        sa.Column("credits_estimated_int", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("meta_json", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
    )
    op.create_index("ix_vendor_calls_org_id", "vendor_calls", ["org_id"])
    op.create_index("ix_vendor_calls_job_id", "vendor_calls", ["job_id"])
    op.create_index("ix_vendor_calls_vendor", "vendor_calls", ["vendor"])
    op.create_index("ix_vendor_calls_request_hash", "vendor_calls", ["request_hash"])

    op.create_table(
        "vendor_usage",
        sa.Column("org_id", postgresql.UUID(as_uuid=False), sa.ForeignKey("orgs.id"), primary_key=True),
        sa.Column("month", sa.Date(), primary_key=True),
        sa.Column("apollo_credits_used_int", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )

    op.create_table(
        "recipes",
        sa.Column("id", postgresql.UUID(as_uuid=False), primary_key=True),
        sa.Column("org_id", postgresql.UUID(as_uuid=False), sa.ForeignKey("orgs.id"), nullable=False),
        sa.Column("created_by_user_id", postgresql.UUID(as_uuid=False), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("name", sa.String(120), nullable=False),
        sa.Column("params_json", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_recipes_org_id", "recipes", ["org_id"])
    op.create_index("ix_recipes_created_by_user_id", "recipes", ["created_by_user_id"])

    op.create_table(
        "enterprise_leads",
        sa.Column("id", postgresql.UUID(as_uuid=False), primary_key=True),
        sa.Column("name", sa.String(255), nullable=False),
        sa.Column("email", sa.String(320), nullable=False),
        sa.Column("company", sa.String(255), nullable=False),
        sa.Column("use_case", sa.Text(), nullable=False),
        sa.Column("desired_volume", sa.String(120), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
    )

    op.execute(
        """
        INSERT INTO plans (id, code, name, monthly_contact_cap_int, allows_phone_bool, recipes_limit_int, ai_mode)
        VALUES
          ('00000000-0000-0000-0000-000000000001', 'lite', 'Lite', 100, false, 1, 'off'),
          ('00000000-0000-0000-0000-000000000002', 'starter', 'Starter', 300, false, 3, 'job'),
          ('00000000-0000-0000-0000-000000000003', 'pro', 'Pro', 2000, true, 999999, 'contact'),
          ('00000000-0000-0000-0000-000000000004', 'enterprise', 'Enterprise', 1000000, true, 999999, 'contact')
        ON CONFLICT (code) DO NOTHING;
        """
    )


def downgrade() -> None:
    op.drop_table("enterprise_leads")
    op.drop_index("ix_recipes_created_by_user_id", table_name="recipes")
    op.drop_index("ix_recipes_org_id", table_name="recipes")
    op.drop_table("recipes")
    op.drop_table("vendor_usage")
    op.drop_index("ix_vendor_calls_request_hash", table_name="vendor_calls")
    op.drop_index("ix_vendor_calls_vendor", table_name="vendor_calls")
    op.drop_index("ix_vendor_calls_job_id", table_name="vendor_calls")
    op.drop_index("ix_vendor_calls_org_id", table_name="vendor_calls")
    op.drop_table("vendor_calls")
    op.drop_index("ix_lead_actions_apollo_contact_id", table_name="lead_actions")
    op.drop_index("ix_lead_actions_action_type", table_name="lead_actions")
    op.drop_index("ix_lead_actions_org_id", table_name="lead_actions")
    op.drop_table("lead_actions")
    op.drop_index("ix_leads_job_id", table_name="leads")
    op.drop_index("ix_leads_org_id", table_name="leads")
    op.drop_table("leads")
    op.drop_index("ix_lead_jobs_status", table_name="lead_jobs")
    op.drop_index("ix_lead_jobs_created_by_user_id", table_name="lead_jobs")
    op.drop_index("ix_lead_jobs_org_id", table_name="lead_jobs")
    op.drop_table("lead_jobs")
    op.drop_table("terms_acceptance")
    op.drop_table("profiles")
    op.drop_index("ix_stripe_customers_customer_id", table_name="stripe_customers")
    op.drop_table("stripe_customers")
    op.drop_index("ix_org_plan_plan_code", table_name="org_plan")
    op.drop_table("org_plan")
    op.drop_index("ix_plans_code", table_name="plans")
    op.drop_table("plans")
    op.drop_table("memberships")
    op.drop_index("ix_orgs_clerk_org_id", table_name="orgs")
    op.drop_table("orgs")
    op.drop_index("ix_users_email", table_name="users")
    op.drop_index("ix_users_clerk_user_id", table_name="users")
    op.drop_table("users")
