# 🔄 Solution Alternative : Cloudflare Tunnel au lieu de ngrok

## ❌ Problème avec ngrok

ngrok gratuit retourne **403 Forbidden** même avec le header `ngrok-skip-browser-warning` pour les requêtes API automatiques. Le header ne fonctionne pas correctement dans ce contexte.

## ✅ Solution : Utiliser Cloudflare Tunnel

Cloudflare Tunnel (cloudflared) est une alternative gratuite qui **ne bloque pas** les requêtes API automatiques.

### Installation

1. **Télécharger cloudflared** :
   - Windows : https://github.com/cloudflare/cloudflared/releases
   - Ou via Chocolatey : `choco install cloudflared`
   - Ou via winget : `winget install --id Cloudflare.cloudflared`

### Utilisation

1. **Arrêter ngrok** (si actif)

2. **Démarrer Cloudflare Tunnel** :
   ```powershell
   cloudflared tunnel --url http://localhost:11434
   ```

3. **Copier l'URL** :
   Vous verrez quelque chose comme :
   ```
   https://abc123-xyz.trycloudflare.com
   ```

4. **Mettre à jour Railway** :
   - Variables → `OLLAMA_BASE_URL`
   - Mettre : `https://abc123-xyz.trycloudflare.com` (sans `/` à la fin)
   - Save

5. **Attendre le redéploiement Railway** (2-3 minutes)

### Avantages de Cloudflare Tunnel

- ✅ **Gratuit**
- ✅ **Pas de 403** pour les requêtes API automatiques
- ✅ **Pas besoin de header spécial**
- ✅ **Plus simple à utiliser**

### Inconvénients

- ⚠️ **URL change à chaque démarrage** (comme ngrok gratuit)
- ⚠️ **Votre PC doit être allumé** (comme ngrok)

### Script PowerShell

Vous pouvez créer un script `demarrer_cloudflare_tunnel.ps1` :

```powershell
Write-Host "🌐 Démarrage de Cloudflare Tunnel..." -ForegroundColor Cyan
cloudflared tunnel --url http://localhost:11434
```

## 🔄 Migration depuis ngrok

1. Arrêter ngrok
2. Démarrer cloudflared
3. Mettre à jour `OLLAMA_BASE_URL` dans Railway
4. Attendre le redéploiement
5. Tester

---

**Cette solution devrait résoudre le problème de 403 !** 🎉

