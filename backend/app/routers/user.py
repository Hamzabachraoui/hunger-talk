"""
Router pour la gestion de l'utilisateur et ses préférences
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Optional
from uuid import UUID, uuid4
from datetime import datetime

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from database import get_db
from app.models.user import User
from app.models.user_preferences import UserPreferences
from app.schemas.user_preferences import (
    UserPreferencesCreate,
    UserPreferencesUpdate,
    UserPreferencesResponse
)
from app.schemas.user import User as UserSchema, UserUpdate
from app.core.dependencies import get_current_user

router = APIRouter()


@router.get("/preferences", response_model=UserPreferencesResponse)
async def get_user_preferences(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupérer les préférences de l'utilisateur.
    
    Si aucune préférence n'existe, retourne une structure vide.
    """
    preferences = db.query(UserPreferences).filter(
        UserPreferences.user_id == current_user.id
    ).first()
    
    if not preferences:
        # Retourner une structure vide si aucune préférence n'existe
        return UserPreferencesResponse(
            id=uuid4(),
            user_id=current_user.id,
            dietary_restrictions=None,
            allergies=None,
            daily_calorie_goal=None,
            daily_protein_goal=None,
            daily_carb_goal=None,
            daily_fat_goal=None,
            preferred_cuisines=None,
            disliked_ingredients=None,
            max_prep_time=None,
            max_cooking_time=None,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
    
    return UserPreferencesResponse(
        id=preferences.id,
        user_id=preferences.user_id,
        dietary_restrictions=preferences.dietary_restrictions,
        allergies=preferences.allergies,
        daily_calorie_goal=preferences.daily_calorie_goal,
        daily_protein_goal=preferences.daily_protein_goal,
        daily_carb_goal=preferences.daily_carb_goal,
        daily_fat_goal=preferences.daily_fat_goal,
        preferred_cuisines=preferences.preferred_cuisines,
        disliked_ingredients=preferences.disliked_ingredients,
        max_prep_time=preferences.max_prep_time,
        max_cooking_time=preferences.max_cooking_time,
        created_at=preferences.created_at,
        updated_at=preferences.updated_at
    )


@router.get("/me", response_model=UserSchema)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupérer le profil de l'utilisateur connecté.
    """
    return UserSchema(
        id=current_user.id,
        email=current_user.email,
        first_name=current_user.first_name,
        last_name=current_user.last_name,
        is_active=current_user.is_active,
        created_at=current_user.created_at,
        updated_at=current_user.updated_at,
        last_login=current_user.last_login
    )


@router.put("/me", response_model=UserSchema)
async def update_current_user_profile(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Mettre à jour le profil de l'utilisateur connecté.
    """
    # Mettre à jour les champs fournis
    if user_update.first_name is not None:
        current_user.first_name = user_update.first_name
    if user_update.last_name is not None:
        current_user.last_name = user_update.last_name
    
    try:
        db.commit()
        db.refresh(current_user)
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors de la mise à jour du profil: {str(e)}"
        )
    
    return UserSchema(
        id=current_user.id,
        email=current_user.email,
        first_name=current_user.first_name,
        last_name=current_user.last_name,
        is_active=current_user.is_active,
        created_at=current_user.created_at,
        updated_at=current_user.updated_at,
        last_login=current_user.last_login
    )


@router.put("/preferences", response_model=UserPreferencesResponse)
async def update_user_preferences(
    preferences_update: UserPreferencesUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Mettre à jour les préférences de l'utilisateur.
    
    Crée les préférences si elles n'existent pas, sinon les met à jour.
    Tous les champs sont optionnels - seuls les champs fournis seront mis à jour.
    """
    preferences = db.query(UserPreferences).filter(
        UserPreferences.user_id == current_user.id
    ).first()
    
    if not preferences:
        # Créer de nouvelles préférences
        preferences = UserPreferences(
            id=uuid4(),
            user_id=current_user.id,
            dietary_restrictions=preferences_update.dietary_restrictions,
            allergies=preferences_update.allergies,
            daily_calorie_goal=preferences_update.daily_calorie_goal,
            daily_protein_goal=preferences_update.daily_protein_goal,
            daily_carb_goal=preferences_update.daily_carb_goal,
            daily_fat_goal=preferences_update.daily_fat_goal,
            preferred_cuisines=preferences_update.preferred_cuisines,
            disliked_ingredients=preferences_update.disliked_ingredients,
            max_prep_time=preferences_update.max_prep_time,
            max_cooking_time=preferences_update.max_cooking_time
        )
        db.add(preferences)
    else:
        # Mettre à jour les préférences existantes
        if preferences_update.dietary_restrictions is not None:
            preferences.dietary_restrictions = preferences_update.dietary_restrictions
        if preferences_update.allergies is not None:
            preferences.allergies = preferences_update.allergies
        if preferences_update.daily_calorie_goal is not None:
            preferences.daily_calorie_goal = preferences_update.daily_calorie_goal
        if preferences_update.daily_protein_goal is not None:
            preferences.daily_protein_goal = preferences_update.daily_protein_goal
        if preferences_update.daily_carb_goal is not None:
            preferences.daily_carb_goal = preferences_update.daily_carb_goal
        if preferences_update.daily_fat_goal is not None:
            preferences.daily_fat_goal = preferences_update.daily_fat_goal
        if preferences_update.preferred_cuisines is not None:
            preferences.preferred_cuisines = preferences_update.preferred_cuisines
        if preferences_update.disliked_ingredients is not None:
            preferences.disliked_ingredients = preferences_update.disliked_ingredients
        if preferences_update.max_prep_time is not None:
            preferences.max_prep_time = preferences_update.max_prep_time
        if preferences_update.max_cooking_time is not None:
            preferences.max_cooking_time = preferences_update.max_cooking_time
    
    try:
        db.commit()
        db.refresh(preferences)
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors de la mise à jour des préférences: {str(e)}"
        )
    
    return UserPreferencesResponse(
        id=preferences.id,
        user_id=preferences.user_id,
        dietary_restrictions=preferences.dietary_restrictions,
        allergies=preferences.allergies,
        daily_calorie_goal=preferences.daily_calorie_goal,
        daily_protein_goal=preferences.daily_protein_goal,
        daily_carb_goal=preferences.daily_carb_goal,
        daily_fat_goal=preferences.daily_fat_goal,
        preferred_cuisines=preferences.preferred_cuisines,
        disliked_ingredients=preferences.disliked_ingredients,
        max_prep_time=preferences.max_prep_time,
        max_cooking_time=preferences.max_cooking_time,
        created_at=preferences.created_at,
        updated_at=preferences.updated_at
    )


@router.get("/me", response_model=UserSchema)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupérer le profil de l'utilisateur connecté.
    """
    return UserSchema(
        id=current_user.id,
        email=current_user.email,
        first_name=current_user.first_name,
        last_name=current_user.last_name,
        is_active=current_user.is_active,
        created_at=current_user.created_at,
        updated_at=current_user.updated_at,
        last_login=current_user.last_login
    )


@router.put("/me", response_model=UserSchema)
async def update_current_user_profile(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Mettre à jour le profil de l'utilisateur connecté.
    """
    # Mettre à jour les champs fournis
    if user_update.first_name is not None:
        current_user.first_name = user_update.first_name
    if user_update.last_name is not None:
        current_user.last_name = user_update.last_name
    
    try:
        db.commit()
        db.refresh(current_user)
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors de la mise à jour du profil: {str(e)}"
        )
    
    return UserSchema(
        id=current_user.id,
        email=current_user.email,
        first_name=current_user.first_name,
        last_name=current_user.last_name,
        is_active=current_user.is_active,
        created_at=current_user.created_at,
        updated_at=current_user.updated_at,
        last_login=current_user.last_login
    )

