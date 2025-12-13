"""
Script pour créer les catégories directement
"""
from database import SessionLocal
from app.models.category import Category

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

db = SessionLocal()
try:
    # Supprimer toutes les catégories existantes
    db.query(Category).delete()
    db.commit()
    print("Anciennes catégories supprimées")
    
    # Créer les nouvelles catégories
    for cat_data in CATEGORIES:
        category = Category(**cat_data)
        db.add(category)
        print(f"✅ Catégorie ajoutée : {cat_data['name']}")
    
    db.commit()
    print("\n✅ Toutes les catégories créées !")
    
    # Vérifier
    count = db.query(Category).count()
    print(f"Nombre de catégories dans la base : {count}")
    
    # Afficher les IDs
    categories = db.query(Category).all()
    for cat in categories:
        print(f"  - ID {cat.id}: {cat.name}")
        
except Exception as e:
    db.rollback()
    print(f"❌ Erreur : {e}")
    import traceback
    traceback.print_exc()
finally:
    db.close()

