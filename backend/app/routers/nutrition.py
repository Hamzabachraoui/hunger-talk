"""
Router pour la nutrition et les statistiques
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional
from datetime import date, datetime

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from database import get_db
from app.models.user import User
from app.schemas.nutrition import DailyNutritionResponse, WeeklyNutritionResponse
from app.core.dependencies import get_current_user
from app.services.nutrition_service import NutritionService

router = APIRouter()


@router.get("/daily", response_model=DailyNutritionResponse)
async def get_daily_nutrition(
    target_date: Optional[str] = Query(None, description="Date cible au format YYYY-MM-DD (par défaut: aujourd'hui)"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupérer les statistiques nutritionnelles pour une journée.
    
    Calcule les valeurs nutritionnelles totales basées sur les recettes cuisinées ce jour :
    - Calories, protéines, glucides, lipides
    - Comparaison avec les objectifs de l'utilisateur
    - Liste des recettes cuisinées
    
    Si aucune date n'est fournie, utilise la date du jour.
    """
    try:
        # Parser la date si fournie
        parsed_date = None
        if target_date:
            try:
                parsed_date = datetime.strptime(target_date, "%Y-%m-%d").date()
            except ValueError:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Format de date invalide. Utilisez YYYY-MM-DD"
                )
        
        service = NutritionService(db, current_user.id)
        result = service.calculate_daily_nutrition(parsed_date)
        
        return DailyNutritionResponse(**result)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors du calcul des statistiques nutritionnelles: {str(e)}"
        )


@router.get("/weekly", response_model=WeeklyNutritionResponse)
async def get_weekly_nutrition(
    start_date: Optional[str] = Query(None, description="Date de début au format YYYY-MM-DD (par défaut: il y a 7 jours)"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupérer les statistiques nutritionnelles pour une semaine.
    
    Calcule les statistiques pour les 7 derniers jours :
    - Stats par jour
    - Moyennes quotidiennes
    - Totaux de la semaine
    - Comparaison avec les objectifs
    
    Si aucune date de début n'est fournie, utilise les 7 derniers jours (incluant aujourd'hui).
    """
    try:
        # Parser la date si fournie
        parsed_start_date = None
        if start_date:
            try:
                parsed_start_date = datetime.strptime(start_date, "%Y-%m-%d").date()
            except ValueError:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Format de date invalide. Utilisez YYYY-MM-DD"
                )
        
        service = NutritionService(db, current_user.id)
        result = service.calculate_weekly_nutrition(parsed_start_date)
        
        return WeeklyNutritionResponse(**result)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors du calcul des statistiques hebdomadaires: {str(e)}"
        )

