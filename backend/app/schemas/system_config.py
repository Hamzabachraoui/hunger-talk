"""
Schémas pour la configuration système
"""
from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class SystemConfigBase(BaseModel):
    """Schéma de base pour SystemConfig"""
    key: str
    value: str
    description: Optional[str] = None


class SystemConfigCreate(SystemConfigBase):
    """Schéma pour créer une configuration"""
    pass


class SystemConfigUpdate(BaseModel):
    """Schéma pour mettre à jour une configuration"""
    value: str
    description: Optional[str] = None


class SystemConfigResponse(SystemConfigBase):
    """Schéma de réponse pour SystemConfig"""
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class OllamaConfigResponse(BaseModel):
    """Schéma de réponse pour la configuration Ollama"""
    ollama_base_url: str
    ollama_model: str
    updated_at: Optional[datetime] = None

