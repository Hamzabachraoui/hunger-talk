"""
Script pour créer toutes les tables de la base de données
⚠️  NOTE: Ce script utilise Base.metadata.create_all()
     Pour une approche plus standard, utilisez Alembic migrations :
     - alembic revision --autogenerate -m "Initial migration"
     - alembic upgrade head
"""
import sys
from pathlib import Path

backend_path = Path(__file__).parent.parent
sys.path.insert(0, str(backend_path))

print("=" * 50)
print("Création de la base de données Hunger-Talk")
print("=" * 50)
print()

try:
    print("📦 Import des modules...")
    from database import init_db, engine
    from app.models.user import User
    from app.models.category import Category
    from app.models.stock_item import StockItem
    from app.models.recipe import Recipe, RecipeIngredient, RecipeStep, NutritionData
    from app.models.user_preferences import UserPreferences
    from app.models.chat_message import ChatMessage
    from app.models.shopping_list import ShoppingListItem
    from app.models.notification import Notification
    from app.models.cooking_history import CookingHistory
    print("✅ Modules importés")
    print()
    
    print("🔄 Test de connexion à la base de données...")
    from sqlalchemy import text
    with engine.connect() as conn:
        result = conn.execute(text("SELECT version()"))
        version = result.fetchone()[0]
        print(f"✅ Connecté à PostgreSQL : {version[:50]}...")
    print()
    
    print("🔄 Création des tables...")
    
    # Créer les tables
    init_db()
    
    print("✅ Toutes les tables ont été créées avec succès !")
    print()
    
    # Vérifier que les tables existent
    from sqlalchemy import inspect
    inspector = inspect(engine)
    tables = inspector.get_table_names()
    
    print(f"📋 Tables créées ({len(tables)}) :")
    for table in sorted(tables):
        # Obtenir le nombre de colonnes
        columns = inspector.get_columns(table)
        print(f"  ✓ {table:30s} ({len(columns)} colonnes)")
    
    print()
    print("=" * 50)
    print("✅ Base de données initialisée avec succès !")
    print("=" * 50)
    
except Exception as e:
    print()
    print("=" * 50)
    print(f"❌ ERREUR : {e}")
    print("=" * 50)
    import traceback
    traceback.print_exc()
    sys.exit(1)
