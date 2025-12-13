"""
Schemas Pydantic pour Category
"""
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class CategoryBase(BaseModel):
    """Schéma de base pour Category"""
    name: str = Field(..., min_length=1, max_length=100)
    icon: Optional[str] = Field(None, max_length=50)
    description: Optional[str] = None


class CategoryCreate(CategoryBase):
    """Schéma pour créer une catégorie (admin uniquement)"""
    pass


class CategoryInDB(CategoryBase):
    """Schéma Category en base de données"""
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True


class Category(CategoryInDB):
    """Schéma Category public"""
    
    class Config:
        from_attributes = True

