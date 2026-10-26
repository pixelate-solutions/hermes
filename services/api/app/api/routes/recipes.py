from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import and_, select
from sqlalchemy.orm import Session

from app.api.deps import ActorContext, get_current_actor
from app.db.session import get_db
from app.models.recipes import Recipe
from app.schemas.recipes import RecipeIn, RecipeListOut, RecipeOut, RecipePatch
from app.services.lead_service import create_job
from app.services.recipe_service import can_create_recipe, list_recipes

router = APIRouter(prefix="/recipes", tags=["recipes"])


@router.get("", response_model=RecipeListOut)
def get_recipes(actor: ActorContext = Depends(get_current_actor), db: Session = Depends(get_db)) -> RecipeListOut:
    return RecipeListOut(items=[RecipeOut.model_validate(recipe, from_attributes=True) for recipe in list_recipes(db, actor.org_id)])


@router.post("", response_model=RecipeOut)
def create_recipe(payload: RecipeIn, actor: ActorContext = Depends(get_current_actor), db: Session = Depends(get_db)) -> RecipeOut:
    if not can_create_recipe(db, actor.org_id):
        raise HTTPException(status_code=403, detail="Recipe limit reached for current plan")
    recipe = Recipe(org_id=actor.org_id, created_by_user_id=actor.user_id, **payload.model_dump())
    db.add(recipe)
    db.commit()
    db.refresh(recipe)
    return RecipeOut.model_validate(recipe, from_attributes=True)


@router.patch("/{recipe_id}", response_model=RecipeOut)
def update_recipe(recipe_id: str, payload: RecipePatch, actor: ActorContext = Depends(get_current_actor), db: Session = Depends(get_db)) -> RecipeOut:
    recipe = db.scalar(select(Recipe).where(and_(Recipe.id == recipe_id, Recipe.org_id == actor.org_id)))
    if recipe is None:
        raise HTTPException(status_code=404, detail="Recipe not found")
    updates = payload.model_dump(exclude_unset=True)
    for key, value in updates.items():
        setattr(recipe, key, value)
    db.add(recipe)
    db.commit()
    db.refresh(recipe)
    return RecipeOut.model_validate(recipe, from_attributes=True)


@router.patch("", response_model=RecipeOut)
def update_recipe_by_query(
    recipe_id: str,
    payload: RecipePatch,
    actor: ActorContext = Depends(get_current_actor),
    db: Session = Depends(get_db),
) -> RecipeOut:
    return update_recipe(recipe_id, payload, actor, db)


@router.post("/{recipe_id}/rerun")
def rerun_recipe(recipe_id: str, actor: ActorContext = Depends(get_current_actor), db: Session = Depends(get_db)) -> dict:
    recipe = db.scalar(select(Recipe).where(and_(Recipe.id == recipe_id, Recipe.org_id == actor.org_id)))
    if recipe is None:
        raise HTTPException(status_code=404, detail="Recipe not found")
    job = create_job(db, org_id=actor.org_id, user_id=actor.user_id, payload=recipe.params_json)
    return {"job_id": job.id}
