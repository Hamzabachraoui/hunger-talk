"""
Router pour la gestion du stock alimentaire
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date, datetime, timedelta
from uuid import UUID

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from database import get_db
from app.models.user import User
from app.models.stock_item import StockItem
from app.models.category import Category as CategoryModel
from app.schemas.stock import (
    StockItemCreate,
    StockItemUpdate,
    StockItem as StockItemSchema,
    StockItemWithCategory
)
from app.schemas.category import Category
from app.core.dependencies import get_current_user

router = APIRouter()


@router.get("/categories", response_model=List[Category])
async def get_categories(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupérer la liste de toutes les catégories disponibles.
    """
    categories = db.query(CategoryModel).order_by(CategoryModel.name.asc()).all()
    return categories


@router.get("/statistics/summary")
async def get_stock_statistics(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Obtenir des statistiques sur le stock de l'utilisateur.
    
    Retourne :
    - Nombre total d'éléments
    - Nombre d'éléments par catégorie
    - Nombre d'éléments expirant bientôt (dans 3 jours)
    - Nombre d'éléments expirés
    """
    # Total d'éléments
    total_items = db.query(StockItem).filter(StockItem.user_id == current_user.id).count()
    
    # Éléments expirant bientôt (dans 3 jours)
    today = date.today()
    three_days_later = today + timedelta(days=3)
    expiring_soon = db.query(StockItem).filter(
        StockItem.user_id == current_user.id,
        StockItem.expiry_date.isnot(None),
        StockItem.expiry_date >= today,
        StockItem.expiry_date <= three_days_later
    ).count()
    
    # Éléments expirés
    expired = db.query(StockItem).filter(
        StockItem.user_id == current_user.id,
        StockItem.expiry_date.isnot(None),
        StockItem.expiry_date < today
    ).count()
    
    # Éléments par catégorie
    from sqlalchemy import func
    items_by_category = db.query(
        CategoryModel.id,
        CategoryModel.name,
        CategoryModel.icon,
        func.count(StockItem.id).label('count')
    ).join(
        StockItem, CategoryModel.id == StockItem.category_id
    ).filter(
        StockItem.user_id == current_user.id
    ).group_by(
        CategoryModel.id, CategoryModel.name, CategoryModel.icon
    ).all()
    
    category_stats = [
        {
            "category_id": cat_id,
            "category_name": name,
            "category_icon": icon,
            "count": count
        }
        for cat_id, name, icon, count in items_by_category
    ]
    
    return {
        "total_items": total_items,
        "expiring_soon": expiring_soon,
        "expired": expired,
        "by_category": category_stats
    }


@router.get("", response_model=List[StockItemWithCategory])
@router.get("/", response_model=List[StockItemWithCategory])
async def get_stock(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    category_id: Optional[int] = Query(None, description="Filtrer par catégorie"),
    expired_soon: Optional[bool] = Query(None, description="Afficher seulement les produits expirant bientôt (dans 3 jours)"),
    sort_by: Optional[str] = Query("expiry_date", description="Trier par: expiry_date, name, added_at")
):
    """
    Récupérer le stock de l'utilisateur connecté.
    
    Options :
    - Filtrer par catégorie (category_id)
    - Filtrer les produits expirant bientôt (expired_soon=true)
    - Trier par date d'expiration, nom ou date d'ajout
    """
    # Requête de base : tous les items de l'utilisateur
    query = db.query(StockItem).filter(StockItem.user_id == current_user.id)
    
    # Filtrer par catégorie
    if category_id is not None:
        query = query.filter(StockItem.category_id == category_id)
    
    # Filtrer les produits expirant bientôt (dans les 3 prochains jours)
    if expired_soon:
        today = date.today()
        three_days_later = today + timedelta(days=3)
        query = query.filter(
            StockItem.expiry_date.isnot(None),
            StockItem.expiry_date >= today,
            StockItem.expiry_date <= three_days_later
        )
    
    # Trier
    if sort_by == "expiry_date":
        query = query.order_by(
            StockItem.expiry_date.asc().nullslast(),
            StockItem.name.asc()
        )
    elif sort_by == "name":
        query = query.order_by(StockItem.name.asc())
    elif sort_by == "added_at":
        query = query.order_by(StockItem.added_at.desc())
    else:
        # Par défaut : trier par date d'expiration
        query = query.order_by(
            StockItem.expiry_date.asc().nullslast(),
            StockItem.name.asc()
        )
    
    stock_items = query.all()
    
    # Ajouter les informations de catégorie
    result = []
    for item in stock_items:
        item_dict = {
            "id": item.id,
            "user_id": item.user_id,
            "name": item.name,
            "quantity": float(item.quantity),
            "unit": item.unit,
            "category_id": item.category_id,
            "expiry_date": item.expiry_date,
            "added_at": item.added_at,
            "updated_at": item.updated_at,
            "notes": item.notes,
            "category_name": None,
            "category_icon": None
        }
        
        if item.category_id:
            category = db.query(CategoryModel).filter(CategoryModel.id == item.category_id).first()
            if category:
                item_dict["category_name"] = category.name
                item_dict["category_icon"] = category.icon
        
        result.append(StockItemWithCategory(**item_dict))
    
    return result


@router.get("/{item_id}", response_model=StockItemWithCategory)
async def get_stock_item(
    item_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupérer un élément spécifique du stock par son ID.
    """
    stock_item = db.query(StockItem).filter(
        StockItem.id == item_id,
        StockItem.user_id == current_user.id
    ).first()
    
    if not stock_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Élément de stock non trouvé"
        )
    
    # Ajouter les informations de catégorie
    item_dict = {
        "id": stock_item.id,
        "user_id": stock_item.user_id,
        "name": stock_item.name,
        "quantity": float(stock_item.quantity),
        "unit": stock_item.unit,
        "category_id": stock_item.category_id,
        "expiry_date": stock_item.expiry_date,
        "added_at": stock_item.added_at,
        "updated_at": stock_item.updated_at,
        "notes": stock_item.notes,
        "category_name": None,
        "category_icon": None
    }
    
    if stock_item.category_id:
        category = db.query(CategoryModel).filter(CategoryModel.id == stock_item.category_id).first()
        if category:
            item_dict["category_name"] = category.name
            item_dict["category_icon"] = category.icon
    
    return StockItemWithCategory(**item_dict)


@router.post("", response_model=StockItemSchema, status_code=status.HTTP_201_CREATED)
@router.post("/", response_model=StockItemSchema, status_code=status.HTTP_201_CREATED)
async def create_stock_item(
    stock_item_data: StockItemCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Ajouter un nouvel élément au stock.
    
    Validation :
    - Vérification que la catégorie existe (si fournie)
    - Quantité >= 0
    """
    # Vérifier que la catégorie existe si elle est fournie
    if stock_item_data.category_id is not None:
        category = db.query(CategoryModel).filter(CategoryModel.id == stock_item_data.category_id).first()
        if not category:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Catégorie avec l'ID {stock_item_data.category_id} non trouvée"
            )
    
    # Créer l'élément de stock
    db_stock_item = StockItem(
        user_id=current_user.id,
        name=stock_item_data.name,
        quantity=stock_item_data.quantity,
        unit=stock_item_data.unit,
        category_id=stock_item_data.category_id,
        expiry_date=stock_item_data.expiry_date,
        notes=stock_item_data.notes
    )
    
    db.add(db_stock_item)
    db.commit()
    db.refresh(db_stock_item)
    
    return StockItemSchema(
        id=db_stock_item.id,
        user_id=db_stock_item.user_id,
        name=db_stock_item.name,
        quantity=float(db_stock_item.quantity),
        unit=db_stock_item.unit,
        category_id=db_stock_item.category_id,
        expiry_date=db_stock_item.expiry_date,
        added_at=db_stock_item.added_at,
        updated_at=db_stock_item.updated_at,
        notes=db_stock_item.notes
    )


@router.put("/{item_id}", response_model=StockItemSchema)
async def update_stock_item(
    item_id: UUID,
    stock_item_data: StockItemUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Mettre à jour un élément du stock.
    
    Seuls les champs fournis seront mis à jour.
    Vérification que l'élément appartient à l'utilisateur.
    """
    # Récupérer l'élément de stock
    db_stock_item = db.query(StockItem).filter(
        StockItem.id == item_id,
        StockItem.user_id == current_user.id
    ).first()
    
    if not db_stock_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Élément de stock non trouvé"
        )
    
    # Vérifier la catégorie si elle est fournie
    if stock_item_data.category_id is not None:
        category = db.query(CategoryModel).filter(CategoryModel.id == stock_item_data.category_id).first()
        if not category:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Catégorie avec l'ID {stock_item_data.category_id} non trouvée"
            )
    
    # Mettre à jour les champs fournis
    update_data = stock_item_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_stock_item, field, value)
    
    db.commit()
    db.refresh(db_stock_item)
    
    return StockItemSchema(
        id=db_stock_item.id,
        user_id=db_stock_item.user_id,
        name=db_stock_item.name,
        quantity=float(db_stock_item.quantity),
        unit=db_stock_item.unit,
        category_id=db_stock_item.category_id,
        expiry_date=db_stock_item.expiry_date,
        added_at=db_stock_item.added_at,
        updated_at=db_stock_item.updated_at,
        notes=db_stock_item.notes
    )


@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_stock_item(
    item_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Supprimer un élément du stock.
    
    Vérification que l'élément appartient à l'utilisateur.
    """
    db_stock_item = db.query(StockItem).filter(
        StockItem.id == item_id,
        StockItem.user_id == current_user.id
    ).first()
    
    if not db_stock_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Élément de stock non trouvé"
        )
    
    db.delete(db_stock_item)
    db.commit()
    
    return None

