# 📦 Informations Railway - Hunger Talk

## 🔑 Variables d'Environnement Requises

### Obligatoires

```bash
DATABASE_URL=${{Postgres.DATABASE_URL}}  # Railway génère automatiquement
SECRET_KEY=3ocryCtmmAx32FUvLhHj3KD58E359TvaYT-jB2487XM  # Générée (à régénérer si besoin)
ENVIRONMENT=production
PORT=${{PORT}}  # Railway définit automatiquement
```

### Optionnelles

```bash
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3.1:8b
DEBUG=False
```

---

## 📁 Configuration Railway

- **Root Directory** : `backend`
- **Build Command** : Automatique (NIXPACKS détecte Python)
- **Start Command** : `uvicorn main:app --host 0.0.0.0 --port $PORT`

---

## 🔗 URLs Importantes

- **Repository GitHub** : https://github.com/Hamzabachraoui/hunger-talk
- **Railway Dashboard** : https://railway.app
- **URL de Production** : `https://ton-app.up.railway.app` (à remplacer après déploiement)

---

## 📝 Checklist Rapide

1. ✅ Repository GitHub créé et code poussé
2. ⏳ Créer compte Railway
3. ⏳ Créer projet et connecter GitHub
4. ⏳ Configurer Root Directory = `backend`
5. ⏳ Ajouter PostgreSQL
6. ⏳ Configurer variables d'environnement
7. ⏳ Obtenir URL publique
8. ⏳ Mettre à jour `app_config.dart` avec l'URL Railway

---

## 🛠️ Commandes Utiles

### Générer une nouvelle SECRET_KEY
```powershell
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

Ou utilise le script :
```powershell
.\generer_secret_key.ps1
```

### Vérifier les logs Railway
Dans Railway Dashboard → Service → Deployments → Logs

---

## 🎯 Prochaine Étape

Une fois Railway configuré et l'URL obtenue, mets à jour :
- `mobile/lib/core/config/app_config.dart` ligne ~30 avec l'URL Railway
