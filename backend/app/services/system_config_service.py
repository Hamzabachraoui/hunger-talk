"""
Service pour gérer la configuration système (IP Ollama, etc.)
"""
from sqlalchemy.orm import Session
from sqlalchemy import select
from typing import Optional
from app.models.system_config import SystemConfig

OLLAMA_BASE_URL_KEY = "ollama_base_url"
OLLAMA_MODEL_KEY = "ollama_model"


def get_ollama_base_url(db: Session) -> str:
    """
    Récupère l'URL de base Ollama depuis la base de données.
    Retourne la valeur par défaut si non configurée.
    """
    stmt = select(SystemConfig).where(SystemConfig.key == OLLAMA_BASE_URL_KEY)
    config = db.execute(stmt).scalar_one_or_none()
    
    if config and config.value:
        return config.value
    
    # Valeur par défaut
    return "http://localhost:11434"


def set_ollama_base_url(db: Session, url: str) -> SystemConfig:
    """
    Définit l'URL de base Ollama dans la base de données.
    Crée la configuration si elle n'existe pas.
    """
    stmt = select(SystemConfig).where(SystemConfig.key == OLLAMA_BASE_URL_KEY)
    config = db.execute(stmt).scalar_one_or_none()
    
    if config:
        config.value = url
    else:
        config = SystemConfig(
            key=OLLAMA_BASE_URL_KEY,
            value=url,
            description="Adresse IP/URL de base pour Ollama (détectée automatiquement)"
        )
        db.add(config)
    
    db.commit()
    db.refresh(config)
    return config


def get_ollama_model(db: Session) -> str:
    """Récupère le modèle Ollama depuis la base de données"""
    stmt = select(SystemConfig).where(SystemConfig.key == OLLAMA_MODEL_KEY)
    config = db.execute(stmt).scalar_one_or_none()
    
    if config and config.value:
        return config.value
    
    # Valeur par défaut
    return "llama3.1:8b"

