# 🚀 Setup Complet Automatique - Ollama Tunnel

## ⚡ Installation en 2 Commandes

### 1. Installer ngrok (Copier-Coller dans PowerShell Admin)

```powershell
# Télécharger et installer ngrok automatiquement
$ngrokPath = "$env:USERPROFILE\ngrok"
New-Item -ItemType Directory -Force -Path $ngrokPath | Out-Null
Invoke-WebRequest -Uri "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip" -OutFile "$ngrokPath\ngrok.zip"
Expand-Archive -Path "$ngrokPath\ngrok.zip" -DestinationPath $ngrokPath -Force
Remove-Item "$ngrokPath\ngrok.zip"
$env:Path += ";$ngrokPath"
[Environment]::SetEnvironmentVariable("Path", $env:Path, [EnvironmentVariableTarget]::User)
Write-Host "✅ ngrok installé dans: $ngrokPath" -ForegroundColor Green
Write-Host "⚠️ IMPORTANT: Créez un compte sur https://ngrok.com et configurez votre token:" -ForegroundColor Yellow
Write-Host "   ngrok config add-authtoken VOTRE_TOKEN" -ForegroundColor Cyan
```

### 2. Démarrer Tout Automatiquement

```powershell
cd backend
.\demarrer_ollama_tunnel.ps1
```

## 📋 Ce que le Script Fait Automatiquement

✅ Vérifie qu'Ollama est installé  
✅ Vérifie qu'ngrok est installé  
✅ Démarre Ollama automatiquement  
✅ Vérifie que le modèle est installé (le télécharge si nécessaire)  
✅ Démarre ngrok et affiche l'URL  

## 🔧 Configuration Railway (1 seule fois)

Après avoir démarré le script, vous verrez une URL comme :
```
Forwarding: https://abc123.ngrok-free.app -> http://localhost:11434
```

**Copiez cette URL** et :

1. Allez sur : https://railway.app
2. Votre Projet → Votre Service → Variables
3. Cliquez **+ New Variable**
4. Name : `OLLAMA_BASE_URL`
5. Value : `https://abc123.ngrok-free.app` (votre URL)
6. Cliquez **Add**

Railway redéploiera automatiquement (2-3 minutes).

## ✅ Vérification

Une fois Railway redéployé, testez depuis votre app mobile. L'IA devrait fonctionner !

## 🔄 Pour Chaque Nouvelle Session

Si vous fermez ngrok et que vous le redémarrez, l'URL change. Il faut :

1. Redémarrer le script
2. Copier la nouvelle URL
3. Mettre à jour la variable Railway

---

**C'est tout ! Le script fait 95% du travail automatiquement.**

