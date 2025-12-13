"""
Schemas Pydantic pour la nutrition
"""
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import date


class NutritionTotal(BaseModel):
    """Valeurs nutritionnelles totales"""
    calories: float
    proteins: float
    carbohydrates: float
    fats: float
    fiber: Optional[float] = None
    sugar: Optional[float] = None
    sodium: Optional[float] = None


class NutritionComparison(BaseModel):
    """Comparaison avec un objectif"""
    goal: float
    consumed: float
    remaining: float
    percentage: float
    status: str = Field(..., description="Status: 'over', 'under', or 'good'")


class RecipeCooked(BaseModel):
    """Recette cuisinée dans la journée"""
    recipe_id: str
    recipe_name: str
    servings_made: int
    calories: float
    cooked_at: Optional[str] = None


class DailyNutritionResponse(BaseModel):
    """Réponse pour les stats nutritionnelles quotidiennes"""
    date: str
    total: NutritionTotal
    goals: Dict[str, float] = {}
    comparisons: Dict[str, NutritionComparison] = {}
    recipes_cooked: List[RecipeCooked] = []
    recipes_count: int = 0


class DailyStat(BaseModel):
    """Statistiques d'un jour"""
    date: str
    calories: float
    proteins: float
    carbohydrates: float
    fats: float
    recipes_count: int


class WeeklyNutritionResponse(BaseModel):
    """Réponse pour les stats nutritionnelles hebdomadaires"""
    start_date: str
    end_date: str
    daily_stats: List[DailyStat]
    averages: NutritionTotal
    totals: NutritionTotal
    goals: Dict[str, float] = {}
    days_with_data: int
    total_days: int

