# 🔧 Correction Erreur 403 Forbidden de ngrok

## ❌ Problème

ngrok retourne une erreur **403 Forbidden** lorsque Railway essaie d'accéder à Ollama via le tunnel ngrok.

```
HTTP/1.1 403 Forbidden
Date: Tue, 30 Dec 2025 12:11:22 GMT
Content-Length: 0
```

## 🔍 Cause

Sur le plan gratuit de ngrok, une page d'avertissement de sécurité bloque les requêtes automatisées. Cette page demande une confirmation dans le navigateur, ce que Railway ne peut pas faire.

## ✅ Solution Appliquée

J'ai modifié le service Ollama (`backend/app/services/ollama_service.py`) pour ajouter le header `ngrok-skip-browser-warning` dans toutes les requêtes vers ngrok.

Ce header indique à ngrok de ne pas afficher la page d'avertissement et permet aux requêtes automatisées de passer.

### Modifications Effectuées

1. **Dans la méthode `generate()`** : Ajout du header pour les requêtes POST vers `/api/chat`
2. **Dans la méthode `check_availability()`** : Ajout du header pour les requêtes GET vers `/api/tags`

Le header est ajouté automatiquement seulement si l'URL contient "ngrok" ou "ngrok-free.dev".

## 📋 Prochaines Étapes

1. **Redéployer sur Railway** :
   - Les modifications sont dans le code
   - Railway devrait redéployer automatiquement si vous avez activé le déploiement automatique
   - Sinon, poussez les changements sur GitHub ou redéployez manuellement

2. **Vérifier que ngrok fonctionne** :
   - Assurez-vous que ngrok est toujours actif avec `ngrok http 11434`
   - Vérifiez que l'URL ngrok dans Railway (`OLLAMA_BASE_URL`) est correcte

3. **Tester** :
   - Ouvrez votre application mobile
   - Allez dans le Chat IA
   - Envoyez un message de test
   - L'IA devrait maintenant répondre ! 🎉

## 🔍 Vérification

Pour vérifier que tout fonctionne :

1. **Vérifier les logs Railway** :
   - Allez dans Railway → Votre service → Deployments → Dernier déploiement → Logs
   - Vous devriez voir : `✅ Ollama est accessible à https://votre-url-ngrok.ngrok-free.app`

2. **Tester manuellement** (depuis votre machine) :
   ```powershell
   curl -H "ngrok-skip-browser-warning: true" https://votre-url-ngrok.ngrok-free.app/api/tags
   ```
   Vous devriez recevoir une réponse JSON avec la liste des modèles Ollama.

## ⚠️ Notes Importantes

- **Gardez ngrok ouvert** : Ne fermez pas la fenêtre ngrok pendant que vous utilisez l'IA
- **Gardez Ollama ouvert** : Ne fermez pas Ollama
- **URL change** : Si vous redémarrez ngrok, l'URL change et il faudra mettre à jour Railway
- **Header automatique** : Le header `ngrok-skip-browser-warning` est ajouté automatiquement, vous n'avez rien à configurer

## 🚀 Si ça ne fonctionne toujours pas

1. Vérifiez que les modifications sont bien déployées sur Railway
2. Vérifiez les logs Railway pour voir les erreurs exactes
3. Vérifiez que ngrok pointe bien vers le port 11434 : `ngrok http 11434`
4. Testez manuellement avec curl pour confirmer que ngrok fonctionne

