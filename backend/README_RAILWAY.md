# 🚂 Configuration Railway - Hunger-Talk Backend

## 📁 Fichiers de Configuration Créés

### ✅ Fichiers Nécessaires pour Railway

1. **`railway.json`** - Configuration Railway
2. **`Procfile`** - Commande de démarrage
3. **`runtime.txt`** - Version Python
4. **`.railwayignore`** - Fichiers à ignorer

### 📝 Modifications Apportées

1. **`main.py`** - Utilise maintenant `PORT` depuis l'environnement (Railway)
2. **`config.py`** - CORS accepte `*` pour production

---

## 🚀 Déploiement Rapide

### 1. Générer SECRET_KEY

```bash
cd backend
python generate_secret_key.py
```

Copie la clé générée.

### 2. Sur Railway

1. **Créer le projet** depuis GitHub
2. **Ajouter PostgreSQL** (Database)
3. **Configurer les variables** :
   - `SECRET_KEY` = (la clé générée)
   - `ALLOWED_ORIGINS` = `*`
   - `ENVIRONMENT` = `production`
   - `DEBUG` = `False`

4. **Railway déploie automatiquement !**

### 3. Récupérer l'URL

Dans Railway → Service → Settings → Networking
URL : `https://ton-app.up.railway.app`

### 4. Mettre à jour l'App

Dans `mobile/lib/core/config/app_config.dart` :
```dart
defaultValue: 'https://ton-app.up.railway.app',
```

---

## ✅ Vérification

Teste l'API :
```
https://ton-app.up.railway.app/health
https://ton-app.up.railway.app/docs
```

---

## 📚 Documentation Complète

Voir `DEPLOIEMENT_RAILWAY.md` pour le guide complet.
