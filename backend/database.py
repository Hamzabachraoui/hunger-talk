"""
Configuration de la base de données - Hunger-Talk
"""
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from config import settings

# Créer le moteur SQLAlchemy
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,  # Vérifier la connexion avant utilisation
    echo=settings.DEBUG   # Afficher les requêtes SQL en mode debug
)

# Session locale
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base pour les modèles
Base = declarative_base()


def get_db():
    """
    Dépendance pour obtenir une session de base de données.
    À utiliser avec FastAPI Depends().
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db():
    """
    Initialiser la base de données.
    Crée toutes les tables définies dans les modèles.
    """
    Base.metadata.create_all(bind=engine)

