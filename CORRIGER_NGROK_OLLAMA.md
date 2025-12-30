# 🔧 Correction : ngrok ne communique pas avec Ollama

## ❌ Problème

Votre erreur 502 indique que ngrok essaie de se connecter au port **80** au lieu du port **11434** (Ollama).

```
Error: dial tcp [::1]:80: connectex: Aucune connexion n'a pu être établie
```

## ✅ Solution Rapide

### Étape 1 : Arrêter ngrok (si actif)

1. Fermez la fenêtre ngrok actuelle
2. Ou tuez le processus : `taskkill /F /IM ngrok.exe`

### Étape 2 : Vérifier qu'Ollama fonctionne

Ollama est déjà en cours d'exécution sur le port 11434 ✅

Pour vérifier :
```powershell
curl http://localhost:11434/api/tags
```

### Étape 3 : Démarrer ngrok avec le BON port

Dans un terminal PowerShell, exécutez :

```powershell
ngrok http 11434
```

**⚠️ IMPORTANT :** Utilisez le port **11434** (Ollama), pas 80 !

### Étape 4 : Copier la nouvelle URL ngrok

Dans la fenêtre ngrok, vous verrez quelque chose comme :

```
Forwarding   https://abc123-def456.ngrok-free.app -> http://localhost:11434
```

**Copiez l'URL complète** : `https://abc123-def456.ngrok-free.app`

### Étape 5 : Mettre à jour Railway

1. Allez sur https://railway.app
2. Sélectionnez votre projet **Hunger-Talk**
3. Cliquez sur votre **service backend**
4. Allez dans l'onglet **Variables**
5. Trouvez la variable `OLLAMA_BASE_URL`
6. Cliquez sur **Edit** (ou supprimez et recréez-la)
7. Mettez la nouvelle URL ngrok : `https://abc123-def456.ngrok-free.app`
   - ⚠️ **PAS de `/` à la fin !**
8. Cliquez sur **Save**

### Étape 6 : Attendre le redéploiement

Railway va automatiquement redéployer votre service. Attendez **2-3 minutes**.

### Étape 7 : Tester

1. Ouvrez votre application mobile
2. Allez dans le Chat IA
3. Envoyez un message de test
4. L'IA devrait maintenant répondre ! 🎉

## 🔍 Vérification

Pour vérifier que ngrok fonctionne correctement :

```powershell
# Test 1: Vérifier qu'Ollama écoute sur 11434
netstat -ano | findstr :11434

# Test 2: Tester Ollama localement
curl http://localhost:11434/api/tags

# Test 3: Tester via ngrok (remplacez par votre URL)
curl https://votre-url-ngrok.ngrok-free.app/api/tags
```

## 📋 Checklist

- [ ] Ollama fonctionne sur localhost:11434 ✅ (déjà vérifié)
- [ ] ngrok est arrêté
- [ ] ngrok est redémarré avec `ngrok http 11434`
- [ ] URL ngrok copiée
- [ ] Variable `OLLAMA_BASE_URL` mise à jour dans Railway
- [ ] Redéploiement Railway terminé
- [ ] Application mobile testée

## ⚠️ Notes Importantes

1. **Gardez ngrok ouvert** : Ne fermez pas la fenêtre ngrok pendant que vous utilisez l'IA
2. **Gardez Ollama ouvert** : Ne fermez pas Ollama
3. **URL change** : Si vous redémarrez ngrok, l'URL change et il faudra mettre à jour Railway à nouveau
4. **Port correct** : Toujours utiliser `ngrok http 11434` pour Ollama (pas 80, pas 8000)

## 🚀 Script Automatique (Optionnel)

Vous pouvez utiliser le script fourni pour automatiser le démarrage :

```powershell
.\backend\demarrer_ollama_tunnel.ps1
```

Ce script démarre automatiquement Ollama et ngrok avec les bons paramètres.

