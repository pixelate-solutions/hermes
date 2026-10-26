from typing import Any

import stripe

from app.core.config import get_settings


def get_stripe_client() -> stripe:
    settings = get_settings()
    stripe.api_key = settings.stripe_secret_key
    return stripe


def verify_webhook(payload: bytes, sig_header: str) -> Any:
    settings = get_settings()
    return stripe.Webhook.construct_event(payload, sig_header, settings.stripe_webhook_secret)
