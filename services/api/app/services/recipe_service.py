from sqlalchemy import desc, func, select
from sqlalchemy.orm import Session

from app.models.recipes import Recipe
from app.services.quota_service import get_org_plan


def list_recipes(db: Session, org_id: str) -> list[Recipe]:
    return list(db.scalars(select(Recipe).where(Recipe.org_id == org_id).order_by(desc(Recipe.updated_at))).all())


def can_create_recipe(db: Session, org_id: str) -> bool:
    plan_usage = get_org_plan(db, org_id)
    if plan_usage.plan.recipes_limit_int >= 999999:
        return True
    count = db.scalar(select(func.count(Recipe.id)).where(Recipe.org_id == org_id)) or 0
    return count < plan_usage.plan.recipes_limit_int
