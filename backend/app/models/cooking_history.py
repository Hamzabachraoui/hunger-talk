"""
Modèle CookingHistory - Historique des recettes cuisinées
"""
from sqlalchemy import Column, String, Integer, Text, DateTime, func, ForeignKey, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.models._base import Base
import uuid


class CookingHistory(Base):
    __tablename__ = "cooking_history"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    recipe_id = Column(UUID(as_uuid=True), ForeignKey("recipes.id", ondelete="CASCADE"), nullable=False, index=True)
    cooked_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)
    servings_made = Column(Integer)
    rating = Column(Integer)  # 1-5
    notes = Column(Text)
    
    # Contrainte
    __table_args__ = (
        CheckConstraint('rating IS NULL OR (rating >= 1 AND rating <= 5)', name='chk_rating_range'),
    )
    
    # Relations
    user = relationship("User", back_populates="cooking_history")
    recipe = relationship("Recipe", back_populates="cooking_history")
    
    def __repr__(self):
        return f"<CookingHistory(id={self.id}, user_id={self.user_id}, recipe_id={self.recipe_id})>"

