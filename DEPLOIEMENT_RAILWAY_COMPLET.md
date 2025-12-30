# 🚀 Déploiement Railway - Guide Complet

## 📋 Prérequis
- ✅ Compte GitHub avec le repository `hunger-talk` (déjà fait)
- ✅ Compte Railway (à créer)

---

## Étape 1 : Créer un Compte Railway

1. Va sur [railway.app](https://railway.app)
2. Clique sur **"Login"** ou **"Start a New Project"**
3. Choisis **"Login with GitHub"**
4. Autorise Railway à accéder à ton compte GitHub

---

## Étape 2 : Créer un Nouveau Projet

1. Une fois connecté, clique sur **"New Project"**
2. Choisis **"Deploy from GitHub repo"**
3. Sélectionne ton repository : **`Hamzabachraoui/hunger-talk`**
4. Railway va détecter automatiquement que c'est un projet Python

---

## Étape 3 : Configurer le Service Backend

### 3.1. Configuration du Root Directory

Railway doit savoir que le backend est dans le dossier `backend/` :

1. Dans ton projet Railway, clique sur le service créé
2. Va dans l'onglet **"Settings"**
3. Trouve **"Root Directory"**
4. Entre : `backend`
5. Clique sur **"Save"**

### 3.2. Configuration du Build

Railway devrait détecter automatiquement :
- **Builder** : NIXPACKS (détecte Python)
- **Start Command** : `uvicorn main:app --host 0.0.0.0 --port $PORT`

Si ce n'est pas le cas, vérifie que `railway.json` et `Procfile` sont bien dans `backend/`.

---

## Étape 4 : Ajouter PostgreSQL

1. Dans ton projet Railway, clique sur **"+ New"**
2. Choisis **"Database"** → **"Add PostgreSQL"**
3. Railway va créer une base de données PostgreSQL
4. **IMPORTANT** : Note l'URL de connexion qui apparaît (ou tu la récupéreras plus tard)

---

## Étape 5 : Configurer les Variables d'Environnement

1. Dans ton projet Railway, clique sur le service backend
2. Va dans l'onglet **"Variables"**
3. Ajoute les variables suivantes :

### Variables Obligatoires

| Variable | Valeur | Commentaire |
|----------|--------|-------------|
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | Railway génère automatiquement cette variable quand tu ajoutes PostgreSQL. Clique sur "Add Reference" et sélectionne la base de données. |
| `SECRET_KEY` | `[Génère une clé secrète]` | Voir ci-dessous pour générer |
| `PORT` | `${{PORT}}` | Railway définit automatiquement cette variable |
| `ENVIRONMENT` | `production` | Mode production |

### Générer SECRET_KEY

Exécute cette commande dans PowerShell :

```powershell
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

Copie la clé générée et colle-la dans la variable `SECRET_KEY` sur Railway.

### Variables Optionnelles (si nécessaire)

| Variable | Valeur par défaut | Description |
|----------|-------------------|-------------|
| `OLLAMA_BASE_URL` | `http://localhost:11434` | URL d'Ollama (si tu utilises l'IA localement, laisse vide) |
| `OLLAMA_MODEL` | `llama3.1:8b` | Modèle Ollama |
| `DEBUG` | `False` | Mode debug (désactivé en production) |

---

## Étape 6 : Déployer

1. Railway va automatiquement détecter le push sur GitHub
2. Il va builder et déployer ton application
3. Tu peux suivre les logs dans l'onglet **"Deployments"**

---

## Étape 7 : Obtenir l'URL de Production

1. Une fois le déploiement terminé, va dans l'onglet **"Settings"** de ton service
2. Active **"Generate Domain"** pour obtenir une URL publique
3. Tu obtiendras une URL du type : `https://ton-app.up.railway.app`
4. **COPIE CETTE URL** - tu en auras besoin pour l'app mobile !

---

## Étape 8 : Vérifier le Déploiement

1. Ouvre l'URL générée dans ton navigateur
2. Ajoute `/docs` à la fin : `https://ton-app.up.railway.app/docs`
3. Tu devrais voir la documentation Swagger de FastAPI
4. Teste l'endpoint `/health` : `https://ton-app.up.railway.app/health`

---

## Étape 9 : Mettre à Jour l'Application Mobile

Une fois que tu as l'URL Railway, mets à jour le fichier `mobile/lib/core/config/app_config.dart` :

```dart
// Dans la méthode initialize(), remplace :
_defaultServerUrl = 'https://ton-app.up.railway.app'; // <-- REMPLACER PAR TON URL
```

---

## 🔧 Dépannage

### Le déploiement échoue

1. Vérifie les logs dans Railway (onglet "Deployments")
2. Vérifie que `Root Directory` est bien `backend`
3. Vérifie que toutes les variables d'environnement sont définies

### Erreur de connexion à la base de données

1. Vérifie que `DATABASE_URL` utilise bien `${{Postgres.DATABASE_URL}}`
2. Vérifie que PostgreSQL est bien créé et actif

### L'application ne démarre pas

1. Vérifie les logs Railway
2. Vérifie que `PORT` est bien défini (Railway le fait automatiquement)
3. Vérifie que `uvicorn` est dans `requirements.txt`

---

## 📝 Checklist de Déploiement

- [ ] Compte Railway créé
- [ ] Projet créé et connecté à GitHub
- [ ] Root Directory configuré sur `backend`
- [ ] PostgreSQL ajouté
- [ ] Variables d'environnement configurées :
  - [ ] `DATABASE_URL` (référence à PostgreSQL)
  - [ ] `SECRET_KEY` (générée)
  - [ ] `ENVIRONMENT=production`
- [ ] Déploiement réussi
- [ ] URL publique obtenue
- [ ] Test de l'API réussi (`/docs` et `/health`)
- [ ] URL mise à jour dans l'app mobile

---

## 🎉 C'est Fait !

Une fois tout configuré, ton backend sera accessible publiquement et l'app mobile pourra s'y connecter automatiquement sans problème d'IP !
