"""
Schemas Pydantic pour les recommandations
"""
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from uuid import UUID
from decimal import Decimal


class MissingIngredient(BaseModel):
    """Ingrédient manquant"""
    name: str
    quantity: float
    unit: str


class PartialMatch(BaseModel):
    """Ingrédient partiellement disponible"""
    name: str
    required: float
    available: float
    unit: str


class RecipeRecommendation(BaseModel):
    """Recommandation de recette"""
    recipe_id: UUID
    recipe_name: str
    description: Optional[str] = None
    total_time: Optional[int] = None
    difficulty: Optional[str] = None
    servings: int
    image_url: Optional[str] = None
    final_score: float = Field(..., description="Score final de recommandation (0.0-1.0)")
    match_score: float = Field(..., description="Score de compatibilité avec le stock (0.0-1.0)")
    nutrition_score: float = Field(..., description="Score nutritionnel (0.0-1.0)")
    can_cook: bool = Field(..., description="Si tous les ingrédients sont disponibles")
    available_ingredients: int = Field(..., description="Nombre d'ingrédients disponibles")
    total_ingredients: int = Field(..., description="Nombre total d'ingrédients requis")
    missing_ingredients: List[MissingIngredient] = []
    partial_matches: List[PartialMatch] = []
    calories: Optional[float] = None
    proteins: Optional[float] = None
    carbs: Optional[float] = None
    fats: Optional[float] = None
    goals_met: Optional[Dict[str, str]] = Field(None, description="Objectifs nutritionnels atteints")
    
    class Config:
        from_attributes = True


class RecommendationRequest(BaseModel):
    """Paramètres pour les recommandations"""
    limit: Optional[int] = Field(10, ge=1, le=50, description="Nombre maximum de recommandations")
    min_match_score: Optional[float] = Field(0.0, ge=0.0, le=1.0, description="Score minimum de compatibilité")
    include_nutrition: Optional[bool] = Field(True, description="Inclure le calcul nutritionnel")
    include_preferences: Optional[bool] = Field(True, description="Inclure le filtrage par préférences")


class RecommendationResponse(BaseModel):
    """Réponse avec les recommandations"""
    recommendations: List[RecipeRecommendation]
    total_found: int
    filters_applied: Dict[str, Any]

