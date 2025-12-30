"""
Script Python pour enregistrer l'IP Ollama localement dans la base de données
"""
import sys
from pathlib import Path

# Ajouter le chemin backend
backend_path = Path(__file__).parent / "backend"
sys.path.insert(0, str(backend_path))

from database import SessionLocal
from app.services.system_config_service import set_ollama_base_url

# Détecter l'IP locale (simplifié - prend la première IP 192.168.*)
import socket

def get_local_ip():
    """Trouve l'IP locale"""
    try:
        # Se connecter à une adresse externe (ne fait pas vraiment de connexion)
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "192.168.11.101"  # Valeur par défaut si la détection échoue

local_ip = get_local_ip()
ollama_url = f"http://{local_ip}:11434"

print(f"📍 IP locale détectée: {local_ip}")
print(f"🔗 URL Ollama: {ollama_url}")
print("")

db = SessionLocal()
try:
    config = set_ollama_base_url(db, ollama_url)
    print(f"✅ IP Ollama enregistrée avec succès !")
    print(f"   Clé: {config.key}")
    print(f"   Valeur: {config.value}")
    print(f"   Mis à jour: {config.updated_at}")
except Exception as e:
    print(f"❌ Erreur: {e}")
    sys.exit(1)
finally:
    db.close()

