"""
Routes pour la configuration système (IP Ollama, etc.)
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import select
from typing import List

from database import get_db
from app.models.system_config import SystemConfig
from app.schemas.system_config import (
    SystemConfigCreate,
    SystemConfigUpdate,
    SystemConfigResponse,
    OllamaConfigResponse
)
from app.core.dependencies import get_current_user
from app.models.user import User

router = APIRouter(prefix="/api/system-config", tags=["system-config"])

# Clé pour la configuration Ollama
OLLAMA_BASE_URL_KEY = "ollama_base_url"
OLLAMA_MODEL_KEY = "ollama_model"


@router.get("/ollama", response_model=OllamaConfigResponse, summary="Récupérer la configuration Ollama")
async def get_ollama_config(db: Session = Depends(get_db)):
    """
    Récupère la configuration Ollama depuis la base de données.
    Utilisé par l'application mobile pour obtenir l'adresse IP du modèle.
    """
    # Récupérer l'URL de base Ollama
    stmt_url = select(SystemConfig).where(SystemConfig.key == OLLAMA_BASE_URL_KEY)
    config_url = db.execute(stmt_url).scalar_one_or_none()
    
    # Récupérer le modèle
    stmt_model = select(SystemConfig).where(SystemConfig.key == OLLAMA_MODEL_KEY)
    config_model = db.execute(stmt_model).scalar_one_or_none()
    
    # Valeurs par défaut
    base_url = config_url.value if config_url else "http://localhost:11434"
    model = config_model.value if config_model else "llama3.1:8b"
    updated_at = config_url.updated_at if config_url else None
    
    return OllamaConfigResponse(
        ollama_base_url=base_url,
        ollama_model=model,
        updated_at=updated_at
    )


@router.put("/ollama/base-url", response_model=SystemConfigResponse, summary="Mettre à jour l'URL Ollama")
async def update_ollama_base_url(
    value: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Met à jour l'URL de base Ollama dans la base de données.
    Appelé par un service local pour enregistrer l'IP locale automatiquement.
    
    Note: Pour la sécurité, on pourrait ajouter une authentification spéciale
    (token API) pour ce endpoint, mais pour l'instant on utilise l'auth normale.
    """
    # Vérifier que l'URL est valide (format basique)
    if not value or not value.startswith(("http://", "https://")):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="URL invalide. Doit commencer par http:// ou https://"
        )
    
    # Récupérer ou créer la configuration
    stmt = select(SystemConfig).where(SystemConfig.key == OLLAMA_BASE_URL_KEY)
    config = db.execute(stmt).scalar_one_or_none()
    
    if config:
        # Mettre à jour
        config.value = value
    else:
        # Créer
        config = SystemConfig(
            key=OLLAMA_BASE_URL_KEY,
            value=value,
            description="Adresse IP/URL de base pour Ollama (détectée automatiquement)"
        )
        db.add(config)
    
    db.commit()
    db.refresh(config)
    
    return config


@router.get("/{key}", response_model=SystemConfigResponse, summary="Récupérer une configuration")
async def get_config(key: str, db: Session = Depends(get_db)):
    """Récupère une configuration par sa clé"""
    stmt = select(SystemConfig).where(SystemConfig.key == key)
    config = db.execute(stmt).scalar_one_or_none()
    
    if not config:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Configuration '{key}' non trouvée"
        )
    
    return config


@router.get("", response_model=List[SystemConfigResponse], summary="Récupérer toutes les configurations")
async def get_all_configs(db: Session = Depends(get_db)):
    """Récupère toutes les configurations système"""
    stmt = select(SystemConfig)
    configs = db.execute(stmt).scalars().all()
    return configs

