# 📋 Instructions Finales - IP Ollama Automatique

## 🎯 Architecture

```
App Mobile → Railway Backend (pour tout: auth, stock, recettes, etc.)
           ↓
           Railway lit IP Ollama depuis DB (table system_config)
           ↓
           Railway appelle Ollama Local avec cette IP
```

**Important** : L'app mobile continue d'appeler Railway normalement. Seul l'appel à Ollama utilise l'IP locale.

## ✅ Ce qui est Déjà Fait

1. ✅ Table `system_config` créée dans Railway (via migration)
2. ✅ Endpoint API `/api/system-config/ollama/base-url` créé
3. ✅ Backend Railway récupère l'IP depuis la DB avant d'appeler Ollama
4. ✅ Script PowerShell `enregistrer_ip_ollama_auto.ps1` créé

## 📋 Étapes pour Mettre en Place

### 1. Obtenir un Token JWT

Vous avez besoin d'un token JWT pour appeler l'API Railway.

**Option A : Depuis l'app mobile**

1. Connectez-vous à l'app mobile
2. Le token est stocké dans le storage de l'app
3. Récupérez-le depuis les logs ou le code

**Option B : Via l'API Login**

```powershell
$loginBody = @{
    email = "votre_email@example.com"
    password = "votre_password"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "https://hunger-talk-production.up.railway.app/api/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$token = $loginResponse.access_token
Write-Host "Token: $token"
```

### 2. Définir le Token comme Variable d'Environnement

```powershell
# Pour la session actuelle
$env:RAILWAY_TOKEN = "votre_token_jwt_ici"

# Pour le rendre permanent (dans votre profil PowerShell)
[System.Environment]::SetEnvironmentVariable("RAILWAY_TOKEN", "votre_token_jwt_ici", "User")
```

### 3. Exécuter le Script d'Enregistrement

```powershell
.\enregistrer_ip_ollama_auto.ps1
```

Le script va :
1. Détecter votre IP locale (ex: 192.168.11.101)
2. Vérifier qu'Ollama fonctionne
3. Enregistrer l'IP dans Railway via l'API

### 4. Vérifier que l'IP est Enregistrée

```powershell
# Vérifier via l'API (nécessite token)
$token = $env:RAILWAY_TOKEN
$headers = @{"Authorization" = "Bearer $token"}
$config = Invoke-RestMethod -Uri "https://hunger-talk-production.up.railway.app/api/system-config/ollama" -Method Get -Headers $headers
Write-Host "IP Ollama: $($config.ollama_base_url)"
```

## 🔄 Automatiser l'Enregistrement

Pour enregistrer automatiquement l'IP au démarrage du PC :

### Créer une Tâche Planifiée Windows

```powershell
# Exécuter en tant qu'administrateur
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"$PWD\enregistrer_ip_ollama_auto.ps1`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive
Register-ScheduledTask -TaskName "Enregistrer IP Ollama dans Railway" -Action $action -Trigger $trigger -Principal $principal
```

## ⚠️ Point Important

**Railway (cloud) ne peut pas accéder directement à votre IP locale privée (192.168.11.101) depuis le cloud.**

Pour que Railway puisse appeler votre Ollama local, vous avez deux options :

### Option 1 : Utiliser un Tunnel (ngrok, Cloudflare)

1. Démarrer un tunnel qui expose Ollama :
   ```powershell
   cloudflared tunnel --url http://localhost:11434
   ```

2. Enregistrer l'URL du tunnel (ex: https://xxx.trycloudflare.com) dans Railway au lieu de l'IP locale

### Option 2 : Service Proxy Local

Créer un service local qui :
- Écoute sur un port public (via tunnel)
- Redirige les requêtes vers Ollama local

## 📝 Résumé du Flux

1. **Script local** détecte IP → Enregistre dans Railway DB
2. **Backend Railway** lit IP depuis DB → Appelle Ollama avec cette IP
3. **App mobile** appelle Railway normalement → Railway gère tout

---

**Note** : Pour que Railway puisse réellement appeler votre Ollama local, il faut un tunnel ou un proxy, car Railway est dans le cloud et ne peut pas accéder aux IPs locales privées.

