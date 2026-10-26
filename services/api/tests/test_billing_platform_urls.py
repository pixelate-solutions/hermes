import sys
import types


def test_platform_return_urls(monkeypatch):
    sys.modules.setdefault("stripe", types.SimpleNamespace(api_key=""))
    from app.core.config import get_settings
    from app.services import billing_service

    monkeypatch.setenv("DATABASE_URL", "postgresql+psycopg://postgres:postgres@localhost:5432/hermes")
    monkeypatch.setenv("REDIS_URL", "redis://localhost:6379/0")
    monkeypatch.setenv("HERMES_FLUTTER_WEB_URL", "https://hermesleads.com")
    monkeypatch.setenv("HERMES_IOS_RETURN_URL", "hermes://ios")
    monkeypatch.setenv("HERMES_ANDROID_RETURN_URL", "hermes://android")
    get_settings.cache_clear()

    assert billing_service._return_url("web", "/app/billing") == "https://hermesleads.com/app/billing"
    assert billing_service._return_url("ios", "/app/billing") == "hermes://ios/app/billing"
    assert billing_service._return_url("android", "/app/billing") == "hermes://android/app/billing"
