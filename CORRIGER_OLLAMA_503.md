# 🔧 Corriger l'Erreur 503 - Ollama Non Disponible

## ❌ Problème

L'erreur 503 indique que Railway ne peut pas se connecter à Ollama via ngrok :
```
"L'IA n'est pas disponible. Vérifiez qu'Ollama est démarré et que le modèle est installé."
```

## 🔍 Diagnostic

Le backend vérifie la disponibilité d'Ollama avant d'envoyer le message. Si la connexion échoue, il retourne 503.

## ✅ Solution Étape par Étape

### 1. Vérifier qu'Ollama fonctionne localement

```powershell
# Vérifier qu'Ollama est en cours d'exécution
Get-Process -Name ollama -ErrorAction SilentlyContinue

# Tester Ollama localement
curl http://localhost:11434/api/tags
```

Si Ollama n'est pas démarré :
```powershell
ollama serve
```

### 2. Démarrer ngrok avec le bon port

```powershell
ngrok http 11434
```

**⚠️ IMPORTANT** : Utilisez le port **11434** (Ollama), pas 80 ni 8000 !

### 3. Copier l'URL ngrok

Dans la fenêtre ngrok, vous verrez :
```
Forwarding   https://abc123-def456.ngrok-free.app -> http://localhost:11434
```

**Copiez l'URL complète** : `https://abc123-def456.ngrok-free.app`

### 4. Mettre à jour Railway

1. Allez sur https://railway.app
2. Sélectionnez votre projet **Hunger-Talk**
3. Cliquez sur votre **service backend**
4. Allez dans l'onglet **Variables**
5. Trouvez la variable `OLLAMA_BASE_URL`
6. Cliquez sur **Edit**
7. Mettez la nouvelle URL ngrok : `https://abc123-def456.ngrok-free.app`
   - ⚠️ **PAS de `/` à la fin !**
8. Cliquez sur **Save**

### 5. Attendre le redéploiement

Railway va automatiquement redéployer. Attendez **2-3 minutes**.

### 6. Vérifier les logs Railway

1. Allez dans **Deployments** → Dernier déploiement → **Logs**
2. Cherchez : `✅ Ollama est accessible à https://...`
3. Si vous voyez `❌ Impossible de se connecter`, vérifiez :
   - ngrok est toujours actif
   - L'URL dans Railway est correcte (sans `/` à la fin)
   - Ollama fonctionne sur localhost:11434

### 7. Tester manuellement

Testez depuis votre machine que ngrok fonctionne :
```powershell
curl -H "ngrok-skip-browser-warning: true" https://votre-url-ngrok.ngrok-free.app/api/tags
```

Vous devriez recevoir une réponse JSON avec la liste des modèles Ollama.

## 🔄 Si ça ne fonctionne toujours pas

### Vérifier que Railway a bien redéployé

1. Vérifiez les logs Railway pour voir si le code avec le header `ngrok-skip-browser-warning` est déployé
2. Si Railway n'a pas redéployé, poussez les modifications sur GitHub :
   ```powershell
   cd "G:\EMSI\3eme annee\PFA"
   git add backend/app/services/ollama_service.py
   git commit -m "Fix: Ajout header ngrok-skip-browser-warning"
   git push origin main
   ```

### Vérifier l'URL ngrok

- L'URL ngrok change à chaque redémarrage (plan gratuit)
- Si vous avez redémarré ngrok, mettez à jour Railway avec la nouvelle URL

### Vérifier Ollama

- Assurez-vous que le modèle `llama3.1:8b` est installé :
  ```powershell
  ollama list
  ```
- Si le modèle n'est pas installé :
  ```powershell
  ollama pull llama3.1:8b
  ```

## 📋 Checklist

- [ ] Ollama fonctionne sur localhost:11434
- [ ] ngrok est actif avec `ngrok http 11434`
- [ ] URL ngrok copiée (sans `/` à la fin)
- [ ] Variable `OLLAMA_BASE_URL` mise à jour dans Railway
- [ ] Railway a redéployé (attendre 2-3 minutes)
- [ ] Logs Railway montrent "✅ Ollama est accessible"
- [ ] Test manuel avec curl fonctionne

## ⚠️ Notes Importantes

1. **Gardez ngrok ouvert** : Ne fermez pas la fenêtre ngrok
2. **Gardez Ollama ouvert** : Ne fermez pas Ollama
3. **URL change** : Si vous redémarrez ngrok, l'URL change → mettez à jour Railway
4. **Railway doit redéployer** : Après modification de `OLLAMA_BASE_URL`, attendez le redéploiement

---

Une fois tout configuré, l'IA devrait répondre ! 🎉

