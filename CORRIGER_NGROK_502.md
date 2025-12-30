# 🔧 Correction Erreur 502 Bad Gateway avec ngrok

## ❌ Problème Identifié

L'erreur indique que ngrok essaie de se connecter à `localhost:80`, mais votre serveur FastAPI écoute sur le port **8000**, pas 80.

```
Error: dial tcp [::1]:80: connectex: Aucune connexion n'a pu être établie
```

## ✅ Solution

### Étape 1 : Arrêter ngrok (si actif)

1. Fermez la fenêtre/processus ngrok actuel
2. Ou tuez le processus : `taskkill /F /IM ngrok.exe`

### Étape 2 : Démarrer le serveur FastAPI

Dans un terminal PowerShell (depuis la racine du projet) :

```powershell
.\demarrer_serveur.ps1
```

Ou manuellement :

```powershell
cd backend
.\venv\Scripts\Activate.ps1
python main.py
```

Vérifiez que le serveur démarre correctement. Vous devriez voir :
```
INFO:     Uvicorn running on http://0.0.0.0:8000
```

### Étape 3 : Redémarrer ngrok avec le bon port

Dans un **nouveau terminal PowerShell**, exécutez :

```powershell
ngrok http 8000
```

**⚠️ IMPORTANT** : Utilisez le port **8000**, pas 80 !

### Étape 4 : Vérifier que ça fonctionne

1. Dans la fenêtre ngrok, notez l'URL Forwarding (ex: `https://abc123.ngrok-free.app`)
2. Testez dans votre navigateur : `https://votre-url-ngrok.ngrok-free.app/health`
3. Vous devriez voir : `{"status":"healthy",...}`

### Étape 5 : Mettre à jour la configuration mobile (si nécessaire)

Si votre application mobile utilise l'URL ngrok, mettez à jour la configuration avec la nouvelle URL ngrok.

## 🎯 Commandes Rapides

**Terminal 1 - Serveur FastAPI :**
```powershell
cd backend
.\venv\Scripts\Activate.ps1
python main.py
```

**Terminal 2 - Ngrok :**
```powershell
ngrok http 8000
```

## 📝 Notes

- Le port 80 nécessite des privilèges administrateur sous Windows
- Le port 8000 est le port par défaut de FastAPI/Uvicorn
- Si vous fermez et redémarrez ngrok, l'URL change (plan gratuit)
- Gardez les deux terminaux ouverts pendant l'utilisation

## ✅ Vérification

Pour vérifier que tout fonctionne :

```powershell
# Test 1: Vérifier que le serveur écoute sur 8000
netstat -ano | findstr :8000

# Test 2: Tester l'API localement
curl http://localhost:8000/health

# Test 3: Tester via ngrok (remplacez par votre URL)
curl https://votre-url-ngrok.ngrok-free.app/health
```

