"""
Modèle pour la configuration système (IP Ollama, etc.)
"""
from sqlalchemy import Column, String, DateTime, Boolean
from sqlalchemy.sql import func
from app.models._base import Base


class SystemConfig(Base):
    """Configuration système (IP Ollama, etc.)"""
    
    __tablename__ = "system_config"
    
    # Clé unique pour chaque configuration
    key = Column(String(100), primary_key=True, nullable=False)
    
    # Valeur de la configuration
    value = Column(String(500), nullable=False)
    
    # Description
    description = Column(String(500), nullable=True)
    
    # Métadonnées
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
    
    def __repr__(self):
        return f"<SystemConfig(key={self.key}, value={self.value})>"

