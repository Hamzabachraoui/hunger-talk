"""
Script pour initialiser les catégories de base dans la base de données
"""
import sys
from pathlib import Path

backend_path = Path(__file__).parent.parent
sys.path.insert(0, str(backend_path))

from database import SessionLocal
from app.models.category import Category

# Catégories de base
CATEGORIES = [
    {"name": "Fruits", "icon": "🍎", "description": "Fruits frais et secs"},
    {"name": "Légumes", "icon": "🥕", "description": "Légumes frais et conserves"},
    {"name": "Viande", "icon": "🥩", "description": "Viande, volaille, poisson"},
    {"name": "Produits laitiers", "icon": "🥛", "description": "Lait, fromage, yaourt"},
    {"name": "Céréales", "icon": "🌾", "description": "Pâtes, riz, pain, céréales"},
    {"name": "Épicerie", "icon": "🧂", "description": "Condiments, épices, sauces"},
    {"name": "Surgelés", "icon": "❄️", "description": "Produits surgelés"},
    {"name": "Boissons", "icon": "🥤", "description": "Eau, jus, sodas, alcool"},
    {"name": "Snacks", "icon": "🍫", "description": "Biscuits, chips, bonbons"},
    {"name": "Autres", "icon": "📦", "description": "Autres produits"},
]


def init_categories():
    """Initialiser les catégories dans la base de données"""
    db = SessionLocal()
    try:
        for cat_data in CATEGORIES:
            # Vérifier si la catégorie existe déjà
            existing = db.query(Category).filter(Category.name == cat_data["name"]).first()
            if not existing:
                category = Category(**cat_data)
                db.add(category)
                print(f"✅ Catégorie ajoutée : {cat_data['name']}")
            else:
                print(f"⏭️  Catégorie déjà existante : {cat_data['name']}")
        
        db.commit()
        print("\n✅ Initialisation des catégories terminée !")
    except Exception as e:
        db.rollback()
        print(f"❌ Erreur lors de l'initialisation : {e}")
    finally:
        db.close()


if __name__ == "__main__":
    init_categories()

