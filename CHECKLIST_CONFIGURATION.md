# ✅ Checklist de Configuration - Hunger-Talk

Utilisez cette checklist pour suivre votre progression dans la configuration.

## 📋 Installation des outils

- [ ] **Python 3.10+**
  - [ ] Téléchargé depuis python.org
  - [ ] Installé avec "Add Python to PATH" coché
  - [ ] Vérifié : `python --version`
  - [ ] pip fonctionne : `pip --version`

- [ ] **Flutter SDK**
  - [ ] Téléchargé depuis flutter.dev
  - [ ] Extrait dans `C:\src\flutter` (ou autre dossier)
  - [ ] Ajouté au PATH système
  - [ ] Vérifié : `flutter doctor`
  - [ ] Licences Android acceptées : `flutter doctor --android-licenses`

- [ ] **PostgreSQL**
  - [ ] Téléchargé depuis postgresql.org
  - [ ] Installé avec pgAdmin 4
  - [ ] Mot de passe postgres noté (⚠️ IMPORTANT)
  - [ ] Vérifié : `psql --version`
  - [ ] Service PostgreSQL démarré

- [ ] **Ollama**
  - [ ] Téléchargé depuis ollama.ai
  - [ ] Installé
  - [ ] Vérifié : `ollama --version`
  - [ ] Serveur Ollama accessible sur localhost:11434

- [ ] **Git**
  - [ ] Téléchargé depuis git-scm.com
  - [ ] Installé
  - [ ] Configuré avec nom et email
  - [ ] Vérifié : `git --version`

---

## 🗄️ Configuration de la base de données

- [ ] **Base de données créée**
  - [ ] Base `hungertalk_db` créée
  - [ ] Test de connexion réussi : `psql -U postgres -d hungertalk_db`
  - [ ] Base visible dans pgAdmin 4

---

## 🤖 Configuration de l'IA (Ollama)

- [ ] **Modèle LLaMA installé**
  - [ ] Modèle `llama3.1:8b` téléchargé : `ollama pull llama3.1:8b`
  - [ ] Vérifié dans la liste : `ollama list`
  - [ ] Test réussi : `ollama run llama3.1:8b "Test"`
  - [ ] Le modèle répond correctement en français

---

## 🐍 Configuration du backend Python

- [ ] **Environnement virtuel**
  - [ ] Créé : `python -m venv venv` dans `backend/`
  - [ ] Activé (PowerShell) : `.\venv\Scripts\Activate.ps1`
  - [ ] pip mis à jour : `pip install --upgrade pip`

- [ ] **Dépendances installées**
  - [ ] requirements.txt installé : `pip install -r requirements.txt`
  - [ ] FastAPI installé et vérifié
  - [ ] SQLAlchemy installé
  - [ ] Toutes les dépendances installées sans erreur

- [ ] **Fichier .env configuré**
  - [ ] Fichier `.env` créé depuis `env.example`
  - [ ] `DATABASE_URL` configuré avec le bon mot de passe
  - [ ] `SECRET_KEY` généré et configuré
  - [ ] `OLLAMA_BASE_URL` configuré
  - [ ] `OLLAMA_MODEL` configuré

---

## ✅ Vérifications finales

- [ ] **Script de vérification**
  - [ ] Exécuté : `powershell -ExecutionPolicy Bypass -File install_all_tools.ps1`
  - [ ] Tous les outils marqués comme installés ✅

- [ ] **Tests fonctionnels**
  - [ ] PostgreSQL : `psql -U postgres -d hungertalk_db -c "SELECT version();"`
  - [ ] Ollama : `ollama run llama3.1:8b "Test"`
  - [ ] Python/FastAPI : `python -c "import fastapi; print('OK')"`

---

## 📝 Notes importantes

**Identifiants à conserver** :
- Mot de passe PostgreSQL : ____________________
- Secret Key JWT : ____________________

**URLs de configuration** :
- Base de données : `postgresql://postgres:****@localhost:5432/hungertalk_db`
- Ollama : `http://localhost:11434`
- Modèle : `llama3.1:8b`

---

## 🎯 Prochaines étapes

Une fois tous les éléments cochés :

1. ✅ Toute la configuration est terminée
2. ➡️ Passer à la PHASE 1 : CONCEPTION ET DESIGN
3. ➡️ Commencer la PHASE 2 : DÉVELOPPEMENT BACKEND

---

**Date de complétion** : _______________

**Notes** :
___________________________________________________
___________________________________________________
___________________________________________________

