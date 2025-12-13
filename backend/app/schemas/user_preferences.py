"""
Schemas Pydantic pour les préférences utilisateur
"""
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from uuid import UUID
from decimal import Decimal


class UserPreferencesBase(BaseModel):
    """Schéma de base pour les préférences"""
    dietary_restrictions: Optional[List[str]] = None
    allergies: Optional[List[str]] = None
    daily_calorie_goal: Optional[Decimal] = Field(None, ge=0, description="Objectif calorique quotidien")
    daily_protein_goal: Optional[Decimal] = Field(None, ge=0, description="Objectif protéines quotidien (en grammes)")
    daily_carb_goal: Optional[Decimal] = Field(None, ge=0, description="Objectif glucides quotidien (en grammes)")
    daily_fat_goal: Optional[Decimal] = Field(None, ge=0, description="Objectif lipides quotidien (en grammes)")
    preferred_cuisines: Optional[List[str]] = None
    disliked_ingredients: Optional[List[str]] = None
    max_prep_time: Optional[int] = Field(None, ge=0, description="Temps de préparation maximum (en minutes)")
    max_cooking_time: Optional[int] = Field(None, ge=0, description="Temps de cuisson maximum (en minutes)")


class UserPreferencesCreate(UserPreferencesBase):
    """Schéma pour créer des préférences"""
    pass


class UserPreferencesUpdate(UserPreferencesBase):
    """Schéma pour mettre à jour des préférences (tous les champs optionnels)"""
    pass


class UserPreferencesResponse(UserPreferencesBase):
    """Schéma de réponse pour les préférences"""
    id: UUID
    user_id: UUID
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

