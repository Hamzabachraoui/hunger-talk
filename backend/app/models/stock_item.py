"""
Modèle StockItem - Éléments du stock alimentaire
"""
from sqlalchemy import Column, String, Numeric, Integer, Date, Text, DateTime, func, ForeignKey, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.models._base import Base
import uuid


class StockItem(Base):
    __tablename__ = "stock_items"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(String(255), nullable=False)
    quantity = Column(Numeric(10, 2), nullable=False, default=0)
    unit = Column(String(50), nullable=False, default="unité")
    category_id = Column(Integer, ForeignKey("categories.id"), index=True)
    expiry_date = Column(Date, index=True)
    added_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    notes = Column(Text)
    
    # Contrainte de validation
    __table_args__ = (
        CheckConstraint('quantity >= 0', name='chk_quantity_positive'),
    )
    
    # Relations
    user = relationship("User", back_populates="stock_items")
    category = relationship("Category", back_populates="stock_items")
    
    def __repr__(self):
        return f"<StockItem(id={self.id}, name={self.name}, quantity={self.quantity})>"

