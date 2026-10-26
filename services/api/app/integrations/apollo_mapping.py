from typing import Any


def map_contact_from_apollo(raw: dict[str, Any]) -> dict[str, Any]:
    """
    TODO: Confirm canonical field names against Apollo docs and adjust mappings.
    This mapping intentionally isolates vendor-specific field assumptions.
    """
    return {
        "apollo_contact_id": raw.get("id") or raw.get("contact_id") or "",
        "first_name": raw.get("first_name"),
        "last_name": raw.get("last_name"),
        "title": raw.get("title"),
        "company": (raw.get("organization") or {}).get("name") if isinstance(raw.get("organization"), dict) else raw.get("company"),
        "website": (raw.get("organization") or {}).get("website_url") if isinstance(raw.get("organization"), dict) else raw.get("website"),
        "location": raw.get("city") or raw.get("location"),
        "company_size": raw.get("organization_num_employees") or raw.get("company_size"),
        "email": raw.get("email"),
        "phone": raw.get("phone_number") or raw.get("phone"),
    }
