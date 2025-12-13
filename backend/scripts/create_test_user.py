"""
Script pour créer un utilisateur de test
"""
import sys
from pathlib import Path

backend_path = Path(__file__).parent.parent
sys.path.insert(0, str(backend_path))

from database import SessionLocal
from app.models.user import User
from app.core.security import get_password_hash
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def create_test_user():
    """
    Crée un utilisateur de test si il n'existe pas déjà
    """
    db = SessionLocal()
    try:
        # Vérifier si l'utilisateur existe déjà
        test_email = "test@hungertalk.com"
        existing_user = db.query(User).filter(User.email == test_email).first()
        
        if existing_user:
            print(f"\n✅ Utilisateur de test existe déjà:")
            print(f"   Email: {test_email}")
            print(f"   ID: {existing_user.id}")
            print(f"   Prénom: {existing_user.first_name}")
            print(f"   Nom: {existing_user.last_name}")
            return existing_user
        
        # Créer l'utilisateur de test
        print("\n📝 Création de l'utilisateur de test...")
        test_user = User(
            email=test_email,
            password_hash=get_password_hash("Test1234!"),
            first_name="Test",
            last_name="User"
        )
        
        db.add(test_user)
        db.commit()
        db.refresh(test_user)
        
        print(f"\n✅ Utilisateur de test créé avec succès!")
        print(f"   Email: {test_email}")
        print(f"   Mot de passe: Test1234!")
        print(f"   ID: {test_user.id}")
        print(f"   Prénom: {test_user.first_name}")
        print(f"   Nom: {test_user.last_name}")
        
        return test_user
        
    except Exception as e:
        logger.error(f"Erreur lors de la création de l'utilisateur de test: {e}")
        db.rollback()
        print(f"\n❌ Erreur: {e}")
        return None
    finally:
        db.close()

if __name__ == "__main__":
    create_test_user()

