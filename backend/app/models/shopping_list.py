"""
Modèle ShoppingListItem - Liste de courses
"""
from sqlalchemy import Column, String, Numeric, Integer, Boolean, DateTime, func, Text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.models._base import Base
import uuid


class ShoppingListItem(Base):
    __tablename__ = "shopping_list"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    item_name = Column(String(255), nullable=False)
    quantity = Column(Numeric(10, 2), default=1)
    unit = Column(String(50), default="unité")
    category_id = Column(Integer, ForeignKey("categories.id"), index=True)
    is_purchased = Column(Boolean, default=False, index=True)
    added_at = Column(DateTime(timezone=True), server_default=func.now())
    purchased_at = Column(DateTime(timezone=True))
    notes = Column(Text)
    
    # Relations
    user = relationship("User", back_populates="shopping_list")
    category = relationship("Category", back_populates="shopping_items")
    
    def __repr__(self):
        return f"<ShoppingListItem(id={self.id}, item_name={self.item_name}, is_purchased={self.is_purchased})>"

