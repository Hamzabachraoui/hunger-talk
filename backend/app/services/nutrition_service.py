"""
Service de calcul nutritionnel et statistiques
"""
from sqlalchemy.orm import Session
from typing import Dict, List, Any, Optional
from uuid import UUID
from datetime import date, datetime, timedelta
from decimal import Decimal

from app.models.cooking_history import CookingHistory
from app.models.recipe import Recipe, NutritionData
from app.models.user_preferences import UserPreferences


class NutritionService:
    """Service pour calculer les statistiques nutritionnelles"""
    
    def __init__(self, db: Session, user_id: UUID):
        self.db = db
        self.user_id = user_id
    
    def calculate_daily_nutrition(self, target_date: Optional[date] = None) -> Dict[str, Any]:
        """
        Calcule les statistiques nutritionnelles pour une journée donnée.
        
        Args:
            target_date: Date cible (par défaut: aujourd'hui)
        
        Returns:
            dict avec les stats nutritionnelles et la comparaison avec les objectifs
        """
        if target_date is None:
            target_date = date.today()
        
        # Récupérer toutes les recettes cuisinées ce jour
        start_of_day = datetime.combine(target_date, datetime.min.time())
        end_of_day = datetime.combine(target_date, datetime.max.time())
        
        cooking_records = self.db.query(CookingHistory).filter(
            CookingHistory.user_id == self.user_id,
            CookingHistory.cooked_at >= start_of_day,
            CookingHistory.cooked_at <= end_of_day
        ).all()
        
        # Initialiser les totaux
        total_calories = Decimal('0')
        total_proteins = Decimal('0')
        total_carbs = Decimal('0')
        total_fats = Decimal('0')
        total_fiber = Decimal('0')
        total_sugar = Decimal('0')
        total_sodium = Decimal('0')
        
        recipes_cooked = []
        
        for record in cooking_records:
            # Récupérer la recette et ses données nutritionnelles
            recipe = self.db.query(Recipe).filter(Recipe.id == record.recipe_id).first()
            if not recipe:
                continue
            
            nutrition = self.db.query(NutritionData).filter(
                NutritionData.recipe_id == record.recipe_id
            ).first()
            
            if not nutrition:
                continue
            
            # Calculer le ratio selon le nombre de portions
            servings_ratio = Decimal(str(record.servings_made or recipe.servings)) / Decimal(str(recipe.servings))
            
            # Ajouter les valeurs nutritionnelles (multipliées par le ratio)
            if nutrition.calories:
                total_calories += Decimal(str(nutrition.calories)) * servings_ratio
            if nutrition.proteins:
                total_proteins += Decimal(str(nutrition.proteins)) * servings_ratio
            if nutrition.carbohydrates:
                total_carbs += Decimal(str(nutrition.carbohydrates)) * servings_ratio
            if nutrition.fats:
                total_fats += Decimal(str(nutrition.fats)) * servings_ratio
            if nutrition.fiber:
                total_fiber += Decimal(str(nutrition.fiber)) * servings_ratio
            if nutrition.sugar:
                total_sugar += Decimal(str(nutrition.sugar)) * servings_ratio
            if nutrition.sodium:
                total_sodium += Decimal(str(nutrition.sodium)) * servings_ratio
            
            recipes_cooked.append({
                "recipe_id": str(recipe.id),
                "recipe_name": recipe.name,
                "servings_made": record.servings_made or recipe.servings,
                "calories": float(Decimal(str(nutrition.calories)) * servings_ratio) if nutrition.calories else 0,
                "cooked_at": record.cooked_at.isoformat() if record.cooked_at else None
            })
        
        # Récupérer les objectifs de l'utilisateur
        preferences = self.db.query(UserPreferences).filter(
            UserPreferences.user_id == self.user_id
        ).first()
        
        goals = {}
        comparisons = {}
        
        if preferences:
            if preferences.daily_calorie_goal:
                goal = float(preferences.daily_calorie_goal)
                goals["calories"] = goal
                consumed = float(total_calories)
                comparisons["calories"] = {
                    "goal": goal,
                    "consumed": consumed,
                    "remaining": max(0, goal - consumed),
                    "percentage": min(100, (consumed / goal * 100)) if goal > 0 else 0,
                    "status": "over" if consumed > goal else "under" if consumed < goal * 0.8 else "good"
                }
            
            if preferences.daily_protein_goal:
                goal = float(preferences.daily_protein_goal)
                goals["proteins"] = goal
                consumed = float(total_proteins)
                comparisons["proteins"] = {
                    "goal": goal,
                    "consumed": consumed,
                    "remaining": max(0, goal - consumed),
                    "percentage": min(100, (consumed / goal * 100)) if goal > 0 else 0,
                    "status": "over" if consumed > goal else "under" if consumed < goal * 0.8 else "good"
                }
            
            if preferences.daily_carb_goal:
                goal = float(preferences.daily_carb_goal)
                goals["carbs"] = goal
                consumed = float(total_carbs)
                comparisons["carbs"] = {
                    "goal": goal,
                    "consumed": consumed,
                    "remaining": max(0, goal - consumed),
                    "percentage": min(100, (consumed / goal * 100)) if goal > 0 else 0,
                    "status": "over" if consumed > goal else "under" if consumed < goal * 0.8 else "good"
                }
            
            if preferences.daily_fat_goal:
                goal = float(preferences.daily_fat_goal)
                goals["fats"] = goal
                consumed = float(total_fats)
                comparisons["fats"] = {
                    "goal": goal,
                    "consumed": consumed,
                    "remaining": max(0, goal - consumed),
                    "percentage": min(100, (consumed / goal * 100)) if goal > 0 else 0,
                    "status": "over" if consumed > goal else "under" if consumed < goal * 0.8 else "good"
                }
        
        return {
            "date": target_date.isoformat(),
            "total": {
                "calories": float(total_calories),
                "proteins": float(total_proteins),
                "carbohydrates": float(total_carbs),
                "fats": float(total_fats),
                "fiber": float(total_fiber),
                "sugar": float(total_sugar),
                "sodium": float(total_sodium)
            },
            "goals": goals,
            "comparisons": comparisons,
            "recipes_cooked": recipes_cooked,
            "recipes_count": len(recipes_cooked)
        }
    
    def calculate_weekly_nutrition(self, start_date: Optional[date] = None) -> Dict[str, Any]:
        """
        Calcule les statistiques nutritionnelles pour une semaine.
        
        Args:
            start_date: Date de début de la semaine (par défaut: il y a 7 jours)
        
        Returns:
            dict avec les stats par jour et les moyennes
        """
        if start_date is None:
            start_date = date.today() - timedelta(days=6)  # 7 jours incluant aujourd'hui
        
        daily_stats = []
        total_calories = Decimal('0')
        total_proteins = Decimal('0')
        total_carbs = Decimal('0')
        total_fats = Decimal('0')
        days_with_data = 0
        
        # Calculer pour chaque jour de la semaine
        for i in range(7):
            current_date = start_date + timedelta(days=i)
            day_stats = self.calculate_daily_nutrition(current_date)
            
            daily_stats.append({
                "date": current_date.isoformat(),
                "calories": day_stats["total"]["calories"],
                "proteins": day_stats["total"]["proteins"],
                "carbohydrates": day_stats["total"]["carbohydrates"],
                "fats": day_stats["total"]["fats"],
                "recipes_count": day_stats["recipes_count"]
            })
            
            if day_stats["recipes_count"] > 0:
                total_calories += Decimal(str(day_stats["total"]["calories"]))
                total_proteins += Decimal(str(day_stats["total"]["proteins"]))
                total_carbs += Decimal(str(day_stats["total"]["carbohydrates"]))
                total_fats += Decimal(str(day_stats["total"]["fats"]))
                days_with_data += 1
        
        # Calculer les moyennes
        avg_calories = float(total_calories / Decimal(str(days_with_data))) if days_with_data > 0 else 0
        avg_proteins = float(total_proteins / Decimal(str(days_with_data))) if days_with_data > 0 else 0
        avg_carbs = float(total_carbs / Decimal(str(days_with_data))) if days_with_data > 0 else 0
        avg_fats = float(total_fats / Decimal(str(days_with_data))) if days_with_data > 0 else 0
        
        # Récupérer les objectifs pour la comparaison
        preferences = self.db.query(UserPreferences).filter(
            UserPreferences.user_id == self.user_id
        ).first()
        
        goals = {}
        if preferences:
            if preferences.daily_calorie_goal:
                goals["calories"] = float(preferences.daily_calorie_goal)
            if preferences.daily_protein_goal:
                goals["proteins"] = float(preferences.daily_protein_goal)
            if preferences.daily_carb_goal:
                goals["carbs"] = float(preferences.daily_carb_goal)
            if preferences.daily_fat_goal:
                goals["fats"] = float(preferences.daily_fat_goal)
        
        return {
            "start_date": start_date.isoformat(),
            "end_date": (start_date + timedelta(days=6)).isoformat(),
            "daily_stats": daily_stats,
            "averages": {
                "calories": avg_calories,
                "proteins": avg_proteins,
                "carbohydrates": avg_carbs,
                "fats": avg_fats
            },
            "totals": {
                "calories": float(total_calories),
                "proteins": float(total_proteins),
                "carbohydrates": float(total_carbs),
                "fats": float(total_fats)
            },
            "goals": goals,
            "days_with_data": days_with_data,
            "total_days": 7
        }

