"""
Script pour ajouter des recettes d'exemple dans la base de données
"""
import sys
from pathlib import Path
from decimal import Decimal

backend_path = Path(__file__).parent.parent
sys.path.insert(0, str(backend_path))

from database import SessionLocal
from app.models.recipe import Recipe, RecipeIngredient, RecipeStep, NutritionData
import uuid

# Recettes d'exemple
SAMPLE_RECIPES = [
    {
        "name": "Salade de tomates",
        "description": "Une salade fraîche et simple avec des tomates",
        "preparation_time": 10,
        "cooking_time": 0,
        "total_time": 10,
        "difficulty": "Facile",
        "servings": 2,
        "ingredients": [
            {"name": "Tomates", "quantity": 4, "unit": "unité"},
            {"name": "Huile d'olive", "quantity": 2, "unit": "cuillère à soupe"},
            {"name": "Vinaigre", "quantity": 1, "unit": "cuillère à soupe"},
            {"name": "Sel", "quantity": 1, "unit": "pincée"},
        ],
        "steps": [
            {"number": 1, "instruction": "Laver et couper les tomates en rondelles"},
            {"number": 2, "instruction": "Disposer les tomates dans un plat"},
            {"number": 3, "instruction": "Arroser d'huile d'olive et de vinaigre"},
            {"number": 4, "instruction": "Saler et servir frais"},
        ],
        "nutrition": {
            "calories": 80,
            "proteins": 2,
            "carbohydrates": 8,
            "fats": 5
        }
    },
    {
        "name": "Omelette aux légumes",
        "description": "Omelette simple avec des légumes",
        "preparation_time": 5,
        "cooking_time": 5,
        "total_time": 10,
        "difficulty": "Facile",
        "servings": 2,
        "ingredients": [
            {"name": "Œufs", "quantity": 4, "unit": "unité"},
            {"name": "Tomates", "quantity": 2, "unit": "unité"},
            {"name": "Beurre", "quantity": 20, "unit": "g"},
            {"name": "Sel", "quantity": 1, "unit": "pincée"},
        ],
        "steps": [
            {"number": 1, "instruction": "Battre les œufs dans un bol"},
            {"number": 2, "instruction": "Couper les tomates en petits morceaux"},
            {"number": 3, "instruction": "Faire chauffer le beurre dans une poêle"},
            {"number": 4, "instruction": "Verser les œufs et ajouter les tomates"},
            {"number": 5, "instruction": "Cuire 3-4 minutes de chaque côté"},
        ],
        "nutrition": {
            "calories": 250,
            "proteins": 15,
            "carbohydrates": 5,
            "fats": 18
        }
    },
    {
        "name": "Pâtes à la tomate",
        "description": "Pâtes simples avec une sauce tomate",
        "preparation_time": 10,
        "cooking_time": 15,
        "total_time": 25,
        "difficulty": "Facile",
        "servings": 4,
        "ingredients": [
            {"name": "Pâtes", "quantity": 400, "unit": "g"},
            {"name": "Tomates", "quantity": 6, "unit": "unité"},
            {"name": "Ail", "quantity": 2, "unit": "gousse"},
            {"name": "Huile d'olive", "quantity": 3, "unit": "cuillère à soupe"},
            {"name": "Sel", "quantity": 1, "unit": "pincée"},
        ],
        "steps": [
            {"number": 1, "instruction": "Faire bouillir de l'eau salée pour les pâtes"},
            {"number": 2, "instruction": "Couper les tomates en dés"},
            {"number": 3, "instruction": "Faire revenir l'ail dans l'huile d'olive"},
            {"number": 4, "instruction": "Ajouter les tomates et laisser mijoter 10 minutes"},
            {"number": 5, "instruction": "Cuire les pâtes selon les instructions"},
            {"number": 6, "instruction": "Mélanger les pâtes avec la sauce et servir"},
        ],
        "nutrition": {
            "calories": 350,
            "proteins": 12,
            "carbohydrates": 65,
            "fats": 8
        }
    }
]

def add_sample_recipes():
    """Ajouter les recettes d'exemple"""
    db = SessionLocal()
    try:
        print("=" * 60)
        print("  AJOUT DE RECETTES D'EXEMPLE")
        print("=" * 60)
        print()
        
        for recipe_data in SAMPLE_RECIPES:
            # Vérifier si la recette existe déjà
            existing = db.query(Recipe).filter(Recipe.name == recipe_data["name"]).first()
            if existing:
                print(f"⏭️  Recette déjà existante : {recipe_data['name']}")
                continue
            
            # Créer la recette
            recipe = Recipe(
                id=uuid.uuid4(),
                name=recipe_data["name"],
                description=recipe_data["description"],
                preparation_time=recipe_data["preparation_time"],
                cooking_time=recipe_data["cooking_time"],
                total_time=recipe_data["total_time"],
                difficulty=recipe_data["difficulty"],
                servings=recipe_data["servings"],
                is_active=True
            )
            db.add(recipe)
            db.flush()  # Pour obtenir l'ID
            
            # Ajouter les ingrédients
            for idx, ing_data in enumerate(recipe_data["ingredients"]):
                ingredient = RecipeIngredient(
                    id=uuid.uuid4(),
                    recipe_id=recipe.id,
                    ingredient_name=ing_data["name"],
                    quantity=Decimal(str(ing_data["quantity"])),
                    unit=ing_data["unit"],
                    order_index=idx
                )
                db.add(ingredient)
            
            # Ajouter les étapes
            for step_data in recipe_data["steps"]:
                step = RecipeStep(
                    id=uuid.uuid4(),
                    recipe_id=recipe.id,
                    step_number=step_data["number"],
                    instruction=step_data["instruction"]
                )
                db.add(step)
            
            # Ajouter les données nutritionnelles
            nutrition = NutritionData(
                id=uuid.uuid4(),
                recipe_id=recipe.id,
                calories=Decimal(str(recipe_data["nutrition"]["calories"])),
                proteins=Decimal(str(recipe_data["nutrition"]["proteins"])),
                carbohydrates=Decimal(str(recipe_data["nutrition"]["carbohydrates"])),
                fats=Decimal(str(recipe_data["nutrition"]["fats"])),
                per_serving=True
            )
            db.add(nutrition)
            
            print(f"✅ Recette ajoutée : {recipe_data['name']}")
            print(f"   - {len(recipe_data['ingredients'])} ingrédients")
            print(f"   - {len(recipe_data['steps'])} étapes")
            print(f"   - {recipe_data['nutrition']['calories']} kcal/portion")
        
        db.commit()
        print()
        print("=" * 60)
        print("✅ RECETTES AJOUTÉES AVEC SUCCÈS !")
        print("=" * 60)
        
        # Afficher le nombre total de recettes
        total = db.query(Recipe).filter(Recipe.is_active == True).count()
        print(f"\n📊 Total de recettes actives : {total}")
        
    except Exception as e:
        db.rollback()
        print(f"\n❌ Erreur : {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    add_sample_recipes()

