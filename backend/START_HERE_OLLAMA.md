# 🚀 DÉMARRAGE RAPIDE - OLLAMA TUNNEL

## ⚡ 2 Commandes, C'est Tout !

### 1️⃣ Première fois seulement : Installer ngrok

**Ouvrez PowerShell en Administrateur** et copiez-collez :

```powershell
$ngrokPath = "$env:USERPROFILE\ngrok"
New-Item -ItemType Directory -Force -Path $ngrokPath | Out-Null
Invoke-WebRequest -Uri "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip" -OutFile "$ngrokPath\ngrok.zip"
Expand-Archive -Path "$ngrokPath\ngrok.zip" -DestinationPath $ngrokPath -Force
Remove-Item "$ngrokPath\ngrok.zip"
$env:Path += ";$ngrokPath"
Write-Host "✅ ngrok installé! Créez un compte sur https://ngrok.com et configurez: ngrok config add-authtoken VOTRE_TOKEN"
```

**Ensuite, configurez votre token ngrok** (une seule fois) :
1. Créez un compte gratuit : https://ngrok.com
2. Récupérez votre token
3. Exécutez : `ngrok config add-authtoken VOTRE_TOKEN`

### 2️⃣ Démarrer tout automatiquement

```powershell
cd backend
.\demarrer_ollama_tunnel.ps1
```

**Le script fait TOUT automatiquement :**
- ✅ Vérifie/installe Ollama
- ✅ Démarre Ollama
- ✅ Vérifie/télécharge le modèle
- ✅ Démarre ngrok
- ✅ Affiche l'URL

### 3️⃣ Configurer Railway (1 minute)

1. **Notez l'URL** affichée dans la fenêtre ngrok (ex: `https://abc123.ngrok-free.app`)
2. Allez sur **Railway Dashboard** → Votre Service → **Variables**
3. Ajoutez : `OLLAMA_BASE_URL` = `https://abc123.ngrok-free.app`
4. Attendez 2-3 minutes (redéploiement automatique)

### ✅ C'est Fait !

Testez depuis votre app mobile. L'IA devrait fonctionner ! 🎉

---

## 🔄 Pour les prochaines fois

Juste exécutez :
```powershell
cd backend
.\demarrer_ollama_tunnel.ps1
```

Puis mettez à jour l'URL dans Railway si elle a changé.

---

**C'est vraiment tout ! Le script fait 95% du travail.**

