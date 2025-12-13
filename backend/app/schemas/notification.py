"""
Schemas Pydantic pour les notifications
"""
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from uuid import UUID


class NotificationBase(BaseModel):
    """Schéma de base pour une notification"""
    type: str
    title: str
    message: str


class NotificationCreate(NotificationBase):
    """Schéma pour créer une notification"""
    related_item_id: Optional[UUID] = None


class NotificationResponse(BaseModel):
    """Schéma de réponse pour une notification"""
    id: UUID
    user_id: UUID
    type: str
    title: str
    message: str
    is_read: bool
    related_item_id: Optional[UUID] = None
    created_at: datetime
    read_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True


class NotificationSummary(BaseModel):
    """Résumé des notifications"""
    total: int
    unread: int
    notifications: list[NotificationResponse]

