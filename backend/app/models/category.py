"""
Modèle Category - Catégories de produits alimentaires
"""
from sqlalchemy import Column, Integer, String, Text, DateTime, func
from sqlalchemy.orm import relationship
from app.models._base import Base


class Category(Base):
    __tablename__ = "categories"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, nullable=False, index=True)
    icon = Column(String(50))
    description = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relations
    stock_items = relationship("StockItem", back_populates="category")
    shopping_items = relationship("ShoppingListItem", back_populates="category")
    
    def __repr__(self):
        return f"<Category(id={self.id}, name={self.name})>"

