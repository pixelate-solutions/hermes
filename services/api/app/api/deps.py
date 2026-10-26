from dataclasses import dataclass

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.db.session import get_db
from app.integrations.clerk_auth import verify_clerk_token
from app.services.tenancy_service import get_or_create_user_org

security = HTTPBearer(auto_error=False)


@dataclass
class ActorContext:
    user_id: str
    email: str
    org_id: str
    org_name: str



def get_current_actor(
    creds: HTTPAuthorizationCredentials | None = Depends(security),
    db: Session = Depends(get_db),
) -> ActorContext:
    settings = get_settings()

    if creds is None:
        if settings.app_env == "development":
            user, org = get_or_create_user_org(
                db,
                clerk_user_id="dev-user",
                email="dev@hermes.local",
                clerk_org_id=None,
                org_name_hint="Dev Org",
            )
            return ActorContext(user_id=user.id, email=user.email, org_id=org.id, org_name=org.name)
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing authorization")

    token = creds.credentials
    if settings.app_env == "development" and token == "dev-token":
        user, org = get_or_create_user_org(
            db,
            clerk_user_id="dev-user",
            email="dev@hermes.local",
            clerk_org_id=None,
            org_name_hint="Dev Org",
        )
        return ActorContext(user_id=user.id, email=user.email, org_id=org.id, org_name=org.name)

    try:
        claims = verify_clerk_token(token)
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=f"Invalid Clerk token: {exc}") from exc

    clerk_user_id = claims.get("sub")
    email = claims.get("email") or claims.get("email_address")
    if not clerk_user_id or not email:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token missing required subject/email claims")

    org_id_claim = claims.get("org_id")
    org_name_hint = claims.get("org_name")

    user, org = get_or_create_user_org(
        db,
        clerk_user_id=clerk_user_id,
        email=email,
        clerk_org_id=org_id_claim,
        org_name_hint=org_name_hint,
    )
    return ActorContext(user_id=user.id, email=user.email, org_id=org.id, org_name=org.name)
