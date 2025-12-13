# 🔧 Guide de Configuration Complète - Hunger-Talk

Ce guide vous accompagne étape par étape pour finaliser toutes les installations et configurations.

## 📋 Vue d'ensemble

Vous devez installer et configurer :
1. ✅ Python 3.10+ (Déjà installé)
2. ✅ Flutter (Déjà installé)
3. ✅ Git (Déjà installé)
4. ⚠️ PostgreSQL (À installer)
5. ⚠️ Ollama (À installer)
6. ⚠️ Base de données `hungertalk_db` (À créer)
7. ⚠️ Modèle LLaMA 3.1:8b (À télécharger)
8. ⚠️ Environnement virtuel Python (À créer)

---

## 🚀 Méthode rapide (recommandée)

Exécutez le script complet :

```powershell
.\COMPLETE_SETUP.bat
```

Ce script vous guidera à travers toutes les étapes.

---

## 📝 Méthode manuelle étape par étape

### ÉTAPE 1 : Vérifier les outils installés

```powershell
powershell -ExecutionPolicy Bypass -File install_all_tools.ps1
```

---

### ÉTAPE 2 : Installer PostgreSQL

#### 2.1 Téléchargement et installation

1. **Télécharger PostgreSQL** :
   - Aller sur [postgresql.org/download/windows](https://www.postgresql.org/download/windows/)
   - Cliquer sur "Download the installer"
   - Télécharger la dernière version (16.x ou 15.x)

2. **Installer PostgreSQL** :
   - Exécuter le fichier téléchargé
   - Suivre l'assistant d'installation
   - **Port** : Garder 5432 (par défaut)
   - **Superutilisateur** : `postgres`
   - **Mot de passe** : Choisir un mot de passe et **LE NOTER** (⚠️ IMPORTANT)
   - Installer **pgAdmin 4** (recommandé)
   - Installer les outils en ligne de commande (Stack Builder - optionnel)

3. **Vérifier l'installation** :
   ```powershell
   psql --version
   ```
   
   Si la commande n'est pas reconnue :
   - Redémarrer le terminal
   - Ou ajouter manuellement au PATH : `C:\Program Files\PostgreSQL\16\bin` (version peut varier)

#### 2.2 Créer la base de données `hungertalk_db`

**Option A : Via pgAdmin 4 (recommandé)**

1. Ouvrir **pgAdmin 4** depuis le menu Démarrer
2. Se connecter avec le mot de passe choisi lors de l'installation
3. Dans l'arborescence de gauche, développer "Servers" > "PostgreSQL 16"
4. Clic droit sur "Databases" > "Create" > "Database..."
5. Dans l'onglet "General" :
   - **Database name** : `hungertalk_db`
6. Dans l'onglet "Definition" :
   - **Owner** : `postgres`
7. Cliquer sur "Save"

**Option B : Via SQL Shell (psql)**

1. Ouvrir "SQL Shell (psql)" depuis le menu Démarrer
2. Appuyer sur **Entrée** pour chaque question :
   - Server : `[localhost]` → Entrée
   - Database : `[postgres]` → Entrée
   - Port : `[5432]` → Entrée
   - Username : `[postgres]` → Entrée
   - Password : Entrer votre mot de passe
3. Exécuter :
   ```sql
   CREATE DATABASE hungertalk_db;
   \q
   ```

**Option C : Via ligne de commande**

```powershell
psql -U postgres -c "CREATE DATABASE hungertalk_db;"
```
(Entrer le mot de passe quand demandé)

#### 2.3 Tester la connexion

```powershell
psql -U postgres -d hungertalk_db
```

Vous devriez voir un prompt PostgreSQL. Taper `\q` pour quitter.

---

### ÉTAPE 3 : Installer Ollama

#### 3.1 Téléchargement et installation

1. **Télécharger Ollama** :
   - Aller sur [ollama.ai/download](https://ollama.ai/download)
   - Télécharger pour Windows

2. **Installer Ollama** :
   - Exécuter le fichier téléchargé (ollama-windows-amd64.exe)
   - Ollama se lance automatiquement
   - Une icône apparaît dans la barre des tâches

3. **Vérifier l'installation** :
   ```powershell
   ollama --version
   ```

#### 3.2 Télécharger le modèle LLaMA 3.1 8B

⚠️ **Attention** : Le modèle fait environ **4.7 GB**. Assurez-vous d'avoir :
- Une connexion internet stable
- Au moins 10 GB d'espace disque libre
- 10-15 minutes de temps

```powershell
ollama pull llama3.1:8b
```

Cette commande va :
1. Télécharger le modèle
2. L'installer automatiquement
3. Le rendre disponible pour utilisation

#### 3.3 Vérifier le modèle installé

```powershell
ollama list
```

Vous devriez voir :
```
NAME            ID              SIZE    MODIFIED
llama3.1:8b     abc123...       4.7 GB  2 minutes ago
```

#### 3.4 Tester le modèle

```powershell
ollama run llama3.1:8b "Bonjour, comment allez-vous ?"
```

Le modèle devrait répondre en français. Taper `/bye` ou `exit` pour quitter.

#### 3.5 Vérifier que le serveur Ollama fonctionne

Le serveur Ollama devrait être accessible sur : `http://localhost:11434`

Vous pouvez tester avec :
```powershell
curl http://localhost:11434/api/tags
```

---

### ÉTAPE 4 : Configurer l'environnement backend

#### 4.1 Aller dans le dossier backend

```powershell
cd backend
```

#### 4.2 Créer l'environnement virtuel Python

```powershell
python -m venv venv
```

#### 4.3 Activer l'environnement virtuel

**Windows PowerShell** :
```powershell
.\venv\Scripts\Activate.ps1
```

**Windows CMD** :
```cmd
venv\Scripts\activate.bat
```

**Note** : Si vous avez une erreur d'exécution de scripts dans PowerShell :
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### 4.4 Installer les dépendances

```powershell
pip install --upgrade pip
pip install -r requirements.txt
```

Cela peut prendre quelques minutes.

#### 4.5 Créer le fichier .env

```powershell
copy env.example .env
```

#### 4.6 Configurer le fichier .env

Ouvrir `backend/.env` dans un éditeur de texte et modifier :

```env
# Base de données PostgreSQL
DATABASE_URL=postgresql://postgres:VOTRE_MOT_DE_PASSE@localhost:5432/hungertalk_db

# JWT Secret Key (générer une clé aléatoire)
SECRET_KEY=votre_cle_secrete_jwt_ici_changez_moi_par_une_cle_aleatoire
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Configuration Ollama (IA locale)
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3.1:8b

# Configuration CORS
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080

# Environnement
ENVIRONMENT=development
DEBUG=True
```

**⚠️ IMPORTANT** :
- Remplacer `VOTRE_MOT_DE_PASSE` par le mot de passe PostgreSQL choisi
- Remplacer `votre_cle_secrete_jwt_ici_changez_moi` par une clé aléatoire (vous pouvez générer avec Python : `python -c "import secrets; print(secrets.token_urlsafe(32))"`)

---

## ✅ Vérification finale

Exécutez le script de vérification :

```powershell
cd ..
powershell -ExecutionPolicy Bypass -File install_all_tools.ps1
```

Tous les outils devraient être marqués comme installés :
- ✅ Python
- ✅ Flutter
- ✅ PostgreSQL
- ✅ Ollama (avec modèle LLaMA)
- ✅ Git

---

## 🧪 Tests rapides

### Test PostgreSQL

```powershell
psql -U postgres -d hungertalk_db -c "SELECT version();"
```

### Test Ollama

```powershell
ollama run llama3.1:8b "Test rapide"
```

### Test Backend (quand le code sera créé)

```powershell
cd backend
.\venv\Scripts\Activate.ps1
python -c "import fastapi; print('FastAPI installé:', fastapi.__version__)"
```

---

## 🐛 Résolution des problèmes

### PostgreSQL non trouvé

**Problème** : `psql : commande introuvable`

**Solution** :
1. Redémarrer le terminal
2. Ajouter manuellement au PATH : `C:\Program Files\PostgreSQL\16\bin`
3. Redémarrer l'ordinateur si nécessaire

### Ollama ne démarre pas

**Problème** : Ollama ne répond pas

**Solution** :
```powershell
# Vérifier si Ollama est en cours d'exécution
Get-Process ollama -ErrorAction SilentlyContinue

# Si non, démarrer Ollama
ollama serve
```

### Erreur lors de l'installation pip

**Problème** : Erreur lors de `pip install -r requirements.txt`

**Solution** :
```powershell
# Mettre à jour pip
python -m pip install --upgrade pip

# Réessayer
pip install -r requirements.txt
```

### Base de données existe déjà

**Problème** : `ERROR: database "hungertalk_db" already exists`

**Solution** :
- C'est normal si vous l'avez déjà créée
- Ou supprimer et recréer :
  ```sql
  DROP DATABASE hungertalk_db;
  CREATE DATABASE hungertalk_db;
  ```

---

## 📚 Prochaines étapes

Une fois tout configuré :

1. ✅ Tous les outils sont installés
2. ✅ La base de données est créée
3. ✅ Ollama fonctionne avec LLaMA
4. ✅ L'environnement backend est prêt

Vous pouvez maintenant passer à :
- **PHASE 1** : Finaliser la conception (schéma de base de données, API, etc.)
- **PHASE 2** : Commencer le développement du backend

---

## 📞 Support

En cas de problème :
1. Consultez `docs/INSTALLATION_TOOLS.md` pour plus de détails
2. Vérifiez les logs d'erreur
3. Consultez la documentation officielle de chaque outil

**Bon développement ! 🚀**

