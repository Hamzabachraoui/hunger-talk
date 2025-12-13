"""
Service pour interagir avec Ollama
"""
import httpx
from typing import Optional, Dict, Any
from config import settings
import logging

logger = logging.getLogger(__name__)


class OllamaService:
    """Service pour communiquer avec Ollama"""
    
    def __init__(self):
        self.base_url = settings.OLLAMA_BASE_URL
        self.model = settings.OLLAMA_MODEL
        self.timeout = 120.0  # 2 minutes pour les réponses longues
    
    async def generate(
        self, 
        prompt: str, 
        system_prompt: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 2000
    ) -> Dict[str, Any]:
        """
        Générer une réponse avec Ollama
        
        Args:
            prompt: Le prompt utilisateur
            system_prompt: Le prompt système (instructions pour l'IA)
            temperature: Contrôle la créativité (0.0-1.0)
            max_tokens: Nombre maximum de tokens à générer
        
        Returns:
            Dict avec la réponse et les métadonnées
        """
        try:
            # Construire le message complet
            messages = []
            if system_prompt:
                messages.append({
                    "role": "system",
                    "content": system_prompt
                })
            messages.append({
                "role": "user",
                "content": prompt
            })
            
            # Préparer la requête
            payload = {
                "model": self.model,
                "messages": messages,
                "stream": False,
                "options": {
                    "temperature": temperature,
                    "num_predict": max_tokens
                }
            }
            
            # Appel à Ollama
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(
                    f"{self.base_url}/api/chat",
                    json=payload
                )
                response.raise_for_status()
                result = response.json()
                
                return {
                    "response": result.get("message", {}).get("content", ""),
                    "model": result.get("model", self.model),
                    "done": result.get("done", True),
                    "total_duration": result.get("total_duration", 0),
                    "load_duration": result.get("load_duration", 0),
                    "prompt_eval_count": result.get("prompt_eval_count", 0),
                    "eval_count": result.get("eval_count", 0)
                }
                
        except httpx.TimeoutException:
            logger.error("Timeout lors de l'appel à Ollama")
            raise Exception("L'IA prend trop de temps à répondre. Veuillez réessayer.")
        except httpx.ConnectError:
            logger.error(f"Impossible de se connecter à Ollama à {self.base_url}")
            raise Exception("L'IA n'est pas disponible. Vérifiez qu'Ollama est démarré.")
        except httpx.HTTPStatusError as e:
            logger.error(f"Erreur HTTP lors de l'appel à Ollama: {e}")
            raise Exception(f"Erreur lors de la communication avec l'IA: {e.response.status_code}")
        except Exception as e:
            logger.error(f"Erreur inattendue avec Ollama: {e}")
            raise Exception(f"Erreur lors de l'appel à l'IA: {str(e)}")
    
    async def check_availability(self) -> bool:
        """
        Vérifier si Ollama est disponible
        
        Returns:
            True si Ollama est disponible, False sinon
        """
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                response = await client.get(f"{self.base_url}/api/tags")
                return response.status_code == 200
        except:
            return False


# Instance globale du service
ollama_service = OllamaService()

