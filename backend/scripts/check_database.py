"""
Script pour vérifier quelle base de données est utilisée et son état
"""
import sys
from pathlib import Path
import os

backend_path = Path(__file__).parent.parent
sys.path.insert(0, str(backend_path))

from config import settings
from database import SessionLocal
from app.models.category import Category
from app.models.recipe import Recipe
from app.models.stock_item import StockItem
from app.models.user import User

def check_database():
    """Affiche des informations sur la base de données utilisée"""
    print("\n" + "="*70)
    print("  VÉRIFICATION DE LA BASE DE DONNÉES")
    print("="*70 + "\n")
    
    # Afficher l'URL de la base de données (masquer le mot de passe)
    db_url = settings.DATABASE_URL
    if "@" in db_url:
        # Masquer le mot de passe
        parts = db_url.split("@")
        if len(parts) == 2:
            user_pass = parts[0].split("://")[1] if "://" in parts[0] else parts[0]
            if ":" in user_pass:
                user = user_pass.split(":")[0]
                db_url_display = db_url.replace(user_pass, f"{user}:***")
            else:
                db_url_display = db_url
        else:
            db_url_display = db_url
    else:
        db_url_display = db_url
    
    print(f"📍 URL de la base de données: {db_url_display}")
    
    # Détecter si on est dans Docker ou en local
    is_docker = os.path.exists("/.dockerenv") or os.environ.get("DOCKER_CONTAINER") == "true"
    environment = "🐳 Docker" if is_docker else "💻 Local"
    print(f"🌍 Environnement: {environment}")
    
    # Vérifier la connexion
    print("\n📊 État de la base de données:")
    db = SessionLocal()
    try:
        # Compter les enregistrements
        categories_count = db.query(Category).count()
        recipes_count = db.query(Recipe).filter(Recipe.is_active == True).count()
        users_count = db.query(User).count()
        stock_items_count = db.query(StockItem).count()
        
        print(f"   ✅ Connexion réussie")
        print(f"   📦 Catégories: {categories_count}")
        print(f"   🍳 Recettes actives: {recipes_count}")
        print(f"   👥 Utilisateurs: {users_count}")
        print(f"   📦 Articles en stock: {stock_items_count}")
        
        # Avertissements
        if categories_count == 0:
            print("\n   ⚠️  Aucune catégorie trouvée. Exécutez: python scripts/init_categories.py")
        if recipes_count == 0:
            print("\n   ⚠️  Aucune recette trouvée. Exécutez: python scripts/add_sample_recipes.py")
        
    except Exception as e:
        print(f"   ❌ Erreur de connexion: {e}")
    finally:
        db.close()
    
    print("\n" + "="*70 + "\n")

if __name__ == "__main__":
    check_database()

