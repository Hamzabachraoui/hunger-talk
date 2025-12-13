"""
Router pour les notifications
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from database import get_db
from app.models.user import User
from app.schemas.notification import NotificationResponse, NotificationSummary
from app.core.dependencies import get_current_user
from app.services.notification_service import NotificationService

router = APIRouter()


def generate_notifications_background(db: Session, user_id: UUID):
    """Tâche en arrière-plan pour générer les notifications"""
    try:
        service = NotificationService(db, user_id)
        # Générer les notifications d'expiration
        service.generate_expiry_notifications(days_ahead=3)
        # Générer les suggestions de recettes
        service.generate_recipe_suggestions_for_expiring(days_ahead=3)
    except Exception as e:
        # Log l'erreur mais ne pas bloquer
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f"Erreur lors de la génération des notifications: {e}")


@router.get("/", response_model=NotificationSummary)
async def get_notifications(
    unread_only: Optional[bool] = Query(False, description="Retourner uniquement les non lues"),
    limit: Optional[int] = Query(50, ge=1, le=100, description="Nombre maximum de notifications"),
    background_tasks: BackgroundTasks = BackgroundTasks(),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupérer les notifications de l'utilisateur.
    
    Génère automatiquement de nouvelles notifications en arrière-plan pour :
    - Les produits expirant dans les 3 prochains jours
    - Les suggestions de recettes pour ces produits
    """
    service = NotificationService(db, current_user.id)
    
    # Générer les notifications en arrière-plan
    background_tasks.add_task(generate_notifications_background, db, current_user.id)
    
    # Récupérer les notifications
    notifications = service.get_user_notifications(unread_only=unread_only, limit=limit)
    
    # Compter les non lues
    unread_count = len([n for n in notifications if not n.is_read])
    
    return NotificationSummary(
        total=len(notifications),
        unread=unread_count,
        notifications=[NotificationResponse(
            id=n.id,
            user_id=n.user_id,
            type=n.type,
            title=n.title,
            message=n.message,
            is_read=n.is_read,
            related_item_id=n.related_item_id,
            created_at=n.created_at,
            read_at=n.read_at
        ) for n in notifications]
    )


@router.post("/{notification_id}/read", status_code=status.HTTP_200_OK)
async def mark_notification_read(
    notification_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Marquer une notification comme lue.
    """
    service = NotificationService(db, current_user.id)
    
    success = service.mark_as_read(notification_id)
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification non trouvée"
        )
    
    return {"message": "Notification marquée comme lue", "notification_id": str(notification_id)}


@router.post("/read-all", status_code=status.HTTP_200_OK)
async def mark_all_notifications_read(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Marquer toutes les notifications de l'utilisateur comme lues.
    """
    service = NotificationService(db, current_user.id)
    
    count = service.mark_all_as_read()
    
    return {
        "message": f"{count} notification(s) marquée(s) comme lue(s)",
        "count": count
    }

