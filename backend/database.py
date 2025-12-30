"""
Configuration de la base de données - Hunger-Talk
"""
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from config import settings
import os

# Récupérer DATABASE_URL depuis les variables d'environnement ou settings
database_url = os.getenv("DATABASE_URL", settings.DATABASE_URL)

# Si DATABASE_URL est vide, utiliser une valeur par défaut (ne fonctionnera pas mais évitera le crash)
if not database_url or database_url.strip() == "":
    database_url = "postgresql://user:password@localhost:5432/hungertalk_db"

# Créer le moteur SQLAlchemy
engine = create_engine(
    database_url,
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
    try:
        # Importer tous les modèles pour qu'ils soient enregistrés avec Base.metadata
        # Ceci est nécessaire pour que create_all() crée toutes les tables
        from app.models import (
            User, Category, StockItem, Recipe, RecipeIngredient, RecipeStep,
            NutritionData, UserPreferences, ChatMessage, ShoppingListItem,
            Notification, CookingHistory, SystemConfig
        )
        
        # Tester la connexion avant de créer les tables
        from sqlalchemy import text
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
            conn.commit()
        # Créer toutes les tables (tous les modèles doivent être importés avant)
        Base.metadata.create_all(bind=engine)
    except Exception as e:
        # Relancer l'erreur pour qu'elle soit gérée par le startup event
        raise Exception(f"Impossible de se connecter à la base de données: {e}")

