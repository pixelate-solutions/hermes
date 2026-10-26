import hashlib
import random
from typing import Any

import httpx
from tenacity import retry, retry_if_exception_type, stop_after_attempt, wait_exponential
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.integrations.apollo_mapping import map_contact_from_apollo
from app.services.vendor_usage_service import CREDIT_COSTS, increment_vendor_usage, record_vendor_call


class ApolloClient:
    def __init__(self, db: Session, org_id: str, job_id: str | None):
        self.settings = get_settings()
        self.db = db
        self.org_id = org_id
        self.job_id = job_id

    def _hash(self, payload: dict[str, Any]) -> str:
        return hashlib.sha256(str(sorted(payload.items())).encode("utf-8")).hexdigest()

    @retry(
        stop=stop_after_attempt(4),
        wait=wait_exponential(multiplier=0.5, min=0.5, max=8),
        retry=retry_if_exception_type(httpx.HTTPError),
        reraise=True,
    )
    def _request(self, method: str, endpoint: str, payload: dict[str, Any], action: str) -> dict[str, Any]:
        credits = CREDIT_COSTS.get(action, 0)
        req_hash = self._hash(payload)

        if not self.settings.apollo_api_key:
            record_vendor_call(
                self.db,
                org_id=self.org_id,
                job_id=self.job_id,
                vendor="apollo",
                endpoint=endpoint,
                request_hash=req_hash,
                status_code=200,
                credits_estimated_int=credits,
                meta_json={"mock": True, "action": action},
            )
            increment_vendor_usage(self.db, self.org_id, credits)
            return {"mock": True}

        headers = {"X-Api-Key": self.settings.apollo_api_key, "Content-Type": "application/json"}
        url = f"{self.settings.apollo_base_url.rstrip('/')}/{endpoint.lstrip('/')}"

        with httpx.Client(timeout=20.0) as client:
            response = client.request(method, url, json=payload, headers=headers)

        if response.status_code == 429 or response.status_code >= 500:
            response.raise_for_status()

        record_vendor_call(
            self.db,
            org_id=self.org_id,
            job_id=self.job_id,
            vendor="apollo",
            endpoint=endpoint,
            request_hash=req_hash,
            status_code=response.status_code,
            credits_estimated_int=credits,
            meta_json={"action": action},
        )
        increment_vendor_usage(self.db, self.org_id, credits)

        if response.status_code >= 400:
            raise httpx.HTTPStatusError("Apollo request failed", request=response.request, response=response)

        return response.json()

    def search_contacts(self, params: dict[str, Any]) -> list[dict[str, Any]]:
        if not self.settings.apollo_api_key:
            max_contacts = int(params.get("max_contacts", 25))
            return [
                {
                    "apollo_contact_id": f"mock-{idx}",
                    "first_name": f"Lead{idx}",
                    "last_name": "Prospect",
                    "title": random.choice(params.get("roles", ["Founder"])),
                    "company": f"Company {idx}",
                    "website": f"https://company{idx}.example.com",
                    "location": params.get("geo", "US"),
                    "company_size": params.get("company_size", "11-50"),
                    "email": None,
                    "phone": None,
                }
                for idx in range(max_contacts)
            ]

        payload = {
            "q_organization_industry_tag_ids": [params.get("industry")],
            "person_titles": params.get("roles", []),
            "person_locations": [params.get("geo")],
            "page": 1,
            "per_page": max(25, int(params.get("max_contacts", 25))),
        }
        data = self._request("POST", "mixed_people/search", payload, "SEARCH")
        people = data.get("people", [])
        return [map_contact_from_apollo(row) for row in people]

    def enrich_contact(self, contact_id: str, level: str) -> dict[str, Any]:
        action_map = {"basic": "ENRICH_BASIC", "standard": "ENRICH_STANDARD", "deep": "ENRICH_DEEP"}
        if not self.settings.apollo_api_key:
            return {"company_size": {"basic": "11-50", "standard": "51-200", "deep": "201-500"}.get(level, "11-50")}
        payload = {"id": contact_id}
        data = self._request("POST", "people/match", payload, action_map[level])
        return map_contact_from_apollo(data.get("person", {}))

    def reveal_email(self, contact_id: str) -> str | None:
        if not self.settings.apollo_api_key:
            return f"{contact_id.replace('mock-', 'lead')}@example.com"
        payload = {"id": contact_id}
        data = self._request("POST", "people/reveal_email", payload, "REVEAL_EMAIL")
        person = data.get("person", {})
        return person.get("email")

    def reveal_phone(self, contact_id: str) -> str | None:
        if not self.settings.apollo_api_key:
            base = contact_id.replace("mock-", "")
            return f"+1555{int(base):06d}" if base.isdigit() else None
        payload = {"id": contact_id}
        data = self._request("POST", "people/reveal_phone", payload, "REVEAL_PHONE")
        person = data.get("person", {})
        return person.get("phone_number")
