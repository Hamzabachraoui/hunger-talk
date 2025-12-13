"""
Schemas Pydantic pour la liste de courses
"""
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from uuid import UUID
from decimal import Decimal


class ShoppingListItemBase(BaseModel):
    """Schéma de base pour un élément de liste de courses"""
    item_name: str
    quantity: Decimal = Field(1.0, ge=0)
    unit: str = "unité"
    category_id: Optional[int] = None
    notes: Optional[str] = None


class ShoppingListItemCreate(ShoppingListItemBase):
    """Schéma pour créer un élément de liste de courses"""
    pass


class ShoppingListItemUpdate(BaseModel):
    """Schéma pour mettre à jour un élément de liste de courses"""
    item_name: Optional[str] = None
    quantity: Optional[Decimal] = None
    unit: Optional[str] = None
    category_id: Optional[int] = None
    is_purchased: Optional[bool] = None
    notes: Optional[str] = None


class ShoppingListItemResponse(BaseModel):
    """Schéma de réponse pour un élément de liste de courses"""
    id: UUID
    user_id: UUID
    item_name: str
    quantity: float
    unit: str
    category_id: Optional[int] = None
    is_purchased: bool
    added_at: datetime
    purchased_at: Optional[datetime] = None
    notes: Optional[str] = None
    
    class Config:
        from_attributes = True


class ShoppingListSummary(BaseModel):
    """Résumé de la liste de courses"""
    total_items: int
    purchased_items: int
    remaining_items: int
    items: list[ShoppingListItemResponse]


class GenerateFromRecipeRequest(BaseModel):
    """Requête pour générer une liste depuis une recette"""
    recipe_id: UUID
    servings: Optional[int] = None  # Nombre de portions (par défaut: servings de la recette)


class GenerateFromMissingRequest(BaseModel):
    """Requête pour générer une liste depuis les ingrédients manquants"""
    recipe_ids: Optional[list[UUID]] = None  # Recettes spécifiques, ou toutes si None

