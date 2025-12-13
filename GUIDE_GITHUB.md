# 📤 Guide : Mettre le Projet sur GitHub

## 🔍 État Actuel

Ton projet **n'est pas encore sur GitHub**. Il faut :
1. Initialiser Git
2. Créer un repository sur GitHub
3. Pousser le code

---

## 🚀 Étapes pour Mettre sur GitHub

### Étape 1 : Initialiser Git Localement

Ouvre un terminal dans le dossier du projet et exécute :

```bash
cd "g:\EMSI\3eme annee\PFA"

# Initialiser Git
git init

# Ajouter tous les fichiers
git add .

# Premier commit
git commit -m "Initial commit - Hunger-Talk project"
```

### Étape 2 : Créer un Repository sur GitHub

1. Va sur [github.com](https://github.com)
2. Clique sur **"+"** en haut à droite → **"New repository"**
3. Remplis :
   - **Repository name** : `hunger-talk` (ou le nom que tu veux)
   - **Description** : "Application mobile de gestion nutritionnelle et alimentaire"
   - **Visibilité** : Public ou Private (ton choix)
   - **NE PAS** cocher "Initialize with README" (on a déjà des fichiers)
4. Clique sur **"Create repository"**

### Étape 3 : Connecter le Projet Local à GitHub

GitHub va te donner des commandes. Utilise celles-ci :

```bash
# Remplace USERNAME par ton nom d'utilisateur GitHub
# Remplace REPO_NAME par le nom de ton repository

git remote add origin https://github.com/USERNAME/REPO_NAME.git
git branch -M main
git push -u origin main
```

**Exemple :**
```bash
git remote add origin https://github.com/hamza/hunger-talk.git
git branch -M main
git push -u origin main
```

---

## ✅ Vérification

Après le push, vérifie que tout est bien sur GitHub :

1. Va sur ton repository GitHub
2. Tu devrais voir tous tes fichiers (backend/, mobile/, docs/, etc.)

---

## 🔄 Pour les Prochains Changements

Une fois que c'est sur GitHub, pour chaque modification :

```bash
git add .
git commit -m "Description de tes changements"
git push
```

---

## 🚂 Ensuite : Connecter à Railway

Une fois que ton code est sur GitHub :

1. Va sur [railway.app](https://railway.app)
2. Crée un nouveau projet
3. Sélectionne **"Deploy from GitHub repo"**
4. Autorise Railway → GitHub
5. Choisis ton repository `hunger-talk`
6. Railway déploie automatiquement !

---

## ⚠️ Important : Fichiers à NE PAS Pousser

Le fichier `.gitignore` est déjà configuré pour ignorer :
- `.env` (variables d'environnement sensibles)
- `venv/` (environnement virtuel Python)
- `__pycache__/` (fichiers Python compilés)
- `*.log` (logs)

**Ne pousse JAMAIS** :
- Fichiers `.env` avec tes mots de passe
- Clés secrètes
- Données personnelles

---

## 🆘 En Cas de Problème

### Erreur "remote origin already exists"
```bash
git remote remove origin
git remote add origin https://github.com/USERNAME/REPO_NAME.git
```

### Erreur d'authentification
GitHub demande maintenant un **Personal Access Token** au lieu du mot de passe :

1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token
3. Donne les permissions : `repo`
4. Copie le token
5. Utilise-le comme mot de passe lors du `git push`

---

## 📋 Checklist

- [ ] Git initialisé localement
- [ ] Repository créé sur GitHub
- [ ] Code poussé sur GitHub
- [ ] Vérifié que les fichiers sont bien sur GitHub
- [ ] Prêt à connecter à Railway !

---

**Une fois que c'est fait, dis-moi et on connecte Railway ! 🚀**
