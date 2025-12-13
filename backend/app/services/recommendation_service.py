"""
Service de recommandations de recettes
"""
from sqlalchemy.orm import Session
from typing import List, Dict, Any, Optional
from uuid import UUID
from decimal import Decimal
from datetime import date, timedelta

from app.models.recipe import Recipe, RecipeIngredient, NutritionData
from app.models.stock_item import StockItem
from app.models.user_preferences import UserPreferences
from app.models.cooking_history import CookingHistory


class RecommendationService:
    """Service pour générer des recommandations de recettes personnalisées"""
    
    def __init__(self, db: Session, user_id: UUID):
        self.db = db
        self.user_id = user_id
    
    def calculate_ingredient_match_score(
        self, 
        recipe: Recipe, 
        stock_items: List[StockItem]
    ) -> Dict[str, Any]:
        """
        Calcule un score de compatibilité détaillé entre une recette et le stock.
        
        Returns:
            dict avec:
            - match_score: score global (0.0-1.0)
            - available_ingredients: nombre d'ingrédients disponibles
            - missing_ingredients: liste des ingrédients manquants
            - partial_matches: ingrédients partiellement disponibles
            - can_cook: bool si tous les ingrédients sont disponibles
        """
        # Récupérer les ingrédients de la recette (non optionnels)
        ingredients = self.db.query(RecipeIngredient).filter(
            RecipeIngredient.recipe_id == recipe.id,
            RecipeIngredient.optional == False
        ).all()
        
        if not ingredients:
            return {
                "match_score": 0.0,
                "available_ingredients": 0,
                "total_ingredients": 0,
                "missing_ingredients": [],
                "partial_matches": [],
                "can_cook": False
            }
        
        # Créer un dictionnaire du stock (nom normalisé en minuscules)
        stock_dict = {}
        for item in stock_items:
            name_lower = item.name.lower().strip()
            stock_dict[name_lower] = {
                "item": item,
                "quantity": float(item.quantity),
                "unit": item.unit or ""
            }
        
        available_count = 0
        missing_ingredients = []
        partial_matches = []
        
        for ingredient in ingredients:
            ingredient_name_lower = ingredient.ingredient_name.lower().strip()
            required_qty = float(ingredient.quantity)
            found = False
            
            # Chercher une correspondance exacte ou partielle
            for stock_name, stock_data in stock_dict.items():
                # Correspondance exacte ou partielle
                if (ingredient_name_lower in stock_name or 
                    stock_name in ingredient_name_lower or
                    self._ingredient_similarity(ingredient_name_lower, stock_name) > 0.7):
                    
                    # Vérifier l'unité (simplifié - peut être amélioré)
                    units_match = self._units_compatible(ingredient.unit, stock_data["unit"])
                    
                    if units_match:
                        available_qty = stock_data["quantity"]
                        
                        if available_qty >= required_qty:
                            # Ingredient complètement disponible
                            available_count += 1
                            found = True
                            break
                        elif available_qty > 0:
                            # Ingredient partiellement disponible
                            partial_matches.append({
                                "name": ingredient.ingredient_name,
                                "required": required_qty,
                                "available": available_qty,
                                "unit": ingredient.unit
                            })
                            found = True
                            break
            
            if not found:
                missing_ingredients.append({
                    "name": ingredient.ingredient_name,
                    "quantity": required_qty,
                    "unit": ingredient.unit
                })
        
        total_required = len(ingredients)
        match_score = available_count / total_required if total_required > 0 else 0.0
        
        # Bonus pour les correspondances partielles (score réduit)
        if partial_matches:
            partial_bonus = len(partial_matches) * 0.2 / total_required
            match_score = min(1.0, match_score + partial_bonus)
        
        return {
            "match_score": match_score,
            "available_ingredients": available_count,
            "total_ingredients": total_required,
            "missing_ingredients": missing_ingredients,
            "partial_matches": partial_matches,
            "can_cook": len(missing_ingredients) == 0
        }
    
    def _ingredient_similarity(self, name1: str, name2: str) -> float:
        """Calcule une similarité simple entre deux noms d'ingrédients"""
        # Correspondance exacte
        if name1 == name2:
            return 1.0
        
        # Un nom contient l'autre
        if name1 in name2 or name2 in name1:
            return 0.8
        
        # Mots communs
        words1 = set(name1.split())
        words2 = set(name2.split())
        if words1 and words2:
            common = words1.intersection(words2)
            if common:
                return len(common) / max(len(words1), len(words2))
        
        return 0.0
    
    def _units_compatible(self, unit1: str, unit2: str) -> bool:
        """Vérifie si deux unités sont compatibles"""
        if not unit1 or not unit2:
            return True  # Si une unité n'est pas spécifiée, on accepte
        
        unit1_lower = unit1.lower().strip()
        unit2_lower = unit2.lower().strip()
        
        # Correspondance exacte
        if unit1_lower == unit2_lower:
            return True
        
        # Groupes d'unités compatibles
        compatible_groups = [
            {"unité", "unités", "unite", "unites", "pièce", "pièces", "pce"},
            {"g", "gramme", "grammes", "kg", "kilogramme"},
            {"ml", "millilitre", "millilitres", "l", "litre", "litres", "cl"},
            {"cuillère à soupe", "c. à s.", "càs", "tbsp"},
            {"cuillère à café", "c. à c.", "càc", "tsp"},
        ]
        
        for group in compatible_groups:
            if unit1_lower in group and unit2_lower in group:
                return True
        
        return False
    
    def filter_by_preferences(
        self, 
        recipe: Recipe, 
        preferences: Optional[UserPreferences]
    ) -> Dict[str, Any]:
        """
        Filtre une recette selon les préférences utilisateur.
        
        Returns:
            dict avec:
            - passed: bool si la recette passe les filtres
            - reasons: liste des raisons de filtrage
            - score_adjustment: ajustement du score (-1.0 à 0.0)
        """
        if not preferences:
            return {
                "passed": True,
                "reasons": [],
                "score_adjustment": 0.0
            }
        
        reasons = []
        score_adjustment = 0.0
        
        # Vérifier les restrictions alimentaires
        if preferences.dietary_restrictions:
            restrictions = [r.lower() for r in preferences.dietary_restrictions]
            
            # Vérifier les ingrédients de la recette
            ingredients = self.db.query(RecipeIngredient).filter(
                RecipeIngredient.recipe_id == recipe.id
            ).all()
            
            for ingredient in ingredients:
                ingredient_lower = ingredient.ingredient_name.lower()
                
                # Vérifications basiques (peut être amélioré)
                if "végétarien" in restrictions and any(
                    meat in ingredient_lower for meat in ["viande", "poulet", "bœuf", "porc", "poisson"]
                ):
                    reasons.append("Contient de la viande (régime végétarien)")
                    return {"passed": False, "reasons": reasons, "score_adjustment": -1.0}
                
                if "végétalien" in restrictions or "vegan" in restrictions:
                    if any(dairy in ingredient_lower for dairy in ["lait", "fromage", "beurre", "crème", "œuf", "oeuf"]):
                        reasons.append("Contient des produits d'origine animale (régime végétalien)")
                        return {"passed": False, "reasons": reasons, "score_adjustment": -1.0}
        
        # Vérifier les allergies
        if preferences.allergies:
            allergies = [a.lower() for a in preferences.allergies]
            ingredients = self.db.query(RecipeIngredient).filter(
                RecipeIngredient.recipe_id == recipe.id
            ).all()
            
            for ingredient in ingredients:
                ingredient_lower = ingredient.ingredient_name.lower()
                for allergy in allergies:
                    if allergy in ingredient_lower or ingredient_lower in allergy:
                        reasons.append(f"Contient {allergy} (allergie)")
                        return {"passed": False, "reasons": reasons, "score_adjustment": -1.0}
        
        # Vérifier les ingrédients détestés
        if preferences.disliked_ingredients:
            disliked = [d.lower() for d in preferences.disliked_ingredients]
            ingredients = self.db.query(RecipeIngredient).filter(
                RecipeIngredient.recipe_id == recipe.id
            ).all()
            
            for ingredient in ingredients:
                ingredient_lower = ingredient.ingredient_name.lower()
                for dislike in disliked:
                    if dislike in ingredient_lower:
                        reasons.append(f"Contient {dislike} (ingrédient détesté)")
                        score_adjustment -= 0.3  # Réduction mais pas exclusion
        
        # Vérifier le temps de préparation
        if preferences.max_prep_time and recipe.preparation_time:
            if recipe.preparation_time > preferences.max_prep_time:
                reasons.append(f"Temps de préparation trop long ({recipe.preparation_time}min > {preferences.max_prep_time}min)")
                score_adjustment -= 0.2
        
        if preferences.max_cooking_time and recipe.cooking_time:
            if recipe.cooking_time > preferences.max_cooking_time:
                reasons.append(f"Temps de cuisson trop long ({recipe.cooking_time}min > {preferences.max_cooking_time}min)")
                score_adjustment -= 0.2
        
        return {
            "passed": True,
            "reasons": reasons,
            "score_adjustment": max(-1.0, score_adjustment)
        }
    
    def calculate_nutrition_score(
        self,
        recipe: Recipe,
        preferences: Optional[UserPreferences]
    ) -> Dict[str, Any]:
        """
        Calcule un score nutritionnel basé sur les objectifs de l'utilisateur.
        
        Returns:
            dict avec:
            - score: score nutritionnel (0.0-1.0)
            - calories: calories de la recette
            - proteins: protéines
            - carbs: glucides
            - fats: lipides
            - goals_met: dict indiquant quels objectifs sont atteints
        """
        nutrition = self.db.query(NutritionData).filter(
            NutritionData.recipe_id == recipe.id
        ).first()
        
        if not nutrition:
            return {
                "score": 0.5,  # Score neutre si pas de données
                "calories": None,
                "proteins": None,
                "carbs": None,
                "fats": None,
                "goals_met": {}
            }
        
        calories = float(nutrition.calories) if nutrition.calories else 0
        proteins = float(nutrition.proteins) if nutrition.proteins else 0
        carbs = float(nutrition.carbohydrates) if nutrition.carbohydrates else 0
        fats = float(nutrition.fats) if nutrition.fats else 0
        
        goals_met = {}
        score = 0.5  # Score de base
        
        if preferences:
            # Vérifier les objectifs caloriques
            if preferences.daily_calorie_goal:
                goal = float(preferences.daily_calorie_goal)
                # Score basé sur la proximité de l'objectif (pour une portion)
                if goal > 0:
                    ratio = calories / goal
                    if 0.2 <= ratio <= 0.4:  # 20-40% de l'objectif quotidien (idéal pour un repas)
                        score += 0.2
                        goals_met["calories"] = "optimal"
                    elif 0.1 <= ratio <= 0.5:
                        score += 0.1
                        goals_met["calories"] = "good"
                    else:
                        goals_met["calories"] = "outside_range"
            
            # Vérifier les objectifs de protéines
            if preferences.daily_protein_goal:
                goal = float(preferences.daily_protein_goal)
                if goal > 0:
                    ratio = proteins / goal
                    if 0.2 <= ratio <= 0.4:
                        score += 0.15
                        goals_met["proteins"] = "optimal"
                    elif 0.1 <= ratio <= 0.5:
                        score += 0.1
                        goals_met["proteins"] = "good"
        
        return {
            "score": min(1.0, score),
            "calories": calories,
            "proteins": proteins,
            "carbs": carbs,
            "fats": fats,
            "goals_met": goals_met
        }
    
    def get_recommendations(
        self,
        limit: int = 10,
        min_match_score: float = 0.0,
        include_nutrition: bool = True,
        include_preferences: bool = True
    ) -> List[Dict[str, Any]]:
        """
        Génère une liste de recettes recommandées pour l'utilisateur.
        
        Args:
            limit: Nombre maximum de recommandations
            min_match_score: Score minimum de compatibilité
            include_nutrition: Inclure le calcul nutritionnel
            include_preferences: Inclure le filtrage par préférences
        
        Returns:
            Liste de dicts avec les recettes recommandées et leurs scores
        """
        # Récupérer le stock de l'utilisateur
        stock_items = self.db.query(StockItem).filter(
            StockItem.user_id == self.user_id
        ).all()
        
        # Récupérer les préférences
        preferences = self.db.query(UserPreferences).filter(
            UserPreferences.user_id == self.user_id
        ).first()
        
        # Récupérer toutes les recettes actives
        recipes = self.db.query(Recipe).filter(Recipe.is_active == True).all()
        
        recommendations = []
        
        for recipe in recipes:
            # Calculer le score de compatibilité avec le stock
            match_result = self.calculate_ingredient_match_score(recipe, stock_items)
            base_score = match_result["match_score"]
            
            # Filtrer selon le score minimum
            if base_score < min_match_score:
                continue
            
            # Filtrer selon les préférences
            if include_preferences:
                pref_result = self.filter_by_preferences(recipe, preferences)
                if not pref_result["passed"]:
                    continue
                base_score += pref_result["score_adjustment"]
            
            # Calculer le score nutritionnel
            nutrition_score = 0.5
            nutrition_data = {}
            if include_nutrition:
                nutrition_result = self.calculate_nutrition_score(recipe, preferences)
                nutrition_score = nutrition_result["score"]
                nutrition_data = {
                    "calories": nutrition_result["calories"],
                    "proteins": nutrition_result["proteins"],
                    "carbs": nutrition_result["carbs"],
                    "fats": nutrition_result["fats"],
                    "goals_met": nutrition_result["goals_met"]
                }
            
            # Score final (pondération : 60% compatibilité, 40% nutrition)
            final_score = (base_score * 0.6) + (nutrition_score * 0.4)
            
            # Récupérer les infos nutritionnelles
            nutrition = self.db.query(NutritionData).filter(
                NutritionData.recipe_id == recipe.id
            ).first()
            
            recommendation = {
                "recipe_id": recipe.id,
                "recipe_name": recipe.name,
                "description": recipe.description,
                "total_time": recipe.total_time,
                "difficulty": recipe.difficulty,
                "servings": recipe.servings,
                "image_url": recipe.image_url,
                "final_score": final_score,
                "match_score": base_score,
                "nutrition_score": nutrition_score,
                "can_cook": match_result["can_cook"],
                "available_ingredients": match_result["available_ingredients"],
                "total_ingredients": match_result["total_ingredients"],
                "missing_ingredients": match_result["missing_ingredients"],
                "partial_matches": match_result["partial_matches"],
                "calories": float(nutrition.calories) if nutrition and nutrition.calories else None,
                **nutrition_data
            }
            
            recommendations.append(recommendation)
        
        # Trier par score final décroissant
        recommendations.sort(key=lambda x: x["final_score"], reverse=True)
        
        # Retourner les top N
        return recommendations[:limit]

