"""
Configuration de l'environnement Alembic
"""
from logging.config import fileConfig
from sqlalchemy import engine_from_config
from sqlalchemy import pool
from alembic import context
import sys
from pathlib import Path

# Ajouter le chemin backend au sys.path
backend_path = Path(__file__).parent.parent
sys.path.insert(0, str(backend_path))

# Importer la configuration et les modèles
from config import settings
from database import Base

# Importer tous les modèles pour qu'Alembic les détecte
from app.models.user import User
from app.models.category import Category
from app.models.stock_item import StockItem
from app.models.recipe import Recipe, RecipeIngredient, RecipeStep, NutritionData
from app.models.user_preferences import UserPreferences
from app.models.chat_message import ChatMessage
from app.models.shopping_list import ShoppingListItem
from app.models.notification import Notification
from app.models.cooking_history import CookingHistory
from app.models.system_config import SystemConfig

# this is the Alembic Config object
config = context.config

# Interpréter le fichier de configuration pour le logging
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Définir l'URL de la base de données depuis les settings
config.set_main_option("sqlalchemy.url", settings.DATABASE_URL)

# target_metadata pour la détection automatique
target_metadata = Base.metadata


def run_migrations_offline() -> None:
    """Exécuter les migrations en mode 'offline'."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """Exécuter les migrations en mode 'online'."""
    # Utiliser l'URL de la base de données depuis les settings
    configuration = config.get_section(config.config_ini_section, {})
    configuration["sqlalchemy.url"] = settings.DATABASE_URL
    
    connectable = engine_from_config(
        configuration,
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection, 
            target_metadata=target_metadata,
            compare_type=True,
            compare_server_default=True
        )

        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
