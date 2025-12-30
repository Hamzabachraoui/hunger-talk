# 📋 Implémentation Architecture Hybride

## 🎯 Objectif

**Architecture hybride** :
- Railway : Backend (auth, stock, recettes, etc.)
- Ollama Local : Appelé directement depuis l'app mobile (via WiFi local)

## 📝 Plan d'Implémentation

### 1. Service Ollama dans l'App Mobile

Créer `mobile/lib/data/services/ollama_service.dart` :
- Récupère l'IP Ollama depuis Railway (`/api/system-config/ollama`)
- Appelle Ollama directement via HTTP
- Gère les erreurs de connexion

### 2. Modification du ChatService

Modifier `mobile/lib/data/services/chat_service.dart` :
- Option A : Appeler Ollama directement (simple, mais perd le contexte RAG)
- Option B : Récupérer le contexte depuis Railway, puis appeler Ollama (meilleur)

### 3. Option Recommandée : Hybride avec Contexte

Pour garder le contexte RAG (stock, recettes, etc.) :

1. **L'app appelle Railway pour obtenir le contexte** :
   ```
   POST /api/chat/context
   → Retourne : {"context": "Stock: lait, oeufs... Recettes: ..."}
   ```

2. **L'app appelle Ollama directement avec le contexte** :
   ```
   POST http://192.168.11.101:11434/api/chat
   → Message + Contexte
   ```

3. **Optionnel : L'app sauvegarde dans Railway** :
   ```
   POST /api/chat/save
   → Sauvegarde le message et la réponse
   ```

### 4. Option Simple : Appel Direct (Sans Contexte)

Si vous voulez juste un chat simple sans contexte RAG :

1. L'app récupère l'IP Ollama depuis Railway
2. L'app appelle Ollama directement
3. Pas de contexte (pas de stock, recettes, etc.)

**Avantage** : Plus simple, plus rapide
**Inconvénient** : Perd le contexte (pas de recommandations basées sur le stock)

## 🔄 Flux Recommandé (Avec Contexte)

```
1. Utilisateur envoie un message
   ↓
2. App appelle Railway : POST /api/chat/context
   → Railway construit le contexte RAG (stock, recettes, etc.)
   → Retourne le contexte
   ↓
3. App récupère l'IP Ollama depuis Railway (cachée)
   ↓
4. App appelle Ollama directement : POST http://IP:11434/api/chat
   → Message + Contexte
   → Ollama répond
   ↓
5. Optionnel : App sauvegarde dans Railway : POST /api/chat/save
```

## 📝 Modifications Nécessaires

### Backend Railway

Créer un endpoint pour obtenir juste le contexte :
```python
@router.post("/chat/context")
async def get_chat_context(
    chat_data: ChatMessageCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Retourne le contexte RAG sans appeler Ollama"""
    rag_service = RAGService(db, current_user)
    context = rag_service.build_full_context(chat_data.message)
    system_prompt = rag_service.build_system_prompt()
    return {
        "context": context,
        "system_prompt": system_prompt
    }
```

### App Mobile

1. Créer `OllamaService` (déjà fait)
2. Modifier `ChatService` pour utiliser `OllamaService`
3. Récupérer le contexte depuis Railway avant d'appeler Ollama

---

**Recommandation** : Option Hybride avec Contexte pour garder toutes les fonctionnalités RAG !

