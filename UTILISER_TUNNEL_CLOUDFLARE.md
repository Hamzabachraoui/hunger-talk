# 🌐 Utiliser Cloudflare Tunnel pour Ollama

## 🎯 Architecture

```
App Mobile → Railway Backend (pour tout: auth, stock, recettes)
           ↓
           Railway lit URL tunnel depuis DB (table system_config)
           ↓
           Railway appelle Ollama via Cloudflare Tunnel (https://xxx.trycloudflare.com)
           ↓
           Cloudflare Tunnel redirige vers Ollama Local (localhost:11434)
```

## 📋 Étapes d'Utilisation

### 1. Obtenir un Token JWT

**Option A : Depuis l'app mobile**
- Connectez-vous à l'app
- Le token est dans les logs

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

### 2. Définir le Token

```powershell
$env:RAILWAY_TOKEN = "votre_token_jwt_ici"
```

### 3. Exécuter le Script

```powershell
.\enregistrer_ip_ollama_auto.ps1
```

Le script va :
1. ✅ Vérifier qu'Ollama fonctionne localement
2. ✅ Démarrer Cloudflare Tunnel (expose localhost:11434)
3. ✅ Récupérer l'URL du tunnel (ex: https://xxx.trycloudflare.com)
4. ✅ Enregistrer cette URL dans Railway via l'API
5. ✅ Railway utilisera cette URL pour appeler Ollama

### 4. Garder le Tunnel Actif

⚠️ **IMPORTANT** : Gardez la fenêtre cloudflared ouverte !

Le tunnel doit rester actif pour que Railway puisse appeler Ollama. Si vous fermez la fenêtre, le tunnel s'arrête et Railway ne pourra plus appeler Ollama.

### 5. Tester

Une fois le script exécuté :
1. Vérifiez que l'URL est bien enregistrée dans Railway
2. Testez le chat dans l'app mobile
3. Railway devrait appeler Ollama via le tunnel

## 🔄 Réexécuter le Script

Si le tunnel change (nouvelle URL) ou si vous redémarrez :
1. Exécutez à nouveau `.\enregistrer_ip_ollama_auto.ps1`
2. Le script mettra à jour l'URL dans Railway automatiquement

## 📝 Notes

- Le tunnel Cloudflare "quick tunnel" est gratuit mais l'URL change à chaque démarrage
- Pour une URL permanente, créez un tunnel nommé avec un compte Cloudflare (gratuit)
- Le tunnel doit rester actif pendant toute l'utilisation
- Si le tunnel s'arrête, Railway ne pourra plus appeler Ollama

---

**Cette solution permet à Railway (cloud) d'appeler votre Ollama local via le tunnel Cloudflare !** 🎉

