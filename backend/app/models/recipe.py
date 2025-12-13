"""
Modèles Recipe - Recettes et leurs composants
"""
from sqlalchemy import Column, String, Integer, Text, Boolean, DateTime, func, ForeignKey, CheckConstraint, Numeric
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.models._base import Base
import uuid


class Recipe(Base):
    __tablename__ = "recipes"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False, index=True)
    description = Column(Text)
    preparation_time = Column(Integer)  # en minutes
    cooking_time = Column(Integer)  # en minutes
    total_time = Column(Integer)  # en minutes
    difficulty = Column(String(20))  # Facile, Moyen, Difficile
    servings = Column(Integer, default=4)
    image_url = Column(String(500))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    is_active = Column(Boolean, default=True)
    
    # Contrainte de validation
    __table_args__ = (
        CheckConstraint("difficulty IN ('Facile', 'Moyen', 'Difficile')", name='chk_difficulty'),
    )
    
    # Relations
    ingredients = relationship("RecipeIngredient", back_populates="recipe", cascade="all, delete-orphan", order_by="RecipeIngredient.order_index")
    steps = relationship("RecipeStep", back_populates="recipe", cascade="all, delete-orphan", order_by="RecipeStep.step_number")
    nutrition = relationship("NutritionData", back_populates="recipe", uselist=False, cascade="all, delete-orphan")
    cooking_history = relationship("CookingHistory", back_populates="recipe")
    
    def __repr__(self):
        return f"<Recipe(id={self.id}, name={self.name})>"


class RecipeIngredient(Base):
    __tablename__ = "recipe_ingredients"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    recipe_id = Column(UUID(as_uuid=True), ForeignKey("recipes.id", ondelete="CASCADE"), nullable=False, index=True)
    ingredient_name = Column(String(255), nullable=False, index=True)
    quantity = Column(Numeric(10, 2), nullable=False)
    unit = Column(String(50), nullable=False, default="unité")
    optional = Column(Boolean, default=False)
    order_index = Column(Integer, default=0)
    
    # Relations
    recipe = relationship("Recipe", back_populates="ingredients")
    
    def __repr__(self):
        return f"<RecipeIngredient(id={self.id}, name={self.ingredient_name}, quantity={self.quantity})>"


class RecipeStep(Base):
    __tablename__ = "recipe_steps"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    recipe_id = Column(UUID(as_uuid=True), ForeignKey("recipes.id", ondelete="CASCADE"), nullable=False, index=True)
    step_number = Column(Integer, nullable=False)
    instruction = Column(Text, nullable=False)
    image_url = Column(String(500))
    
    # Relations
    recipe = relationship("Recipe", back_populates="steps")
    
    def __repr__(self):
        return f"<RecipeStep(id={self.id}, recipe_id={self.recipe_id}, step={self.step_number})>"


class NutritionData(Base):
    __tablename__ = "nutrition_data"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    recipe_id = Column(UUID(as_uuid=True), ForeignKey("recipes.id", ondelete="CASCADE"), nullable=False, unique=True, index=True)
    calories = Column(Numeric(10, 2), nullable=False, default=0)
    proteins = Column(Numeric(10, 2), nullable=False, default=0)  # en grammes
    carbohydrates = Column(Numeric(10, 2), nullable=False, default=0)  # en grammes
    fats = Column(Numeric(10, 2), nullable=False, default=0)  # en grammes
    fiber = Column(Numeric(10, 2), default=0)  # en grammes
    sugar = Column(Numeric(10, 2), default=0)  # en grammes
    sodium = Column(Numeric(10, 2), default=0)  # en milligrammes
    per_serving = Column(Boolean, default=True)  # Si les valeurs sont par portion ou totales
    
    # Contraintes de validation
    __table_args__ = (
        CheckConstraint('calories >= 0', name='chk_calories_positive'),
        CheckConstraint('proteins >= 0', name='chk_proteins_positive'),
        CheckConstraint('carbohydrates >= 0', name='chk_carbs_positive'),
        CheckConstraint('fats >= 0', name='chk_fats_positive'),
    )
    
    # Relations
    recipe = relationship("Recipe", back_populates="nutrition")
    
    def __repr__(self):
        return f"<NutritionData(recipe_id={self.recipe_id}, calories={self.calories})>"

