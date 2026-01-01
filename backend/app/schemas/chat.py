"""
Schemas Pydantic pour le chat avec l'IA
"""
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from uuid import UUID


class ChatMessageCreate(BaseModel):
    """Schéma pour créer un message de chat"""
    message: str = Field(..., min_length=1, max_length=2000)


class ChatMessageResponse(BaseModel):
    """Schéma pour la réponse du chat"""
    id: UUID
    user_id: UUID
    message: str
    response: str
    timestamp: datetime
    ai_model: Optional[str] = None  # Renommé pour éviter le conflit
    response_time_ms: Optional[int] = None
    
    class Config:
        from_attributes = True
        protected_namespaces = ()


class ChatMessageSimple(BaseModel):
    """Schéma simplifié pour la réponse"""
    response: str
    ai_model: Optional[str] = None  # Renommé pour éviter le conflit avec "model"
    response_time_ms: Optional[int] = None
    
    class Config:
        protected_namespaces = ()


class ChatMessageSave(BaseModel):
    """Schéma pour sauvegarder un message déjà traité (pour architecture hybride)"""
    message: str = Field(..., min_length=1, max_length=2000)
    response: str
    ai_model: Optional[str] = None
    response_time_ms: Optional[int] = None
