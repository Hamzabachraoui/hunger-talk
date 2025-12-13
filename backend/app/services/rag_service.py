"""
Service RAG pour construire le contexte et formater les données
"""
from sqlalchemy.orm import Session
from datetime import date, timedelta
from typing import Dict, List, Any, Optional
from app.models.user import User
from app.models.stock_item import StockItem
from app.models.user_preferences import UserPreferences
from app.models.recipe import Recipe, RecipeIngredient, NutritionData
from app.models.category import Category
from app.services.recommendation_service import RecommendationService


class RAGService:
    """Service pour construire le contexte RAG"""
    
    def __init__(self, db: Session, user: User):
        self.db = db
        self.user = user
    
    def get_stock_context(self) -> str:
        """Récupérer et formater le stock actuel"""
        stock_items = self.db.query(StockItem).filter(
            StockItem.user_id == self.user.id
        ).all()
        
        if not stock_items:
            return "Stock actuel : Aucun produit dans le stock."
        
        today = date.today()
        context_lines = ["Stock actuel de l'utilisateur :"]
        
        expiring_soon_count = 0
        for item in stock_items:
            category_name = "Non catégorisé"
            if item.category_id:
                category = self.db.query(Category).filter(Category.id == item.category_id).first()
                if category:
                    category_name = category.name
            
            line = f"- {item.name} : {item.quantity} {item.unit or ''}"
            if item.expiry_date:
                days_until = (item.expiry_date - today).days
                if days_until < 0:
                    line += f" (expiré il y a {abs(days_until)} jour(s)) ⚠️"
                elif days_until <= 3:
                    line += f" (expire le {item.expiry_date}, dans {days_until} jour(s)) ⚠️ Expire bientôt"
                    expiring_soon_count += 1
                else:
                    line += f" (expire le {item.expiry_date}, dans {days_until} jour(s))"
            line += f" [Catégorie: {category_name}]"
            context_lines.append(line)
        
        context_lines.append(f"\nTotal : {len(stock_items)} produit(s), {expiring_soon_count} expirant bientôt (dans moins de 3 jours)")
        
        return "\n".join(context_lines)
    
    def get_preferences_context(self) -> str:
        """Récupérer et formater les préférences utilisateur"""
        preferences = self.db.query(UserPreferences).filter(
            UserPreferences.user_id == self.user.id
        ).first()
        
        if not preferences:
            return "Préférences : Aucune préférence spécifiée."
        
        context_lines = ["Préférences alimentaires :"]
        
        if preferences.dietary_restrictions:
            restrictions = preferences.dietary_restrictions if isinstance(preferences.dietary_restrictions, list) else [preferences.dietary_restrictions]
            context_lines.append(f"- Restrictions : {', '.join(restrictions)}")
        
        if preferences.allergies:
            allergies = preferences.allergies if isinstance(preferences.allergies, list) else [preferences.allergies]
            context_lines.append(f"- Allergies : {', '.join(allergies)}")
        
        if preferences.preferred_cuisines:
            cuisines = preferences.preferred_cuisines if isinstance(preferences.preferred_cuisines, list) else [preferences.preferred_cuisines]
            context_lines.append(f"- Cuisines préférées : {', '.join(cuisines)}")
        
        if preferences.disliked_ingredients:
            disliked = preferences.disliked_ingredients if isinstance(preferences.disliked_ingredients, list) else [preferences.disliked_ingredients]
            context_lines.append(f"- Ingrédients à éviter : {', '.join(disliked)}")
        
        if preferences.max_prep_time or preferences.max_cooking_time:
            context_lines.append(f"- Contraintes de temps : préparation max {preferences.max_prep_time or 'illimité'}min, cuisson max {preferences.max_cooking_time or 'illimité'}min")
        
        return "\n".join(context_lines) if len(context_lines) > 1 else "Préférences : Aucune préférence spécifiée."
    
    def get_nutrition_goals_context(self) -> str:
        """Récupérer et formater les objectifs nutritionnels"""
        preferences = self.db.query(UserPreferences).filter(
            UserPreferences.user_id == self.user.id
        ).first()
        
        if not preferences:
            return "Objectifs nutritionnels : Aucun objectif spécifié."
        
        context_lines = ["Objectifs nutritionnels quotidiens :"]
        has_goals = False
        
        if preferences.daily_calorie_goal:
            context_lines.append(f"- Calories : {float(preferences.daily_calorie_goal)} kcal")
            has_goals = True
        
        if preferences.daily_protein_goal:
            context_lines.append(f"- Protéines : {float(preferences.daily_protein_goal)}g")
            has_goals = True
        
        if preferences.daily_carb_goal:
            context_lines.append(f"- Glucides : {float(preferences.daily_carb_goal)}g")
            has_goals = True
        
        if preferences.daily_fat_goal:
            context_lines.append(f"- Lipides : {float(preferences.daily_fat_goal)}g")
            has_goals = True
        
        if has_goals:
            return "\n".join(context_lines)
        
        return "Objectifs nutritionnels : Aucun objectif spécifié."
    
    def get_recipes_context(self, limit: int = 5) -> str:
        """Récupérer et formater les recettes disponibles"""
        recipes = self.db.query(Recipe).filter(
            Recipe.is_active == True
        ).limit(limit).all()
        
        if not recipes:
            return "Recettes disponibles : Aucune recette disponible pour le moment."
        
        context_lines = [f"Recettes disponibles (top {len(recipes)}) :"]
        
        for idx, recipe in enumerate(recipes, 1):
            # Récupérer les ingrédients
            ingredients = self.db.query(RecipeIngredient).filter(
                RecipeIngredient.recipe_id == recipe.id
            ).all()
            ingredient_names = [ing.ingredient_name for ing in ingredients]
            
            # Récupérer les infos nutritionnelles
            nutrition = self.db.query(NutritionData).filter(
                NutritionData.recipe_id == recipe.id
            ).first()
            
            line = f"\n{idx}. {recipe.name}"
            if recipe.description:
                line += f" - {recipe.description[:100]}"
            
            line += f"\n   - Ingrédients : {', '.join(ingredient_names[:5])}"
            if len(ingredient_names) > 5:
                line += f" (+ {len(ingredient_names) - 5} autres)"
            
            if recipe.total_time:
                line += f"\n   - Temps total : {recipe.total_time}min"
            if recipe.difficulty:
                line += f"\n   - Difficulté : {recipe.difficulty}"
            if recipe.servings:
                line += f"\n   - Portions : {recipe.servings}"
            
            if nutrition:
                line += f"\n   - Nutrition : {nutrition.calories or 0} kcal"
                if nutrition.proteins:
                    line += f", {nutrition.proteins}g protéines"
            
            line += f"\n   - ID recette : {recipe.id}"
            context_lines.append(line)
        
        return "\n".join(context_lines)
    
    def get_recommendations_context(self, limit: int = 5) -> str:
        """Récupérer et formater les recommandations personnalisées"""
        try:
            from app.services.recommendation_service import RecommendationService
            service = RecommendationService(self.db, self.user.id)
            recommendations = service.get_recommendations(limit=limit, min_match_score=0.3)
            
            if not recommendations:
                return "Recommandations : Aucune recette recommandée pour le moment."
            
            context_lines = [f"Recommandations personnalisées (top {len(recommendations)}) :"]
            
            for idx, rec in enumerate(recommendations, 1):
                line = f"\n{idx}. {rec['recipe_name']} (Score: {rec['final_score']:.2f})"
                if rec.get('description'):
                    line += f"\n   - {rec['description'][:100]}"
                
                line += f"\n   - Compatibilité stock : {rec['match_score']:.1%} ({rec['available_ingredients']}/{rec['total_ingredients']} ingrédients)"
                
                if rec.get('can_cook'):
                    line += " ✅ Peut être cuisinée maintenant"
                elif rec.get('missing_ingredients'):
                    missing = [m['name'] for m in rec['missing_ingredients'][:3]]
                    line += f"\n   - Ingrédients manquants : {', '.join(missing)}"
                    if len(rec['missing_ingredients']) > 3:
                        line += f" (+ {len(rec['missing_ingredients']) - 3} autres)"
                
                if rec.get('calories'):
                    line += f"\n   - Nutrition : {rec['calories']:.0f} kcal"
                    if rec.get('proteins'):
                        line += f", {rec['proteins']:.1f}g protéines"
                
                if rec.get('total_time'):
                    line += f"\n   - Temps : {rec['total_time']}min"
                
                line += f"\n   - ID recette : {rec['recipe_id']}"
                context_lines.append(line)
            
            return "\n".join(context_lines)
        except Exception as e:
            # En cas d'erreur, retourner un message simple
            return f"Recommandations : Erreur lors de la génération ({str(e)[:50]})."
    
    def build_full_context(self, user_message: str, include_recommendations: bool = True) -> str:
        """Construire le contexte complet pour l'IA"""
        context_parts = [
            "[STOCK ACTUEL]",
            self.get_stock_context(),
            "",
            "[PRÉFÉRENCES]",
            self.get_preferences_context(),
            "",
            "[OBJECTIFS NUTRITIONNELS]",
            self.get_nutrition_goals_context(),
            "",
            "[RECETTES DISPONIBLES]",
            self.get_recipes_context(),
        ]
        
        # Ajouter les recommandations personnalisées si demandé
        if include_recommendations:
            context_parts.extend([
                "",
                "[RECOMMANDATIONS PERSONNALISÉES]",
                self.get_recommendations_context(limit=5),
            ])
        
        context_parts.extend([
            "",
            "[MESSAGE UTILISATEUR]",
            user_message
        ])
        
        return "\n".join(context_parts)
    
    def build_system_prompt(self) -> str:
        """Construire le prompt système pour l'IA"""
        return """Tu es un assistant culinaire intelligent pour l'application Hunger-Talk. 
Ton rôle est d'aider les utilisateurs à cuisiner avec les ingrédients qu'ils ont déjà dans leur stock.

INSTRUCTIONS :
1. Analyse le stock disponible et les préférences de l'utilisateur
2. Recommande des recettes pertinentes en priorisant :
   - Les recettes avec tous les ingrédients disponibles
   - Les produits expirant bientôt
   - Les objectifs nutritionnels de l'utilisateur
   - Les préférences alimentaires
3. Si des ingrédients manquent, suggère des alternatives ou des produits à acheter
4. Adapte les recommandations au contexte du message de l'utilisateur
5. Formate ta réponse de manière claire et engageante
6. Inclus les informations nutritionnelles pertinentes

FORMAT DE RÉPONSE :
- Réponse naturelle et conversationnelle
- Mentionne les IDs des recettes recommandées si tu en cites
- Explication de pourquoi ces recettes sont recommandées
- Suggestions d'alternatives si nécessaire

IMPORTANT :
- Respecte absolument les allergies et restrictions alimentaires
- Priorise les produits expirant bientôt pour réduire le gaspillage
- Considère les objectifs nutritionnels quotidiens
- Sois créatif mais pratique"""

