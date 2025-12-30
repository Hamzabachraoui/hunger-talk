# 📤 Instructions pour Mettre le Projet sur GitHub

## ✅ Étape 1 : Créer le Repository sur GitHub

1. Va sur [github.com](https://github.com) et connecte-toi avec ton compte
2. Clique sur **"+"** en haut à droite → **"New repository"**
3. Remplis :
   - **Repository name** : `hunger-talk` (ou le nom que tu veux)
   - **Description** : "Application mobile de gestion nutritionnelle et alimentaire"
   - **Visibilité** : Public ou Private (ton choix)
   - **⚠️ IMPORTANT** : Ne coche PAS "Initialize with README" (on a déjà des fichiers)
4. Clique sur **"Create repository"**

## ✅ Étape 2 : Pousser le Code

### Option A : Utiliser le Script Automatique (RECOMMANDÉ)

1. Exécute le script :
   ```powershell
   .\pousser_sur_github.ps1
   ```

2. Entre ton nom d'utilisateur GitHub quand demandé
3. Entre le nom du repository (ex: `hunger-talk`)
4. Le script fait tout automatiquement !

### Option B : Commandes Manuelles

Si tu préfères faire manuellement :

```bash
# Remplace USERNAME et REPO_NAME
git remote add origin https://github.com/USERNAME/REPO_NAME.git
git branch -M main
git push -u origin main
```

**Exemple :**
```bash
git remote add origin https://github.com/hamza-bachraoui/hunger-talk.git
git branch -M main
git push -u origin main
```

## 🔐 Authentification GitHub

GitHub demande maintenant un **Personal Access Token** au lieu du mot de passe :

1. Va sur GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Clique sur **"Generate new token (classic)"**
3. Donne un nom : "Hunger-Talk Project"
4. Sélectionne les permissions : `repo` (toutes les permissions repo)
5. Clique sur **"Generate token"**
6. **⚠️ COPIE LE TOKEN** (tu ne pourras plus le voir après)
7. Utilise ce token comme mot de passe lors du `git push`

## ✅ Vérification

Après le push, vérifie que tout est bien sur GitHub :

1. Va sur ton repository : `https://github.com/USERNAME/hunger-talk`
2. Tu devrais voir tous tes fichiers (backend/, mobile/, docs/, etc.)

## 🚂 Prochaine Étape : Railway

Une fois que le code est sur GitHub :

1. Va sur [railway.app](https://railway.app)
2. Crée un nouveau projet
3. Sélectionne **"Deploy from GitHub repo"**
4. Choisis ton repository `hunger-talk`
5. Railway déploie automatiquement !

---

**Besoin d'aide ?** Voir `GUIDE_GITHUB.md` pour plus de détails.
