# Configuration Ollama sur Railway

## Étapes Rapides

### 1. Obtenir l'URL du Tunnel

Après avoir démarré ngrok (voir `GUIDE_OLLAMA_TUNNEL.md`), vous obtiendrez une URL comme :
```
https://abc123.ngrok-free.app
```

### 2. Configurer dans Railway

1. Allez sur https://railway.app
2. Sélectionnez votre projet
3. Cliquez sur votre service backend
4. Allez dans l'onglet **Variables**
5. Cliquez sur **+ New Variable**
6. Ajoutez :
   - **Name** : `OLLAMA_BASE_URL`
   - **Value** : `https://abc123.ngrok-free.app` (votre URL ngrok)
7. Cliquez sur **Add**

### 3. Redéployer

Railway redéploiera automatiquement votre service. Attendez 2-3 minutes.

### 4. Vérifier

Testez l'IA depuis votre application mobile. Si ça ne fonctionne pas :
- Vérifiez que ngrok est toujours actif
- Vérifiez les logs Railway pour voir les erreurs
- Assurez-vous que l'URL ngrok est correcte (sans `/` à la fin)

## ⚠️ Important

- L'URL ngrok change à chaque redémarrage (plan gratuit)
- Vous devrez mettre à jour la variable Railway à chaque fois
- Votre PC doit être allumé et connecté à Internet

