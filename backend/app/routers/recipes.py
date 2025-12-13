"""
Router pour la gestion des recettes
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID
from datetime import datetime
from decimal import Decimal

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from database import get_db
from app.models.user import User
from app.models.recipe import Recipe, RecipeIngredient, RecipeStep, NutritionData
from app.models.stock_item import StockItem
from app.models.user_preferences import UserPreferences
from app.models.cooking_history import CookingHistory
from app.schemas.recipe import (
    RecipeSummary,
    RecipeDetail,
    CookRecipeRequest,
    CookRecipeResponse
)
from app.core.dependencies import get_current_user, get_optional_current_user

router = APIRouter()


def check_recipe_availability(recipe: Recipe, user_id: UUID, db: Session) -> dict:
    """
    Vérifier si une recette est réalisable avec le stock actuel de l'utilisateur.
    
    Returns:
        dict avec:
        - match_score: score de compatibilité (0.0-1.0)
        - available_ingredients: nombre d'ingrédients disponibles
        - missing_ingredients: nombre d'ingrédients manquants
        - missing_ingredients_list: liste des ingrédients manquants
        - can_cook: bool si tous les ingrédients sont disponibles
    """
    ingredients = db.query(RecipeIngredient).filter(
        RecipeIngredient.recipe_id == recipe.id,
        RecipeIngredient.optional == False
    ).all()
    
    if not ingredients:
        return {
            "match_score": 0.0,
            "available_ingredients": 0,
            "missing_ingredients": 0,
            "missing_ingredients_list": [],
            "can_cook": False
        }
    
    # Récupérer le stock de l'utilisateur
    stock_items = db.query(StockItem).filter(StockItem.user_id == user_id).all()
    
    # Créer un dictionnaire du stock (nom normalisé en minuscules)
    stock_dict = {}
    for item in stock_items:
        name_lower = item.name.lower().strip()
        stock_dict[name_lower] = {
            "item": item,
            "quantity": float(item.quantity),
            "unit": item.unit or ""
        }
    
    available_count = 0
    missing_ingredients = []
    
    for ingredient in ingredients:
        ingredient_name_lower = ingredient.ingredient_name.lower().strip()
        found = False
        
        # Chercher une correspondance exacte ou partielle
        for stock_name, stock_data in stock_dict.items():
            if ingredient_name_lower in stock_name or stock_name in ingredient_name_lower:
                # Vérifier la quantité
                required_qty = float(ingredient.quantity)
                available_qty = stock_data["quantity"]
                
                # Conversion basique des unités (simplifié)
                if ingredient.unit.lower() == stock_data["unit"].lower() or \
                   (ingredient.unit.lower() in ["unité", "unités", "unite"] and 
                    stock_data["unit"].lower() in ["unité", "unités", "unite"]):
                    if available_qty >= required_qty:
                        available_count += 1
                        found = True
                        break
        
        if not found:
            missing_ingredients.append(ingredient.ingredient_name)
    
    total_required = len(ingredients)
    match_score = available_count / total_required if total_required > 0 else 0.0
    
    return {
        "match_score": match_score,
        "available_ingredients": available_count,
        "missing_ingredients": len(missing_ingredients),
        "missing_ingredients_list": missing_ingredients,
        "can_cook": len(missing_ingredients) == 0
    }


@router.get("/", response_model=List[RecipeSummary])
async def get_recipes(
    difficulty: Optional[str] = Query(None, description="Filtrer par difficulté (Facile, Moyen, Difficile)"),
    max_time: Optional[int] = Query(None, description="Temps maximum en minutes"),
    min_servings: Optional[int] = Query(None, description="Nombre minimum de portions"),
    current_user: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupérer la liste des recettes disponibles.
    
    Options de filtrage :
    - Par difficulté
    - Par temps maximum
    - Par nombre de portions minimum
    
    Si l'utilisateur est connecté, calcule aussi le score de compatibilité avec son stock.
    """
    # Requête de base : recettes actives
    query = db.query(Recipe).filter(Recipe.is_active == True)
    
    # Filtres
    if difficulty:
        query = query.filter(Recipe.difficulty == difficulty)
    
    if max_time:
        query = query.filter(Recipe.total_time <= max_time)
    
    if min_servings:
        query = query.filter(Recipe.servings >= min_servings)
    
    recipes = query.order_by(Recipe.name).all()
    
    result = []
    for recipe in recipes:
        try:
            # Récupérer les infos nutritionnelles
            nutrition = db.query(NutritionData).filter(
                NutritionData.recipe_id == recipe.id
            ).first()
            
            # Préparer les calories
            calories_value = None
            if nutrition and nutrition.calories is not None:
                calories_value = Decimal(str(nutrition.calories))
            
            recipe_dict = {
                "id": recipe.id,
                "name": recipe.name,
                "description": recipe.description,
                "total_time": recipe.total_time,
                "difficulty": recipe.difficulty,
                "servings": recipe.servings,
                "image_url": recipe.image_url,
                "calories": calories_value
            }
            
            # Si l'utilisateur est connecté, calculer la compatibilité
            if current_user:
                availability = check_recipe_availability(recipe, current_user.id, db)
                recipe_dict["match_score"] = availability["match_score"]
                recipe_dict["available_ingredients"] = availability["available_ingredients"]
                recipe_dict["missing_ingredients"] = availability["missing_ingredients"]
            
            recipe_summary = RecipeSummary(**recipe_dict)
            result.append(recipe_summary)
        except Exception as e:
            # Log l'erreur mais continue avec les autres recettes
            import logging
            import traceback
            logger = logging.getLogger(__name__)
            logger.error(f"Erreur lors du traitement de la recette {recipe.id}: {e}", exc_info=True)
            # En développement, on peut aussi print pour debug
            print(f"❌ Erreur recette {recipe.name}: {e}")
            traceback.print_exc()
            continue
    
    return result


@router.get("/{recipe_id}", response_model=RecipeDetail)
async def get_recipe_details(
    recipe_id: UUID,
    current_user: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupérer les détails complets d'une recette.
    
    Inclut :
    - Informations de base
    - Liste des ingrédients avec quantités
    - Étapes de préparation
    - Informations nutritionnelles
    - Vérification de compatibilité avec le stock (si utilisateur connecté)
    """
    recipe = db.query(Recipe).filter(Recipe.id == recipe_id).first()
    
    if not recipe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Recette non trouvée"
        )
    
    # Récupérer les ingrédients
    ingredients = db.query(RecipeIngredient).filter(
        RecipeIngredient.recipe_id == recipe_id
    ).order_by(RecipeIngredient.order_index).all()
    
    # Récupérer les étapes
    steps = db.query(RecipeStep).filter(
        RecipeStep.recipe_id == recipe_id
    ).order_by(RecipeStep.step_number).all()
    
    # Récupérer les infos nutritionnelles
    nutrition = db.query(NutritionData).filter(
        NutritionData.recipe_id == recipe_id
    ).first()
    
    # Construire la réponse
    recipe_dict = {
        "id": recipe.id,
        "name": recipe.name,
        "description": recipe.description,
        "preparation_time": recipe.preparation_time,
        "cooking_time": recipe.cooking_time,
        "total_time": recipe.total_time,
        "difficulty": recipe.difficulty,
        "servings": recipe.servings,
        "image_url": recipe.image_url,
        "created_at": recipe.created_at,
        "updated_at": recipe.updated_at,
        "is_active": recipe.is_active,
        "ingredients": ingredients,
        "steps": steps,
        "nutrition": nutrition,
        "can_cook": False,
        "missing_ingredients_list": []
    }
    
    # Si l'utilisateur est connecté, vérifier la disponibilité
    if current_user:
        availability = check_recipe_availability(recipe, current_user.id, db)
        recipe_dict["match_score"] = availability["match_score"]
        recipe_dict["available_ingredients"] = availability["available_ingredients"]
        recipe_dict["missing_ingredients"] = availability["missing_ingredients"]
        recipe_dict["missing_ingredients_list"] = availability["missing_ingredients_list"]
        recipe_dict["can_cook"] = availability["can_cook"]
    
    return RecipeDetail(**recipe_dict)


@router.post("/{recipe_id}/cook", response_model=CookRecipeResponse)
async def cook_recipe(
    recipe_id: UUID,
    cook_data: CookRecipeRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Cuisiner une recette.
    
    Actions effectuées :
    1. Vérifie que tous les ingrédients sont disponibles
    2. Met à jour le stock (soustrait les quantités utilisées)
    3. Supprime les produits arrivés à zéro
    4. Enregistre l'activité de cuisson dans l'historique
    5. Retourne une confirmation
    
    Note: Si servings n'est pas fourni, utilise le nombre de portions de la recette.
    """
    # Récupérer la recette
    recipe = db.query(Recipe).filter(Recipe.id == recipe_id).first()
    if not recipe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Recette non trouvée"
        )
    
    # Vérifier la disponibilité
    availability = check_recipe_availability(recipe, current_user.id, db)
    if not availability["can_cook"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Impossible de cuisiner cette recette. Ingrédients manquants: {', '.join(availability['missing_ingredients_list'])}"
        )
    
    # Nombre de portions à cuisiner
    servings_to_cook = cook_data.servings or recipe.servings
    ratio = servings_to_cook / recipe.servings if recipe.servings > 0 else 1.0
    
    # Récupérer les ingrédients de la recette
    ingredients = db.query(RecipeIngredient).filter(
        RecipeIngredient.recipe_id == recipe_id,
        RecipeIngredient.optional == False
    ).all()
    
    # Récupérer le stock de l'utilisateur
    stock_items = db.query(StockItem).filter(StockItem.user_id == current_user.id).all()
    stock_dict = {}
    for item in stock_items:
        name_lower = item.name.lower().strip()
        stock_dict[name_lower] = item
    
    items_removed = []
    items_updated = []
    
    # Pour chaque ingrédient, trouver le produit correspondant et mettre à jour
    for ingredient in ingredients:
        ingredient_name_lower = ingredient.ingredient_name.lower().strip()
        required_qty = float(ingredient.quantity) * ratio
        
        # Chercher le produit correspondant
        matched_item = None
        for stock_name, stock_item in stock_dict.items():
            if ingredient_name_lower in stock_name or stock_name in ingredient_name_lower:
                # Vérifier l'unité (simplifié)
                if ingredient.unit.lower() == (stock_item.unit or "").lower() or \
                   (ingredient.unit.lower() in ["unité", "unités", "unite"] and 
                    (stock_item.unit or "").lower() in ["unité", "unités", "unite"]):
                    matched_item = stock_item
                    break
        
        if matched_item:
            # Soustraire la quantité utilisée
            new_quantity = float(matched_item.quantity) - required_qty
            
            if new_quantity <= 0:
                # Supprimer le produit
                db.delete(matched_item)
                items_removed.append(matched_item.name)
            else:
                # Mettre à jour la quantité
                matched_item.quantity = new_quantity
                items_updated.append(matched_item.name)
    
    # Enregistrer dans l'historique de cuisson
    cooking_history = CookingHistory(
        user_id=current_user.id,
        recipe_id=recipe_id,
        servings_made=servings_to_cook,
        cooked_at=datetime.utcnow()
    )
    db.add(cooking_history)
    
    db.commit()
    
    return CookRecipeResponse(
        success=True,
        message=f"Recette '{recipe.name}' cuisinée avec succès !",
        recipe_id=recipe_id,
        servings_made=servings_to_cook,
        stock_updated=True,
        items_removed=items_removed
    )

