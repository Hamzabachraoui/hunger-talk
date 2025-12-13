"""
Router pour les recommandations de recettes
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from database import get_db
from app.models.user import User
from app.schemas.recommendation import (
    RecipeRecommendation,
    RecommendationRequest,
    RecommendationResponse
)
from app.core.dependencies import get_current_user
from app.services.recommendation_service import RecommendationService

router = APIRouter()


@router.get("/", response_model=RecommendationResponse)
async def get_recommendations(
    limit: Optional[int] = Query(10, ge=1, le=50, description="Nombre maximum de recommandations"),
    min_match_score: Optional[float] = Query(0.0, ge=0.0, le=1.0, description="Score minimum de compatibilité"),
    include_nutrition: Optional[bool] = Query(True, description="Inclure le calcul nutritionnel"),
    include_preferences: Optional[bool] = Query(True, description="Inclure le filtrage par préférences"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupérer les recommandations de recettes personnalisées pour l'utilisateur.
    
    Les recommandations sont basées sur :
    - La compatibilité avec le stock actuel (60% du score)
    - Les préférences utilisateur (restrictions, allergies, objectifs)
    - Les valeurs nutritionnelles (40% du score)
    
    Les recettes sont triées par score final décroissant.
    """
    try:
        service = RecommendationService(db, current_user.id)
        
        recommendations_data = service.get_recommendations(
            limit=limit,
            min_match_score=min_match_score,
            include_nutrition=include_nutrition,
            include_preferences=include_preferences
        )
        
        # Convertir en schémas Pydantic
        recommendations = [
            RecipeRecommendation(**rec) for rec in recommendations_data
        ]
        
        return RecommendationResponse(
            recommendations=recommendations,
            total_found=len(recommendations),
            filters_applied={
                "limit": limit,
                "min_match_score": min_match_score,
                "include_nutrition": include_nutrition,
                "include_preferences": include_preferences
            }
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors de la génération des recommandations: {str(e)}"
        )


@router.post("/", response_model=RecommendationResponse)
async def get_recommendations_custom(
    request: RecommendationRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupérer les recommandations avec des paramètres personnalisés (version POST).
    
    Permet de passer des paramètres plus complexes via le body de la requête.
    """
    try:
        service = RecommendationService(db, current_user.id)
        
        recommendations_data = service.get_recommendations(
            limit=request.limit or 10,
            min_match_score=request.min_match_score or 0.0,
            include_nutrition=request.include_nutrition if request.include_nutrition is not None else True,
            include_preferences=request.include_preferences if request.include_preferences is not None else True
        )
        
        # Convertir en schémas Pydantic
        recommendations = [
            RecipeRecommendation(**rec) for rec in recommendations_data
        ]
        
        return RecommendationResponse(
            recommendations=recommendations,
            total_found=len(recommendations),
            filters_applied={
                "limit": request.limit,
                "min_match_score": request.min_match_score,
                "include_nutrition": request.include_nutrition,
                "include_preferences": request.include_preferences
            }
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors de la génération des recommandations: {str(e)}"
        )

