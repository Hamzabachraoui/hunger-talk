# 🚀 Guide de Déploiement sur Railway

## 📋 Prérequis

1. ✅ Compte Railway créé ([railway.app](https://railway.app))
2. ✅ Repository GitHub avec ton code
3. ✅ Backend FastAPI prêt

---

## 🔧 Configuration Railway

### Étape 1 : Créer un Nouveau Projet

1. Va sur [railway.app](https://railway.app)
2. Clique sur **"New Project"**
3. Sélectionne **"Deploy from GitHub repo"**
4. Autorise Railway à accéder à ton GitHub
5. Choisis ton repository

### Étape 2 : Ajouter le Service Backend

1. Railway détecte automatiquement Python
2. Il va chercher dans le dossier `backend/`
3. Si besoin, configure le **Root Directory** : `backend`

### Étape 3 : Ajouter PostgreSQL

1. Dans ton projet Railway, clique sur **"+ New"**
2. Sélectionne **"Database"** → **"Add PostgreSQL"**
3. Railway crée automatiquement une base de données
4. La variable `DATABASE_URL` est automatiquement ajoutée

### Étape 4 : Configurer les Variables d'Environnement

Dans les **Settings** de ton service backend, ajoute ces variables :

#### Variables Requises :

```
SECRET_KEY=ta-cle-secrete-super-longue-et-aleatoire-ici
```

**Pour générer une SECRET_KEY :**
```python
import secrets
print(secrets.token_urlsafe(32))
```

#### Variables Optionnelles :

```
ENVIRONMENT=production
DEBUG=False
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3.1:8b
ALLOWED_ORIGINS=*
```

**Note** : `DATABASE_URL` est automatiquement fournie par Railway PostgreSQL.

### Étape 5 : Configurer CORS

Pour permettre l'accès depuis l'app mobile, ajoute dans `ALLOWED_ORIGINS` :

```
ALLOWED_ORIGINS=*
```

Ou spécifiquement pour ton app :
```
ALLOWED_ORIGINS=https://ton-app.up.railway.app,*
```

---

## 🚀 Déploiement

### Déploiement Automatique

Railway déploie automatiquement à chaque push sur GitHub !

1. Push ton code sur GitHub
2. Railway détecte le changement
3. Il rebuild et redéploie automatiquement
4. Tu obtiens une URL : `ton-app.up.railway.app`

### Déploiement Manuel

Si tu veux forcer un déploiement :

1. Va dans ton service sur Railway
2. Clique sur **"Deploy"** → **"Redeploy"**

---

## 🔍 Vérification

### 1. Vérifier que le Serveur Fonctionne

Ouvre dans ton navigateur :
```
https://ton-app.up.railway.app/health
```

Tu devrais voir :
```json
{
  "status": "healthy",
  "service": "hunger-talk-api",
  "version": "1.0.0"
}
```

### 2. Vérifier la Documentation API

Ouvre :
```
https://ton-app.up.railway.app/docs
```

Tu devrais voir la documentation Swagger de ton API.

---

## 📱 Mettre à Jour l'App Mobile

### 1. Récupérer l'URL Railway

Dans Railway, va dans ton service → **Settings** → **Networking**
Tu verras l'URL : `https://ton-app.up.railway.app`

### 2. Modifier `app_config.dart`

Dans `mobile/lib/core/config/app_config.dart`, ligne 23 :

```dart
defaultValue: 'https://ton-app.up.railway.app', // ← Ton URL Railway
```

### 3. Recompiler l'App

```bash
cd mobile
flutter build apk --release
```

---

## 🗄️ Migration de la Base de Données

### Option 1 : Utiliser Alembic (Recommandé)

Railway exécute automatiquement les migrations au démarrage si configuré.

### Option 2 : Migrer les Données Manuellement

1. **Exporter depuis PostgreSQL local :**
```bash
pg_dump -U postgres hungertalk_db > backup.sql
```

2. **Importer dans Railway PostgreSQL :**
   - Va dans Railway → PostgreSQL → **Connect**
   - Utilise les credentials pour te connecter
   - Importe le fichier `backup.sql`

---

## ⚙️ Configuration Avancée

### Variables d'Environnement Disponibles

| Variable | Description | Requis | Valeur par défaut |
|----------|-------------|--------|-------------------|
| `DATABASE_URL` | URL PostgreSQL | ✅ Oui | Auto (Railway) |
| `SECRET_KEY` | Clé JWT | ✅ Oui | - |
| `PORT` | Port du serveur | ✅ Oui | Auto (Railway) |
| `ENVIRONMENT` | Environnement | ❌ Non | `development` |
| `DEBUG` | Mode debug | ❌ Non | `True` |
| `OLLAMA_BASE_URL` | URL Ollama | ❌ Non | `http://localhost:11434` |
| `ALLOWED_ORIGINS` | CORS origins | ❌ Non | `localhost` |

---

## 🐛 Dépannage

### Le déploiement échoue

1. **Vérifie les logs** dans Railway → **Deployments** → **View Logs**
2. **Vérifie que `requirements.txt` existe** dans `backend/`
3. **Vérifie les variables d'environnement** sont toutes définies

### L'app ne se connecte pas

1. **Vérifie l'URL** dans `app_config.dart`
2. **Vérifie CORS** : `ALLOWED_ORIGINS=*`
3. **Teste l'endpoint** : `https://ton-app.up.railway.app/health`

### Erreur de base de données

1. **Vérifie `DATABASE_URL`** est bien définie
2. **Vérifie que PostgreSQL** est bien créé dans Railway
3. **Vérifie les migrations** sont exécutées

---

## 📊 Monitoring

Railway fournit des métriques :
- **Logs** : Voir les logs en temps réel
- **Metrics** : CPU, RAM, Réseau
- **Deployments** : Historique des déploiements

---

## 💰 Coûts

- **Gratuit** : $5 de crédit par mois
- **Suffisant** pour un PFA/projet étudiant
- **Pas de carte bancaire** requise pour commencer

---

## ✅ Checklist de Déploiement

- [ ] Compte Railway créé
- [ ] Repository GitHub connecté
- [ ] Service backend créé
- [ ] PostgreSQL ajouté
- [ ] Variables d'environnement configurées
- [ ] Déploiement réussi
- [ ] `/health` répond correctement
- [ ] URL mise à jour dans `app_config.dart`
- [ ] App mobile testée avec la nouvelle URL

---

## 🎉 C'est Prêt !

Une fois déployé, ton app fonctionnera pour tous les utilisateurs, peu importe où ils sont dans le monde !

**URL de ton API** : `https://ton-app.up.railway.app`
