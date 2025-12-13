"""
Script d'initialisation complète de la base de données
À exécuter après les migrations pour initialiser les données de base
"""
import sys
from pathlib import Path

backend_path = Path(__file__).parent.parent
sys.path.insert(0, str(backend_path))

from database import SessionLocal
from app.models.category import Category
from app.models.recipe import Recipe
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def init_database():
    """
    Initialise toutes les données de base nécessaires :
    - Catégories
    - Recettes d'exemple
    """
    print("\n" + "="*70)
    print("  INITIALISATION DE LA BASE DE DONNÉES")
    print("="*70 + "\n")
    
    # 1. Initialiser les catégories
    print("1. Initialisation des catégories...")
    try:
        from scripts.init_categories import init_categories
        init_categories()
        print("   ✅ Catégories initialisées\n")
    except Exception as e:
        logger.error(f"Erreur lors de l'initialisation des catégories: {e}")
        print(f"   ❌ Erreur: {e}\n")
    
    # 2. Vérifier si des recettes existent déjà
    db = SessionLocal()
    try:
        existing_recipes = db.query(Recipe).filter(Recipe.is_active == True).count()
        if existing_recipes == 0:
            print("2. Ajout des recettes d'exemple...")
            try:
                from scripts.add_sample_recipes import add_sample_recipes
                add_sample_recipes()
                print("   ✅ Recettes d'exemple ajoutées\n")
            except Exception as e:
                logger.error(f"Erreur lors de l'ajout des recettes: {e}")
                print(f"   ❌ Erreur: {e}\n")
        else:
            print(f"2. ⏭️  {existing_recipes} recette(s) déjà présente(s), pas d'ajout nécessaire\n")
    finally:
        db.close()
    
    print("="*70)
    print("✅ INITIALISATION TERMINÉE")
    print("="*70 + "\n")

if __name__ == "__main__":
    init_database()

