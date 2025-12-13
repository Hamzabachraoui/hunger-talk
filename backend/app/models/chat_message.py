"""
Modèle ChatMessage - Messages de chat avec l'IA
"""
from sqlalchemy import Column, String, Text, DateTime, func, Integer, ForeignKey, ARRAY, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.models._base import Base
import uuid


class ChatMessage(Base):
    __tablename__ = "chat_messages"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    message = Column(Text, nullable=False)
    response = Column(Text)
    context_used = Column(Text)  # Contexte RAG utilisé (JSON)
    recipes_suggested = Column(ARRAY(UUID(as_uuid=True)))  # IDs des recettes suggérées
    timestamp = Column(DateTime(timezone=True), server_default=func.now(), index=True)
    model_used = Column(String(100), default="llama3.1:8b")
    response_time_ms = Column(Integer)  # Temps de réponse en millisecondes
    
    # Index composite
    __table_args__ = (
        Index('idx_chat_messages_user_timestamp', 'user_id', 'timestamp'),
    )
    
    # Relations
    user = relationship("User", back_populates="chat_messages")
    
    def __repr__(self):
        return f"<ChatMessage(id={self.id}, user_id={self.user_id}, timestamp={self.timestamp})>"

