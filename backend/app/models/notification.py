"""
Modèle Notification - Notifications pour les utilisateurs
"""
from sqlalchemy import Column, String, Text, Boolean, DateTime, func, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.models._base import Base
import uuid


class Notification(Base):
    __tablename__ = "notifications"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    type = Column(String(50), nullable=False)  # 'expiry', 'recipe_suggestion', 'nutrition_reminder', etc.
    title = Column(String(255), nullable=False)
    message = Column(Text, nullable=False)
    is_read = Column(Boolean, default=False, index=True)
    related_item_id = Column(UUID(as_uuid=True))  # ID de l'item lié (stock_item, recipe, etc.)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)
    read_at = Column(DateTime(timezone=True))
    
    # Relations
    user = relationship("User", back_populates="notifications")
    
    def __repr__(self):
        return f"<Notification(id={self.id}, type={self.type}, is_read={self.is_read})>"

