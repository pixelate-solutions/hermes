from datetime import datetime

from pydantic import BaseModel, Field


class RecipeIn(BaseModel):
    name: str = Field(min_length=2, max_length=120)
    params_json: dict
    notes: str | None = None


class RecipePatch(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=120)
    params_json: dict | None = None
    notes: str | None = None


class RecipeOut(BaseModel):
    id: str
    name: str
    params_json: dict
    notes: str | None
    created_at: datetime
    updated_at: datetime


class RecipeListOut(BaseModel):
    items: list[RecipeOut]
