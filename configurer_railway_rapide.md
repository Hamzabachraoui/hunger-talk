# ⚡ Configuration Railway - Version Rapide

## 🎯 Étapes Essentielles (5 minutes)

### 1. Créer le Projet
- Va sur [railway.app](https://railway.app) → Login avec GitHub
- **New Project** → **Deploy from GitHub repo** → Sélectionne `hunger-talk`

### 2. Configurer le Service
- Clique sur le service → **Settings** → **Root Directory** : `backend`

### 3. Ajouter PostgreSQL
- **+ New** → **Database** → **Add PostgreSQL**

### 4. Variables d'Environnement
Dans **Variables**, ajoute :

```
DATABASE_URL = ${{Postgres.DATABASE_URL}}
SECRET_KEY = [génère avec: python -c "import secrets; print(secrets.token_urlsafe(32))"]
ENVIRONMENT = production
```

### 5. Obtenir l'URL
- **Settings** → **Generate Domain** → Copie l'URL (ex: `https://ton-app.up.railway.app`)

### 6. Mettre à Jour l'App Mobile
Dans `mobile/lib/core/config/app_config.dart`, ligne ~30 :
```dart
_defaultServerUrl = 'https://ton-app.up.railway.app'; // <-- TON URL ICI
```

---

## ✅ Test Rapide
Ouvre dans le navigateur : `https://ton-app.up.railway.app/docs`

Si tu vois Swagger → ✅ Ça marche !
