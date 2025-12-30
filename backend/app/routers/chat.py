"""
Router pour le chat avec l'IA
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime
import time
import uuid

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from database import get_db
from app.models.user import User
from app.models.chat_message import ChatMessage
from app.schemas.chat import ChatMessageCreate, ChatMessageResponse, ChatMessageSimple
from app.core.dependencies import get_current_user
from app.services.ollama_service import ollama_service
from app.services.rag_service import RAGService

router = APIRouter()


@router.post("/", response_model=ChatMessageSimple, status_code=status.HTTP_200_OK)
async def chat_with_ai(
    chat_data: ChatMessageCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Envoyer un message à l'IA et recevoir une réponse.
    
    Le système RAG construit automatiquement le contexte basé sur :
    - Le stock actuel de l'utilisateur
    - Ses préférences alimentaires
    - Ses objectifs nutritionnels
    - Les recettes disponibles
    """
    start_time = time.time()
    
    try:
        # Vérifier que Ollama est disponible
        is_available = await ollama_service.check_availability()
        if not is_available:
            ollama_url = ollama_service.base_url
            error_detail = (
                f"L'IA n'est pas disponible à {ollama_url}. "
                "Vérifiez que :\n"
                "1. Ollama est démarré sur votre machine\n"
                "2. Le tunnel (ngrok) est actif\n"
                "3. La variable OLLAMA_BASE_URL dans Railway est correcte"
            )
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail=error_detail
            )
        
        # Construire le contexte RAG
        rag_service = RAGService(db, current_user)
        full_context = rag_service.build_full_context(chat_data.message)
        system_prompt = rag_service.build_system_prompt()
        
        # Appeler Ollama
        try:
            result = await ollama_service.generate(
                prompt=full_context,
                system_prompt=system_prompt,
                temperature=0.7,
                max_tokens=2000
            )
            
            ai_response = result.get("response", "")
            model_used = result.get("model", "llama3.1:8b")
            
        except Exception as e:
            # En cas d'erreur avec Ollama, retourner un message d'erreur
            ai_response = f"Désolé, je rencontre un problème technique : {str(e)}. Veuillez réessayer plus tard."
            model_used = None
        
        # Calculer le temps de réponse
        response_time_ms = int((time.time() - start_time) * 1000)
        
        # Sauvegarder le message et la réponse en base de données
        chat_message = ChatMessage(
            id=uuid.uuid4(),
            user_id=current_user.id,
            message=chat_data.message,
            response=ai_response,
            context_used=full_context[:5000],  # Limiter la taille du contexte sauvegardé
            model_used=model_used,
            response_time_ms=response_time_ms,
            timestamp=datetime.utcnow()
        )
        
        db.add(chat_message)
        db.commit()
        db.refresh(chat_message)
        
        return ChatMessageSimple(
            response=ai_response,
            ai_model=model_used,
            response_time_ms=response_time_ms
        )
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors du traitement du message : {str(e)}"
        )


@router.get("/history", response_model=list[ChatMessageResponse])
async def get_chat_history(
    limit: int = 20,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupérer l'historique des messages de chat de l'utilisateur.
    """
    messages = db.query(ChatMessage).filter(
        ChatMessage.user_id == current_user.id
    ).order_by(
        ChatMessage.timestamp.desc()
    ).limit(limit).all()
    
    return [ChatMessageResponse(
        id=msg.id,
        user_id=msg.user_id,
        message=msg.message,
        response=msg.response,
        timestamp=msg.timestamp,
        ai_model=msg.model_used,
        response_time_ms=msg.response_time_ms
    ) for msg in messages]

