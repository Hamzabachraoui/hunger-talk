"""
Service de gestion des notifications
"""
from sqlalchemy.orm import Session
from typing import List, Dict, Any, Optional
from uuid import UUID
from datetime import date, datetime, timedelta

from app.models.notification import Notification
from app.models.stock_item import StockItem
from app.models.recipe import Recipe, RecipeIngredient
from app.models.category import Category
from app.services.recommendation_service import RecommendationService


class NotificationService:
    """Service pour gérer les notifications utilisateur"""
    
    def __init__(self, db: Session, user_id: UUID):
        self.db = db
        self.user_id = user_id
    
    def check_expiring_items(self, days_ahead: int = 3) -> List[Dict[str, Any]]:
        """
        Vérifie les produits expirant dans les prochains jours.
        
        Args:
            days_ahead: Nombre de jours à l'avance pour vérifier
        
        Returns:
            Liste des produits expirant bientôt
        """
        today = date.today()
        expiry_threshold = today + timedelta(days=days_ahead)
        
        expiring_items = self.db.query(StockItem).filter(
            StockItem.user_id == self.user_id,
            StockItem.expiry_date.isnot(None),
            StockItem.expiry_date >= today,
            StockItem.expiry_date <= expiry_threshold
        ).all()
        
        result = []
        for item in expiring_items:
            days_until = (item.expiry_date - today).days
            category_name = "Non catégorisé"
            if item.category_id:
                category = self.db.query(Category).filter(Category.id == item.category_id).first()
                if category:
                    category_name = category.name
            
            result.append({
                "item_id": str(item.id),
                "name": item.name,
                "quantity": float(item.quantity),
                "unit": item.unit or "",
                "expiry_date": item.expiry_date.isoformat(),
                "days_until": days_until,
                "category": category_name
            })
        
        return result
    
    def generate_expiry_notifications(self, days_ahead: int = 3) -> int:
        """
        Génère des notifications pour les produits expirant bientôt.
        
        Returns:
            Nombre de notifications créées
        """
        expiring_items = self.check_expiring_items(days_ahead)
        
        if not expiring_items:
            return 0
        
        notifications_created = 0
        
        for item in expiring_items:
            # Vérifier si une notification existe déjà pour cet item
            existing = self.db.query(Notification).filter(
                Notification.user_id == self.user_id,
                Notification.type == "expiry",
                Notification.related_item_id == UUID(item["item_id"]),
                Notification.is_read == False
            ).first()
            
            if existing:
                continue  # Notification déjà existante et non lue
            
            # Créer la notification
            days_text = "demain" if item["days_until"] == 1 else f"dans {item['days_until']} jours"
            if item["days_until"] == 0:
                days_text = "aujourd'hui"
            
            notification = Notification(
                id=UUID(),
                user_id=self.user_id,
                type="expiry",
                title=f"⏰ Produit expirant {days_text}",
                message=f"{item['name']} ({item['quantity']} {item['unit']}) expire le {item['expiry_date']}. Pensez à l'utiliser !",
                related_item_id=UUID(item["item_id"]),
                is_read=False,
                created_at=datetime.utcnow()
            )
            
            self.db.add(notification)
            notifications_created += 1
        
        self.db.commit()
        return notifications_created
    
    def generate_recipe_suggestions_for_expiring(self, days_ahead: int = 3) -> int:
        """
        Génère des suggestions de recettes pour les produits expirant bientôt.
        
        Returns:
            Nombre de notifications créées
        """
        expiring_items = self.check_expiring_items(days_ahead)
        
        if not expiring_items:
            return 0
        
        # Récupérer les recommandations basées sur le stock
        try:
            service = RecommendationService(self.db, self.user_id)
            recommendations = service.get_recommendations(limit=3, min_match_score=0.3)
        except:
            recommendations = []
        
        if not recommendations:
            return 0
        
        notifications_created = 0
        
        # Créer une notification pour les meilleures recettes
        expiring_names = [item["name"] for item in expiring_items[:3]]
        expiring_text = ", ".join(expiring_names)
        
        # Vérifier si une notification de suggestion existe déjà aujourd'hui
        today_start = datetime.combine(date.today(), datetime.min.time())
        existing = self.db.query(Notification).filter(
            Notification.user_id == self.user_id,
            Notification.type == "recipe_suggestion",
            Notification.created_at >= today_start,
            Notification.is_read == False
        ).first()
        
        if existing:
            return 0  # Notification déjà créée aujourd'hui
        
        # Créer la notification avec les suggestions
        recipe_names = [rec["recipe_name"] for rec in recommendations[:3]]
        recipes_text = ", ".join(recipe_names)
        
        notification = Notification(
            id=UUID(),
            user_id=self.user_id,
            type="recipe_suggestion",
            title="🍳 Suggestions de recettes",
            message=f"Vous avez des produits expirant bientôt ({expiring_text}). Voici des recettes suggérées : {recipes_text}",
            is_read=False,
            created_at=datetime.utcnow()
        )
        
        self.db.add(notification)
        notifications_created += 1
        self.db.commit()
        
        return notifications_created
    
    def get_user_notifications(
        self, 
        unread_only: bool = False,
        limit: int = 50
    ) -> List[Notification]:
        """
        Récupère les notifications de l'utilisateur.
        
        Args:
            unread_only: Si True, retourne uniquement les non lues
            limit: Nombre maximum de notifications
        
        Returns:
            Liste des notifications
        """
        query = self.db.query(Notification).filter(
            Notification.user_id == self.user_id
        )
        
        if unread_only:
            query = query.filter(Notification.is_read == False)
        
        return query.order_by(Notification.created_at.desc()).limit(limit).all()
    
    def mark_as_read(self, notification_id: UUID) -> bool:
        """
        Marque une notification comme lue.
        
        Args:
            notification_id: ID de la notification
        
        Returns:
            True si la notification a été marquée comme lue
        """
        notification = self.db.query(Notification).filter(
            Notification.id == notification_id,
            Notification.user_id == self.user_id
        ).first()
        
        if not notification:
            return False
        
        if not notification.is_read:
            notification.is_read = True
            notification.read_at = datetime.utcnow()
            self.db.commit()
        
        return True
    
    def mark_all_as_read(self) -> int:
        """
        Marque toutes les notifications de l'utilisateur comme lues.
        
        Returns:
            Nombre de notifications marquées comme lues
        """
        notifications = self.db.query(Notification).filter(
            Notification.user_id == self.user_id,
            Notification.is_read == False
        ).all()
        
        count = 0
        for notification in notifications:
            notification.is_read = True
            notification.read_at = datetime.utcnow()
            count += 1
        
        self.db.commit()
        return count

