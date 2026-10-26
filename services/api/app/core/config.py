from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_env: str = "development"
    database_url: str
    redis_url: str

    clerk_jwks_url: str = ""

    stripe_secret_key: str = ""
    stripe_webhook_secret: str = ""
    stripe_price_id_lite: str = ""
    stripe_price_id_starter: str = ""
    stripe_price_id_pro: str = ""

    apollo_api_key: str = ""
    apollo_base_url: str = "https://api.apollo.io/api/v1"
    openai_api_key: str = ""

    hermes_flutter_web_url: str = "http://localhost:8080"
    hermes_ios_return_url: str = "hermes://billing"
    hermes_android_return_url: str = "hermes://billing"


@lru_cache
def get_settings() -> Settings:
    return Settings()
