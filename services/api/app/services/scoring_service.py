import hashlib


def score_lead(contact_id: str, title: str | None, company_size: str | None) -> int:
    raw = f"{contact_id}|{title or ''}|{company_size or ''}".encode("utf-8")
    digest = hashlib.sha256(raw).hexdigest()
    return 40 + int(digest[:2], 16) % 61
