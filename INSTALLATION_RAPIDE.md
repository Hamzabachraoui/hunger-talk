# 🚀 Installation rapide des outils - Hunger-Talk

## Installation en une commande (PowerShell)

Ouvrez PowerShell en tant qu'**administrateur** et exécutez :

```powershell
.\install_all_tools.ps1
```

Ce script vérifiera quels outils sont installés et vous donnera les liens pour installer ceux qui manquent.

---

## Installation manuelle rapide

### 1. Python 3.10+
📥 [Télécharger Python](https://www.python.org/downloads/)
- ✅ Cocher "Add Python to PATH"
- Vérifier : `python --version`

### 2. Flutter SDK
📥 [Télécharger Flutter](https://docs.flutter.dev/get-started/install/windows)
- Extraire dans `C:\src\flutter`
- Ajouter `C:\src\flutter\bin` au PATH
- Vérifier : `flutter doctor`

### 3. PostgreSQL
📥 [Télécharger PostgreSQL](https://www.postgresql.org/download/windows/)
- Noter le mot de passe du superutilisateur (postgres)
- Créer la base : `hungertalk_db`
- Vérifier : `psql --version`

### 4. Ollama
📥 [Télécharger Ollama](https://ollama.ai/download)
- Installer
- Télécharger le modèle : `ollama pull llama3.1:8b`
- Vérifier : `ollama list`

### 5. Git
📥 [Télécharger Git](https://git-scm.com/download/win)
- Installer avec options par défaut
- Configurer : 
  ```powershell
  git config --global user.name "Votre Nom"
  git config --global user.email "votre@email.com"
  ```
- Vérifier : `git --version`

---

## 📋 Checklist rapide

```powershell
# Exécuter ces commandes pour vérifier :
python --version
pip --version
flutter --version
psql --version
ollama --version
git --version
ollama list  # Doit afficher llama3.1:8b
```

---

## 🎯 Après l'installation

1. **Initialiser le backend** :
   ```powershell
   cd backend
   .\init_setup.bat
   ```

2. **Configurer la base de données** :
   - Créer `hungertalk_db` dans pgAdmin ou via psql

3. **Configurer le fichier .env** :
   - Copier `backend/env.example` en `backend/.env`
   - Modifier `DATABASE_URL` avec vos identifiants PostgreSQL

---

Pour plus de détails, voir **docs/INSTALLATION_TOOLS.md**

