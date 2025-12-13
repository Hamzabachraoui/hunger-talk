# ✅ Checklist Déploiement Railway

## 📋 Avant de Commencer

- [ ] Compte Railway créé ([railway.app](https://railway.app))
- [ ] Repository GitHub avec le code backend
- [ ] Python 3.11 installé localement (pour tester)

---

## 🔧 Configuration Railway

### Étape 1 : Créer le Projet
- [ ] Aller sur railway.app
- [ ] Cliquer "New Project"
- [ ] Sélectionner "Deploy from GitHub repo"
- [ ] Autoriser Railway → GitHub
- [ ] Choisir ton repository

### Étape 2 : Configurer le Service Backend
- [ ] Railway détecte Python automatiquement
- [ ] Vérifier que le **Root Directory** = `backend`
- [ ] Si besoin, configurer dans Settings → Source

### Étape 3 : Ajouter PostgreSQL
- [ ] Dans le projet, cliquer "+ New"
- [ ] Sélectionner "Database" → "Add PostgreSQL"
- [ ] Railway crée automatiquement la DB
- [ ] `DATABASE_URL` est automatiquement ajoutée ✅

### Étape 4 : Générer SECRET_KEY
- [ ] Exécuter : `python backend/generate_secret_key.py`
- [ ] Copier la clé générée

### Étape 5 : Configurer les Variables d'Environnement

Dans Railway → Service Backend → Variables :

- [ ] `SECRET_KEY` = (clé générée)
- [ ] `ALLOWED_ORIGINS` = `*`
- [ ] `ENVIRONMENT` = `production`
- [ ] `DEBUG` = `False`
- [ ] `OLLAMA_BASE_URL` = `http://localhost:11434` (si Ollama reste local)
- [ ] `OLLAMA_MODEL` = `llama3.1:8b`

**Note** : `DATABASE_URL` et `PORT` sont automatiques ✅

---

## 🚀 Déploiement

- [ ] Railway déploie automatiquement après le push GitHub
- [ ] Vérifier les logs : Railway → Deployments → View Logs
- [ ] Attendre que le déploiement soit terminé (✅ Success)

---

## ✅ Vérification

### 1. Tester l'API
- [ ] Ouvrir : `https://ton-app.up.railway.app/health`
- [ ] Vérifier la réponse : `{"status": "healthy", ...}`

### 2. Tester la Documentation
- [ ] Ouvrir : `https://ton-app.up.railway.app/docs`
- [ ] Vérifier que Swagger s'affiche

### 3. Tester un Endpoint
- [ ] Tester : `POST https://ton-app.up.railway.app/api/auth/register`
- [ ] Vérifier que ça fonctionne

---

## 📱 Mise à Jour de l'App Mobile

### 1. Récupérer l'URL Railway
- [ ] Railway → Service → Settings → Networking
- [ ] Copier l'URL : `https://ton-app.up.railway.app`

### 2. Modifier app_config.dart
- [ ] Ouvrir `mobile/lib/core/config/app_config.dart`
- [ ] Ligne 23, remplacer par ton URL Railway
- [ ] Sauvegarder

### 3. Recompiler l'App
- [ ] `cd mobile`
- [ ] `flutter clean`
- [ ] `flutter pub get`
- [ ] `flutter build apk --release`

### 4. Tester l'App
- [ ] Installer l'APK sur ton téléphone
- [ ] Tester la connexion au serveur Railway
- [ ] Vérifier que tout fonctionne

---

## 🗄️ Migration Base de Données (Optionnel)

Si tu as déjà des données locales :

- [ ] Exporter : `pg_dump -U postgres hungertalk_db > backup.sql`
- [ ] Dans Railway → PostgreSQL → Connect
- [ ] Importer le fichier `backup.sql`

---

## 🎉 C'est Prêt !

- [ ] URL Railway : `https://ton-app.up.railway.app`
- [ ] App mobile configurée avec la nouvelle URL
- [ ] Tout fonctionne ! 🚀

---

## 🆘 En Cas de Problème

### Le déploiement échoue
1. Vérifier les logs Railway
2. Vérifier que `requirements.txt` existe
3. Vérifier les variables d'environnement

### L'app ne se connecte pas
1. Vérifier l'URL dans `app_config.dart`
2. Vérifier CORS : `ALLOWED_ORIGINS=*`
3. Tester `/health` dans le navigateur

### Erreur base de données
1. Vérifier que PostgreSQL est créé
2. Vérifier `DATABASE_URL` est définie
3. Vérifier les migrations Alembic

---

**Besoin d'aide ?** Voir `backend/DEPLOIEMENT_RAILWAY.md`
