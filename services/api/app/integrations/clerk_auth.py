from functools import lru_cache
from typing import Any

import httpx
from jose import jwt

from app.core.config import get_settings


@lru_cache(maxsize=1)
def _jwks() -> dict[str, Any]:
    settings = get_settings()
    if not settings.clerk_jwks_url:
        return {"keys": []}
    with httpx.Client(timeout=10.0) as client:
        response = client.get(settings.clerk_jwks_url)
        response.raise_for_status()
    return response.json()


def verify_clerk_token(token: str) -> dict[str, Any]:
    settings = get_settings()
    if not settings.clerk_jwks_url:
        raise ValueError("CLERK_JWKS_URL is not configured")

    header = jwt.get_unverified_header(token)
    kid = header.get("kid")
    keys = _jwks().get("keys", [])
    key = next((k for k in keys if k.get("kid") == kid), None)
    if not key:
        raise ValueError("Unable to find matching JWK")

    return jwt.decode(token, key, algorithms=[header.get("alg", "RS256")], options={"verify_aud": False})
