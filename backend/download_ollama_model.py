"""
Script pour télécharger le modèle Ollama llama3.1:8b
"""
import requests
import json
import sys

OLLAMA_URL = "http://localhost:11434"

def download_model(model_name: str = "llama3.1:8b"):
    """Télécharger un modèle Ollama"""
    print(f"📥 Téléchargement du modèle {model_name}...")
    print("⏳ Cela peut prendre plusieurs minutes (le modèle fait ~4.7 GB)...")
    print()
    
    try:
        # Vérifier que Ollama est disponible
        response = requests.get(f"{OLLAMA_URL}/api/tags", timeout=5)
        if response.status_code != 200:
            print("❌ Ollama n'est pas disponible. Assurez-vous qu'Ollama est démarré.")
            return False
        
        # Télécharger le modèle
        payload = {"name": model_name}
        response = requests.post(
            f"{OLLAMA_URL}/api/pull",
            json=payload,
            stream=True,
            timeout=None  # Pas de timeout pour le téléchargement
        )
        
        if response.status_code != 200:
            print(f"❌ Erreur lors du téléchargement: {response.status_code}")
            print(response.text)
            return False
        
        # Afficher la progression
        print("📊 Progression du téléchargement:")
        print("-" * 60)
        
        for line in response.iter_lines():
            if line:
                try:
                    data = json.loads(line)
                    
                    if "status" in data:
                        status = data["status"]
                        if "digesting" in status or "pulling" in status:
                            print(f"   {status}")
                        elif "downloading" in status:
                            if "completed" in data and "total" in data:
                                completed = data.get("completed", 0)
                                total = data.get("total", 0)
                                if total > 0:
                                    percent = (completed / total) * 100
                                    print(f"   Téléchargement: {percent:.1f}% ({completed}/{total} bytes)")
                    
                    if data.get("status") == "success":
                        print("\n✅ Modèle téléchargé avec succès !")
                        return True
                        
                except json.JSONDecodeError:
                    continue
        
        print("\n✅ Téléchargement terminé !")
        return True
        
    except requests.exceptions.ConnectionError:
        print("❌ Impossible de se connecter à Ollama.")
        print("   Assurez-vous qu'Ollama est démarré et accessible sur http://localhost:11434")
        return False
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False

def check_model(model_name: str = "llama3.1:8b"):
    """Vérifier si le modèle est installé"""
    try:
        response = requests.get(f"{OLLAMA_URL}/api/tags", timeout=5)
        if response.status_code == 200:
            data = response.json()
            models = [model.get("name", "") for model in data.get("models", [])]
            
            # Vérifier si le modèle exact ou une variante est installée
            for model in models:
                if model_name in model or model in model_name:
                    print(f"✅ Modèle trouvé: {model}")
                    return True
            
            print(f"❌ Modèle {model_name} non trouvé.")
            print(f"   Modèles installés: {', '.join(models) if models else 'Aucun'}")
            return False
    except Exception as e:
        print(f"❌ Erreur lors de la vérification: {e}")
        return False

def main():
    model_name = "llama3.1:8b"
    
    print("=" * 60)
    print("  TÉLÉCHARGEMENT DU MODÈLE OLLAMA")
    print("=" * 60)
    print()
    
    # Vérifier d'abord si le modèle existe déjà
    print("🔍 Vérification des modèles installés...")
    if check_model(model_name):
        print("\n✅ Le modèle est déjà installé !")
        return 0
    
    print()
    
    # Télécharger le modèle
    success = download_model(model_name)
    
    if success:
        print()
        print("=" * 60)
        print("✅ TÉLÉCHARGEMENT RÉUSSI !")
        print("=" * 60)
        print()
        print("💡 Vous pouvez maintenant tester l'API chat:")
        print("   http://localhost:8000/docs")
        print()
        return 0
    else:
        print()
        print("=" * 60)
        print("❌ ÉCHEC DU TÉLÉCHARGEMENT")
        print("=" * 60)
        print()
        print("💡 Vérifiez que:")
        print("   1. Ollama est démarré")
        print("   2. Vous avez une connexion Internet")
        print("   3. Vous avez assez d'espace disque (~5 GB)")
        return 1

if __name__ == "__main__":
    sys.exit(main())

