"""
Schemas Pydantic pour les recettes
"""
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from uuid import UUID
from decimal import Decimal


class RecipeIngredientSchema(BaseModel):
    """Schéma pour un ingrédient de recette"""
    id: UUID
    ingredient_name: str
    quantity: Decimal
    unit: str
    optional: bool = False
    
    class Config:
        from_attributes = True


class RecipeStepSchema(BaseModel):
    """Schéma pour une étape de recette"""
    id: UUID
    step_number: int
    instruction: str
    image_url: Optional[str] = None
    
    class Config:
        from_attributes = True


class NutritionDataSchema(BaseModel):
    """Schéma pour les données nutritionnelles"""
    id: UUID
    calories: Decimal
    proteins: Decimal
    carbohydrates: Decimal
    fats: Decimal
    fiber: Optional[Decimal] = None
    sugar: Optional[Decimal] = None
    sodium: Optional[Decimal] = None
    per_serving: bool = True
    
    class Config:
        from_attributes = True


class RecipeBase(BaseModel):
    """Schéma de base pour une recette"""
    name: str
    description: Optional[str] = None
    preparation_time: Optional[int] = None
    cooking_time: Optional[int] = None
    total_time: Optional[int] = None
    difficulty: Optional[str] = None
    servings: int = 4
    image_url: Optional[str] = None


class RecipeCreate(RecipeBase):
    """Schéma pour créer une recette"""
    pass


class RecipeUpdate(BaseModel):
    """Schéma pour mettre à jour une recette"""
    name: Optional[str] = None
    description: Optional[str] = None
    preparation_time: Optional[int] = None
    cooking_time: Optional[int] = None
    total_time: Optional[int] = None
    difficulty: Optional[str] = None
    servings: Optional[int] = None
    image_url: Optional[str] = None
    is_active: Optional[bool] = None


class RecipeSummary(BaseModel):
    """Schéma résumé d'une recette (pour les listes)"""
    id: UUID
    name: str
    description: Optional[str] = None
    total_time: Optional[int] = None
    difficulty: Optional[str] = None
    servings: int
    image_url: Optional[str] = None
    calories: Optional[Decimal] = None
    match_score: Optional[float] = None  # Score de compatibilité avec le stock
    available_ingredients: Optional[int] = None  # Nombre d'ingrédients disponibles
    missing_ingredients: Optional[int] = None  # Nombre d'ingrédients manquants
    
    class Config:
        from_attributes = True


class RecipeDetail(RecipeBase):
    """Schéma détaillé d'une recette"""
    id: UUID
    created_at: datetime
    updated_at: datetime
    is_active: bool
    ingredients: List[RecipeIngredientSchema] = []
    steps: List[RecipeStepSchema] = []
    nutrition: Optional[NutritionDataSchema] = None
    match_score: Optional[float] = None  # Score de compatibilité avec le stock
    available_ingredients: Optional[int] = None
    missing_ingredients: Optional[int] = None
    missing_ingredients_list: List[str] = []  # Liste des ingrédients manquants
    can_cook: bool = False  # Si tous les ingrédients sont disponibles
    
    class Config:
        from_attributes = True


class CookRecipeRequest(BaseModel):
    """Schéma pour cuisiner une recette"""
    servings: Optional[int] = None  # Nombre de portions à cuisiner (par défaut: servings de la recette)


class CookRecipeResponse(BaseModel):
    """Schéma de réponse après avoir cuisiné"""
    success: bool
    message: str
    recipe_id: UUID
    servings_made: int
    stock_updated: bool
    items_removed: List[str] = []  # Produits supprimés (quantité = 0)

