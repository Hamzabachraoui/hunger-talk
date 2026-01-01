# 🔑 Comment Obtenir le Token JWT

Vous avez plusieurs options pour obtenir votre token JWT :

## Méthode 1 : Depuis les Logs de l'App (Recommandé) ✅

Quand l'app mobile s'exécute, le token est affiché dans les logs.

### Étapes :

1. **Ouvrez l'app mobile** sur votre téléphone (connecté en USB) ou sur un émulateur

2. **Ouvrez les logs Flutter** :
   ```powershell
   flutter logs
   ```
   
   OU si l'app tourne déjà, regardez la console/logcat

3. **Cherchez une ligne comme** :
   ```
   ✅ [API] Token lu depuis le storage (eyJhbGciOiJIUzI1NiIs...)
   ```
   
   Le token complet commence par `eyJhbGciOiJIUzI1NiIs...` et est très long.

4. **Copiez le token complet** (tout le texte après "Bearer " ou depuis le début si c'est le token brut)

### Exemple :
Dans vos logs précédents, vous avez vu :
```
🔑 [API] Token présent dans headers (eyJhbGciOiJIUzI1NiIsInR...)
```

Le token complet est la longue chaîne qui suit. Vous pouvez aussi le voir dans :
```
✅ [API] Token lu depuis le storage (eyJhbGciOiJIUzI1NiIs...)
```

## Méthode 2 : Depuis les Logs Réseau de l'App

1. **Ouvrez l'app mobile**
2. **Ouvrez le chat et envoyez un message**
3. **Regardez les logs** - vous verrez :
   ```
   🔑 Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdW...
   ```
4. **Copiez tout le token** (la longue chaîne qui commence par `eyJ`)

## Méthode 3 : Se Connecter à Nouveau

Si vous ne trouvez pas le token dans les logs :

1. **Déconnectez-vous de l'app**
2. **Reconnectez-vous**
3. **Immédiatement après la connexion**, cherchez dans les logs :
   ```
   ✅✅✅ [AUTH PROVIDER] Token vérifié dans le storage (eyJhbGciOiJIUzI1NiIs...)
   ```
4. **Copiez le token**

## 📋 Utiliser le Token

Une fois que vous avez le token, utilisez-le ainsi :

```powershell
.\enregistrer_ip_ollama_rapide.ps1 -Token "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5ZjQwNmMzOS1lY2VkLTRjN2ItYTM2OC02N2QwMTQyOTZjZjEiLCJleHAiOjE3MzU2MTg3MjB9..."
```

⚠️ **Important** : 
- Le token est très long (plusieurs centaines de caractères)
- Copiez-le **en entier**
- Ne le partagez jamais publiquement (c'est votre identifiant de session)

## 🎯 Alternative : Utiliser curl ou Postman

Si vous préférez, vous pouvez aussi utiliser curl directement :

```powershell
# 1. Récupérer votre IP
$ip = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.*" -and $_.IPAddress -notlike "*.1" } | Select-Object -First 1 -ExpandProperty IPAddress
$url = "http://$ip:11434"

# 2. Enregistrer (remplacez TOKEN_JWT)
$token = "VOTRE_TOKEN_JWT"
$encodedUrl = [System.Web.HttpUtility]::UrlEncode($url)
Invoke-RestMethod -Uri "https://hunger-talk-production.up.railway.app/api/system-config/ollama/base-url?value=$encodedUrl" -Method Put -Headers @{"Authorization"="Bearer $token"}
```

---

**Conseil** : La méthode la plus simple est de regarder les logs pendant que l'app tourne ! 📱

