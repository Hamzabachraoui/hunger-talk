"""
Router pour la liste de courses
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID, uuid4
from datetime import datetime
from decimal import Decimal

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from database import get_db
from app.models.user import User
from app.models.shopping_list import ShoppingListItem
from app.models.recipe import Recipe, RecipeIngredient
from app.models.stock_item import StockItem
from app.models.category import Category
from app.schemas.shopping_list import (
    ShoppingListItemCreate,
    ShoppingListItemUpdate,
    ShoppingListItemResponse,
    ShoppingListSummary,
    GenerateFromRecipeRequest,
    GenerateFromMissingRequest
)
from app.core.dependencies import get_current_user

router = APIRouter()


@router.get("/", response_model=ShoppingListSummary)
async def get_shopping_list(
    purchased_only: Optional[bool] = Query(False, description="Afficher uniquement les éléments achetés"),
    unpurchased_only: Optional[bool] = Query(False, description="Afficher uniquement les éléments non achetés"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupérer la liste de courses de l'utilisateur.
    
    Options de filtrage :
    - purchased_only: Afficher uniquement les éléments achetés
    - unpurchased_only: Afficher uniquement les éléments non achetés
    """
    query = db.query(ShoppingListItem).filter(
        ShoppingListItem.user_id == current_user.id
    )
    
    if purchased_only:
        query = query.filter(ShoppingListItem.is_purchased == True)
    elif unpurchased_only:
        query = query.filter(ShoppingListItem.is_purchased == False)
    
    items = query.order_by(ShoppingListItem.added_at.desc()).all()
    
    purchased_count = len([item for item in items if item.is_purchased])
    
    return ShoppingListSummary(
        total_items=len(items),
        purchased_items=purchased_count,
        remaining_items=len(items) - purchased_count,
        items=[ShoppingListItemResponse(
            id=item.id,
            user_id=item.user_id,
            item_name=item.item_name,
            quantity=float(item.quantity),
            unit=item.unit or "unité",
            category_id=item.category_id,
            is_purchased=item.is_purchased,
            added_at=item.added_at,
            purchased_at=item.purchased_at,
            notes=item.notes
        ) for item in items]
    )


@router.post("/", response_model=ShoppingListItemResponse, status_code=status.HTTP_201_CREATED)
async def add_shopping_list_item(
    item: ShoppingListItemCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Ajouter un élément à la liste de courses.
    """
    # Vérifier que la catégorie existe si fournie
    if item.category_id:
        category = db.query(Category).filter(Category.id == item.category_id).first()
        if not category:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Catégorie avec l'ID {item.category_id} non trouvée"
            )
    
    shopping_item = ShoppingListItem(
        id=uuid4(),
        user_id=current_user.id,
        item_name=item.item_name,
        quantity=Decimal(str(item.quantity)),
        unit=item.unit or "unité",
        category_id=item.category_id,
        notes=item.notes,
        is_purchased=False,
        added_at=datetime.utcnow()
    )
    
    db.add(shopping_item)
    db.commit()
    db.refresh(shopping_item)
    
    return ShoppingListItemResponse(
        id=shopping_item.id,
        user_id=shopping_item.user_id,
        item_name=shopping_item.item_name,
        quantity=float(shopping_item.quantity),
        unit=shopping_item.unit or "unité",
        category_id=shopping_item.category_id,
        is_purchased=shopping_item.is_purchased,
        added_at=shopping_item.added_at,
        purchased_at=shopping_item.purchased_at,
        notes=shopping_item.notes
    )


@router.put("/{item_id}", response_model=ShoppingListItemResponse)
async def update_shopping_list_item(
    item_id: UUID,
    item_update: ShoppingListItemUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Mettre à jour un élément de la liste de courses.
    """
    shopping_item = db.query(ShoppingListItem).filter(
        ShoppingListItem.id == item_id,
        ShoppingListItem.user_id == current_user.id
    ).first()
    
    if not shopping_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Élément de liste de courses non trouvé"
        )
    
    # Mettre à jour les champs fournis
    if item_update.item_name is not None:
        shopping_item.item_name = item_update.item_name
    if item_update.quantity is not None:
        shopping_item.quantity = item_update.quantity
    if item_update.unit is not None:
        shopping_item.unit = item_update.unit
    if item_update.category_id is not None:
        # Vérifier que la catégorie existe
        category = db.query(Category).filter(Category.id == item_update.category_id).first()
        if not category:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Catégorie avec l'ID {item_update.category_id} non trouvée"
            )
        shopping_item.category_id = item_update.category_id
    if item_update.is_purchased is not None:
        shopping_item.is_purchased = item_update.is_purchased
        if item_update.is_purchased and not shopping_item.purchased_at:
            shopping_item.purchased_at = datetime.utcnow()
        elif not item_update.is_purchased:
            shopping_item.purchased_at = None
    if item_update.notes is not None:
        shopping_item.notes = item_update.notes
    
    db.commit()
    db.refresh(shopping_item)
    
    return ShoppingListItemResponse(
        id=shopping_item.id,
        user_id=shopping_item.user_id,
        item_name=shopping_item.item_name,
        quantity=float(shopping_item.quantity),
        unit=shopping_item.unit or "unité",
        category_id=shopping_item.category_id,
        is_purchased=shopping_item.is_purchased,
        added_at=shopping_item.added_at,
        purchased_at=shopping_item.purchased_at,
        notes=shopping_item.notes
    )


@router.delete("/{item_id}", status_code=status.HTTP_200_OK)
async def delete_shopping_list_item(
    item_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Supprimer un élément de la liste de courses.
    """
    shopping_item = db.query(ShoppingListItem).filter(
        ShoppingListItem.id == item_id,
        ShoppingListItem.user_id == current_user.id
    ).first()
    
    if not shopping_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Élément de liste de courses non trouvé"
        )
    
    db.delete(shopping_item)
    db.commit()
    
    return {"message": "Élément supprimé de la liste de courses", "item_id": str(item_id)}


@router.post("/generate-from-recipe", response_model=List[ShoppingListItemResponse], status_code=status.HTTP_201_CREATED)
async def generate_from_recipe(
    request: GenerateFromRecipeRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Générer une liste de courses à partir d'une recette.
    
    Ajoute tous les ingrédients de la recette à la liste de courses.
    """
    try:
        recipe = db.query(Recipe).filter(Recipe.id == request.recipe_id).first()
        
        if not recipe:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Recette non trouvée"
            )
        
        # Calculer le ratio de portions
        target_servings = request.servings if request.servings is not None else recipe.servings
        if recipe.servings and recipe.servings > 0:
            try:
                servings_ratio = Decimal(str(target_servings)) / Decimal(str(recipe.servings))
            except (ValueError, ZeroDivisionError, TypeError):
                servings_ratio = Decimal('1.0')
        else:
            servings_ratio = Decimal('1.0')
        
        # Récupérer les ingrédients
        ingredients = db.query(RecipeIngredient).filter(
            RecipeIngredient.recipe_id == request.recipe_id
        ).all()
        
        if not ingredients:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cette recette n'a pas d'ingrédients"
            )
        
        created_items = []
        items_to_update = []
        items_to_add = []
        
        for ingredient in ingredients:
            try:
                # Convertir la quantité de l'ingrédient en Decimal
                if isinstance(ingredient.quantity, Decimal):
                    ingredient_qty = ingredient.quantity
                else:
                    ingredient_qty = Decimal(str(ingredient.quantity))
                calculated_qty = ingredient_qty * servings_ratio
                
                # Vérifier si l'élément existe déjà dans la liste
                existing = db.query(ShoppingListItem).filter(
                    ShoppingListItem.user_id == current_user.id,
                    ShoppingListItem.item_name.ilike(f"%{ingredient.ingredient_name}%"),
                    ShoppingListItem.is_purchased == False
                ).first()
                
                if existing:
                    # Mettre à jour la quantité
                    existing.quantity += calculated_qty
                    items_to_update.append(existing)
                    created_items.append(existing)
                else:
                    # Créer un nouvel élément
                    shopping_item = ShoppingListItem(
                        id=uuid4(),
                        user_id=current_user.id,
                        item_name=ingredient.ingredient_name,
                        quantity=calculated_qty,
                        unit=ingredient.unit or "unité",
                        is_purchased=False,
                        added_at=datetime.utcnow()
                    )
                    items_to_add.append(shopping_item)
                    created_items.append(shopping_item)
            except Exception as e:
                # Continuer avec les autres ingrédients en cas d'erreur
                import logging
                logger = logging.getLogger(__name__)
                logger.error(f"Erreur lors de l'ajout de l'ingrédient {ingredient.ingredient_name}: {e}")
                continue
        
        # Ajouter tous les nouveaux éléments
        for item in items_to_add:
            db.add(item)
        
        # Commit une seule fois pour toutes les modifications
        try:
            if items_to_add or items_to_update:
                db.commit()
            
            # Refresh tous les éléments
            for item in created_items:
                try:
                    db.refresh(item)
                except:
                    pass  # Ignorer si l'élément n'est plus dans la session
        except Exception as e:
            db.rollback()
            import traceback
            error_detail = str(e)
            traceback.print_exc()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erreur lors de la sauvegarde: {error_detail}"
            )
        
        return [ShoppingListItemResponse(
            id=item.id,
            user_id=item.user_id,
            item_name=item.item_name,
            quantity=float(item.quantity),
            unit=item.unit or "unité",
            category_id=item.category_id,
            is_purchased=item.is_purchased,
            added_at=item.added_at,
            purchased_at=item.purchased_at,
            notes=item.notes
        ) for item in created_items]
    
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors de la génération de la liste: {str(e)}"
        )


@router.post("/generate-from-missing", response_model=List[ShoppingListItemResponse], status_code=status.HTTP_201_CREATED)
async def generate_from_missing_ingredients(
    request: GenerateFromMissingRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Générer une liste de courses à partir des ingrédients manquants.
    
    Analyse les recettes spécifiées (ou toutes les recettes) et ajoute les ingrédients
    manquants dans le stock actuel à la liste de courses.
    """
    # Récupérer le stock de l'utilisateur
    stock_items = db.query(StockItem).filter(StockItem.user_id == current_user.id).all()
    stock_dict = {item.name.lower().strip(): item for item in stock_items}
    
    # Récupérer les recettes
    if request.recipe_ids:
        recipes = db.query(Recipe).filter(
            Recipe.id.in_(request.recipe_ids),
            Recipe.is_active == True
        ).all()
    else:
        recipes = db.query(Recipe).filter(Recipe.is_active == True).all()
    
    if not recipes:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Aucune recette trouvée"
        )
    
    missing_ingredients = {}
    
    for recipe in recipes:
        ingredients = db.query(RecipeIngredient).filter(
            RecipeIngredient.recipe_id == recipe.id,
            RecipeIngredient.optional == False
        ).all()
        
        for ingredient in ingredients:
            ingredient_name_lower = ingredient.ingredient_name.lower().strip()
            
            # Vérifier si l'ingrédient est dans le stock
            found = False
            for stock_name in stock_dict.keys():
                if (ingredient_name_lower in stock_name or 
                    stock_name in ingredient_name_lower):
                    found = True
                    break
            
            if not found:
                # Ajouter à la liste des ingrédients manquants
                if ingredient_name_lower not in missing_ingredients:
                    missing_ingredients[ingredient_name_lower] = {
                        "name": ingredient.ingredient_name,
                        "quantity": float(ingredient.quantity),
                        "unit": ingredient.unit or "unité"
                    }
                else:
                    # Additionner les quantités si plusieurs recettes utilisent le même ingrédient
                    missing_ingredients[ingredient_name_lower]["quantity"] += float(ingredient.quantity)
    
    if not missing_ingredients:
        return []  # Tous les ingrédients sont disponibles
    
    created_items = []
    
    for ingredient_data in missing_ingredients.values():
        # Vérifier si l'élément existe déjà
        existing = db.query(ShoppingListItem).filter(
            ShoppingListItem.user_id == current_user.id,
            ShoppingListItem.item_name.ilike(f"%{ingredient_data['name']}%"),
            ShoppingListItem.is_purchased == False
        ).first()
        
        if existing:
            existing.quantity += Decimal(str(ingredient_data["quantity"]))
            db.commit()
            db.refresh(existing)
            created_items.append(existing)
        else:
            shopping_item = ShoppingListItem(
                id=uuid4(),
                user_id=current_user.id,
                item_name=ingredient_data["name"],
                quantity=Decimal(str(ingredient_data["quantity"])),
                unit=ingredient_data["unit"],
                is_purchased=False,
                added_at=datetime.utcnow()
            )
            
            db.add(shopping_item)
            db.commit()
            db.refresh(shopping_item)
            created_items.append(shopping_item)
    
    return [ShoppingListItemResponse(
        id=item.id,
        user_id=item.user_id,
        item_name=item.item_name,
        quantity=float(item.quantity),
        unit=item.unit or "unité",
        category_id=item.category_id,
        is_purchased=item.is_purchased,
        added_at=item.added_at,
        purchased_at=item.purchased_at,
        notes=item.notes
    ) for item in created_items]

