"""
Configuration de l'application - Hunger-Talk
"""
from pydantic_settings import BaseSettings
from pydantic import field_validator
from typing import List, Union


class Settings(BaseSettings):
    """Paramètres de configuration de l'application"""
    
    # Application
    APP_NAME: str = "Hunger-Talk API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True
    ENVIRONMENT: str = "development"
    
    # Base de données
    DATABASE_URL: str = "postgresql://user:password@localhost:5432/hungertalk_db"
    
    # JWT
    SECRET_KEY: str = "change-me-in-production-79juEwjfulVuZskpnmtZM4pMrGe5LENNDhckNb60MHM"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # Ollama (IA)
    OLLAMA_BASE_URL: str = "http://localhost:11434"
    OLLAMA_MODEL: str = "llama3.1:8b"
    
    # CORS
    ALLOWED_ORIGINS: Union[str, List[str]] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://localhost:8000",
        "*"  # Permet toutes les origines en production (à restreindre si nécessaire)
    ]
    
    @field_validator('ALLOWED_ORIGINS', mode='before')
    @classmethod
    def parse_allowed_origins(cls, v):
        """Parser ALLOWED_ORIGINS depuis une chaîne séparée par des virgules"""
        if isinstance(v, str):
            return [origin.strip() for origin in v.split(',') if origin.strip()]
        return v
    
    # OpenFoodFacts (optionnel)
    OPENFOODFACTS_API_URL: str = "https://world.openfoodfacts.org/api/v0"
    
    class Config:
        env_file = ".env"
        case_sensitive = True


# Instance globale des settings
settings = Settings()

