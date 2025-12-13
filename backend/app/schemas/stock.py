"""
Schemas Pydantic pour StockItem
"""
from pydantic import BaseModel, Field
from typing import Optional
from datetime import date, datetime
from uuid import UUID


class StockItemBase(BaseModel):
    """Schéma de base pour StockItem"""
    name: str = Field(..., min_length=1, max_length=255)
    quantity: float = Field(..., ge=0, description="Quantité (doit être >= 0)")
    unit: str = Field(default="unité", max_length=50)
    category_id: Optional[int] = None
    expiry_date: Optional[date] = None
    notes: Optional[str] = None


class StockItemCreate(StockItemBase):
    """Schéma pour créer un élément de stock"""
    pass


class StockItemUpdate(BaseModel):
    """Schéma pour mettre à jour un élément de stock"""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    quantity: Optional[float] = Field(None, ge=0)
    unit: Optional[str] = Field(None, max_length=50)
    category_id: Optional[int] = None
    expiry_date: Optional[date] = None
    notes: Optional[str] = None


class StockItemInDB(StockItemBase):
    """Schéma StockItem en base de données"""
    id: UUID
    user_id: UUID
    added_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class StockItem(StockItemInDB):
    """Schéma StockItem public"""
    pass


class StockItemWithCategory(StockItem):
    """Schéma StockItem avec informations de catégorie"""
    category_name: Optional[str] = None
    category_icon: Optional[str] = None

