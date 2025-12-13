"""
Modèle UserPreferences - Préférences utilisateur
"""
from sqlalchemy import Column, String, Numeric, Integer, DateTime, func, ForeignKey, CheckConstraint, ARRAY
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.models._base import Base
import uuid


class UserPreferences(Base):
    __tablename__ = "user_preferences"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True, index=True)
    
    # Restrictions alimentaires (array)
    dietary_restrictions = Column(ARRAY(String))
    
    # Allergies (array)
    allergies = Column(ARRAY(String))
    
    # Objectifs nutritionnels
    daily_calorie_goal = Column(Numeric(10, 2))
    daily_protein_goal = Column(Numeric(10, 2))  # en grammes
    daily_carb_goal = Column(Numeric(10, 2))  # en grammes
    daily_fat_goal = Column(Numeric(10, 2))  # en grammes
    
    # Préférences de cuisine
    preferred_cuisines = Column(ARRAY(String))
    disliked_ingredients = Column(ARRAY(String))
    
    # Préférences de temps
    max_prep_time = Column(Integer)  # en minutes
    max_cooking_time = Column(Integer)  # en minutes
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Contrainte
    __table_args__ = (
        CheckConstraint('daily_calorie_goal IS NULL OR daily_calorie_goal > 0', name='chk_calorie_goal_positive'),
    )
    
    # Relations
    user = relationship("User", back_populates="preferences")
    
    def __repr__(self):
        return f"<UserPreferences(user_id={self.user_id})>"

