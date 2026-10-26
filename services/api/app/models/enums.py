from enum import StrEnum


class MembershipRole(StrEnum):
    admin = "admin"
    member = "member"


class PlanCode(StrEnum):
    lite = "lite"
    starter = "starter"
    pro = "pro"
    enterprise = "enterprise"


class AiMode(StrEnum):
    off = "off"
    job = "job"
    contact = "contact"


class JobStatus(StrEnum):
    queued = "queued"
    running = "running"
    completed = "completed"
    failed = "failed"
    cancel_requested = "cancel_requested"
    cancelled = "cancelled"


class ActionType(StrEnum):
    search = "SEARCH"
    enrich_basic = "ENRICH_BASIC"
    enrich_standard = "ENRICH_STANDARD"
    enrich_deep = "ENRICH_DEEP"
    reveal_email = "REVEAL_EMAIL"
    reveal_phone = "REVEAL_PHONE"
    ai_research_job = "AI_RESEARCH_JOB"
    ai_research_contact = "AI_RESEARCH_CONTACT"
    count_verified_contact = "COUNT_VERIFIED_CONTACT"
