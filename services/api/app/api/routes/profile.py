from datetime import datetime

from fastapi import APIRouter, Depends
from sqlalchemy import and_, select
from sqlalchemy.orm import Session

from app.api.deps import ActorContext, get_current_actor
from app.db.session import get_db
from app.models.profile import Profile, TermsAcceptance
from app.schemas.profile import AcceptTermsIn, AcceptTermsOut, ProfileIn, ProfileOut

router = APIRouter(prefix="/profile", tags=["profile"])


@router.get("", response_model=ProfileOut)
def get_profile(actor: ActorContext = Depends(get_current_actor), db: Session = Depends(get_db)) -> ProfileOut:
    profile = db.scalar(select(Profile).where(and_(Profile.user_id == actor.user_id, Profile.org_id == actor.org_id)))
    if profile is None:
        profile = Profile(user_id=actor.user_id, org_id=actor.org_id)
        db.add(profile)
        db.commit()
        db.refresh(profile)
    return ProfileOut.model_validate(profile, from_attributes=True)


@router.put("", response_model=ProfileOut)
def update_profile(payload: ProfileIn, actor: ActorContext = Depends(get_current_actor), db: Session = Depends(get_db)) -> ProfileOut:
    profile = db.scalar(select(Profile).where(and_(Profile.user_id == actor.user_id, Profile.org_id == actor.org_id)))
    if profile is None:
        profile = Profile(user_id=actor.user_id, org_id=actor.org_id)

    for key, value in payload.model_dump().items():
        setattr(profile, key, value)
    profile.updated_at = datetime.utcnow()
    db.add(profile)
    db.commit()
    db.refresh(profile)
    return ProfileOut.model_validate(profile, from_attributes=True)


@router.post("/accept-terms", response_model=AcceptTermsOut)
def accept_terms(payload: AcceptTermsIn, actor: ActorContext = Depends(get_current_actor), db: Session = Depends(get_db)) -> AcceptTermsOut:
    acceptance = db.scalar(
        select(TermsAcceptance).where(
            and_(TermsAcceptance.user_id == actor.user_id, TermsAcceptance.org_id == actor.org_id)
        )
    )
    if acceptance is None:
        acceptance = TermsAcceptance(user_id=actor.user_id, org_id=actor.org_id)
    acceptance.accepted_at = datetime.utcnow()
    acceptance.ip_hash = payload.ip_hash
    db.add(acceptance)
    db.commit()
    return AcceptTermsOut(accepted=True, accepted_at=acceptance.accepted_at)
