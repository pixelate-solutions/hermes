from typing import Any

from app.core.config import get_settings
from app.services.vendor_usage_service import increment_vendor_usage


class AIClient:
    def __init__(self):
        self.settings = get_settings()

    def run_job_research(self, *, db, org_id: str, context: dict[str, Any]) -> dict[str, Any]:
        # MVP deterministic output; can be swapped for real model call when OPENAI_API_KEY is configured.
        increment_vendor_usage(db, org_id, 1)
        return {
            "summary": f"High-fit segment: {context.get('industry', 'General')} in {context.get('geo', 'global')}.",
            "angles": ["pain-first outreach", "proof-oriented opener"],
        }

    def run_contact_research(self, *, db, org_id: str, contact: dict[str, Any]) -> dict[str, Any]:
        increment_vendor_usage(db, org_id, 1)
        return {
            "hook": f"Reference {contact.get('company') or 'their company'} growth motion.",
            "intent_signal": f"Role match for {contact.get('title') or 'decision maker'}",
        }
