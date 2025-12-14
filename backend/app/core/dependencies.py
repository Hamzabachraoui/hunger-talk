"""
Dépendances FastAPI communes
"""
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from typing import Optional
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from database import get_db
from app.core.security import decode_access_token
from app.models.user import User


class CustomHTTPBearer(HTTPBearer):
    """HTTPBearer personnalisé qui retourne une erreur 403 avec 'Not authenticated'"""
    
    async def __call__(self, request) -> Optional[HTTPAuthorizationCredentials]:
        import logging
        logger = logging.getLogger(__name__)
        
        try:
            result = await super().__call__(request)
            if result is None:
                logger.warning("⚠️ [HTTPBearer] Aucun token fourni dans la requête")
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Not authenticated",
                    headers={"WWW-Authenticate": "Bearer"},
                )
            return result
        except HTTPException as e:
            # Si l'exception est due à un token manquant ou invalide, utiliser notre message
            logger.warning(f"⚠️ [HTTPBearer] Exception HTTP: {e.status_code} - {e.detail}")
            if e.status_code in (status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Not authenticated",
                    headers={"WWW-Authenticate": "Bearer"},
                )
            raise
        except Exception as e:
            logger.error(f"❌ [HTTPBearer] Erreur inattendue: {e}")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authenticated",
                headers={"WWW-Authenticate": "Bearer"},
            )


security = CustomHTTPBearer(auto_error=True)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> User:
    """
    Dépendance pour obtenir l'utilisateur actuel à partir du token JWT.
    
    Lève une exception 403 si le token est invalide, expiré ou si l'utilisateur n'est pas trouvé.
    """
    import logging
    logger = logging.getLogger(__name__)
    
    # Exception pour token invalide ou manquant
    authentication_exception = HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="Not authenticated",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        # Vérifier que credentials existe
        if credentials is None:
            logger.warning("⚠️ [AUTH] credentials est None")
            raise authentication_exception
            
        token = credentials.credentials
        if not token or token.strip() == "":
            logger.warning("⚠️ [AUTH] Token vide")
            raise authentication_exception
            
        logger.info(f"🔑 [AUTH] Token reçu: {token[:30]}...")
    except AttributeError as e:
        # Pas de credentials fourni
        logger.warning(f"⚠️ [AUTH] AttributeError: {e}")
        raise authentication_exception
    except Exception as e:
        logger.error(f"❌ [AUTH] Erreur lors de l'extraction du token: {e}")
        raise authentication_exception
    
    # Décoder le token
    payload = decode_access_token(token)
    
    if payload is None:
        # Token invalide ou expiré
        logger.warning(f"⚠️ [AUTH] Token invalide ou expiré: {token[:30]}...")
        raise authentication_exception
    
    # Extraire l'ID utilisateur
    user_id: str = payload.get("sub")
    if user_id is None:
        logger.warning("⚠️ [AUTH] user_id manquant dans le payload")
        raise authentication_exception
    
    logger.info(f"🔍 [AUTH] Recherche utilisateur avec ID: {user_id}")
    
    try:
        # Récupérer l'utilisateur depuis la base de données
        user = db.query(User).filter(User.id == user_id).first()
        if user is None:
            logger.warning(f"⚠️ [AUTH] Utilisateur non trouvé avec ID: {user_id}")
            raise authentication_exception
        
        # Vérifier que le compte est actif
        if not user.is_active:
            logger.warning(f"⚠️ [AUTH] Compte utilisateur inactif: {user_id}")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User account is inactive"
            )
        
        logger.info(f"✅ [AUTH] Utilisateur authentifié: {user.email} (ID: {user_id})")
        return user
    except HTTPException:
        # Re-lancer les HTTPException telles quelles
        raise
    except Exception as e:
        logger.error(f"❌ [AUTH] Erreur lors de la récupération de l'utilisateur: {e}")
        raise authentication_exception


async def get_current_active_user(
    current_user: User = Depends(get_current_user)
) -> User:
    """Vérifier que l'utilisateur est actif"""
    if not current_user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is inactive"
        )
    return current_user


async def get_optional_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(HTTPBearer(auto_error=False)),
    db: Session = Depends(get_db)
) -> Optional[User]:
    """
    Dépendance pour obtenir l'utilisateur actuel de manière optionnelle.
    Retourne None si aucun token n'est fourni, invalide ou expiré.
    Ne lève pas d'exception, retourne simplement None.
    """
    if credentials is None:
        return None
    
    try:
        token = credentials.credentials
        payload = decode_access_token(token)
        
        if payload is None:
            return None
        
        user_id: str = payload.get("sub")
        if user_id is None:
            return None
        
        user = db.query(User).filter(User.id == user_id).first()
        if user is None or not user.is_active:
            return None
        
        return user
    except Exception:
        # En cas d'erreur, retourner None (pas d'exception pour une dépendance optionnelle)
        return None
