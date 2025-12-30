# 🚀 Utiliser Cloudflare Tunnel

## ✅ Installation Terminée

cloudflared est installé (version 2025.8.1)

## 📋 Commandes

### Démarrer le tunnel

**Option 1 : Dans un nouveau PowerShell**
```powershell
cloudflared tunnel --url http://localhost:11434
```

**Option 2 : Dans le PowerShell actuel** (PATH déjà rafraîchi)
```powershell
cloudflared tunnel --url http://localhost:11434
```

### Copier l'URL

Dans la sortie de cloudflared, vous verrez quelque chose comme :
```
+--------------------------------------------------------------------------------------------+
|  Your quick Tunnel has been created! Visit it at (it may take some time to be reachable): |
|  https://abc123-xyz.trycloudflare.com                                                      |
+--------------------------------------------------------------------------------------------+
```

**Copiez cette URL** : `https://abc123-xyz.trycloudflare.com`

### Configurer Railway

1. Allez sur https://railway.app
2. Votre projet → Service backend → Variables
3. Trouvez `OLLAMA_BASE_URL`
4. Mettez l'URL Cloudflare : `https://abc123-xyz.trycloudflare.com`
   - ⚠️ **SANS `/` à la fin !**
5. Save

### Attendre le redéploiement

Railway va redéployer automatiquement (2-3 minutes)

## ✅ Avantages vs ngrok

- ✅ **Gratuit** - 100%
- ✅ **Pas de 403** - Fonctionne avec requêtes API automatiques
- ✅ **Simple** - Une seule commande
- ✅ **Pas de header spécial** - Fonctionne directement

## ⚠️ Notes

- Gardez la fenêtre cloudflared **ouverte** pendant l'utilisation
- L'URL change à chaque démarrage (comme ngrok gratuit)
- Votre PC doit être allumé (comme ngrok)

---

**Une fois configuré dans Railway, l'IA devrait fonctionner !** 🎉

