# Guide d'installation des outils - Hunger-Talk

Ce guide vous aidera à installer tous les outils nécessaires pour développer Hunger-Talk sur Windows.

## 📋 Liste des outils à installer

1. **Python 3.10+**
2. **Flutter SDK**
3. **PostgreSQL**
4. **Ollama**
5. **Git**

---

## 1. 🔵 Python 3.10+

### Installation

1. **Télécharger Python** :
   - Aller sur [python.org/downloads](https://www.python.org/downloads/)
   - Cliquer sur "Download Python 3.12.x" (ou la dernière version 3.10+)

2. **Installer Python** :
   - Exécuter le fichier téléchargé
   - ⚠️ **IMPORTANT** : Cocher "Add Python to PATH" avant de cliquer sur "Install Now"
   - Attendre la fin de l'installation

3. **Vérifier l'installation** :
   ```powershell
   python --version
   ```
   - Vous devriez voir : `Python 3.12.x` (ou similaire)

4. **Vérifier pip** :
   ```powershell
   pip --version
   ```

### ✅ Test de Python

```powershell
python -c "print('Python fonctionne correctement!')"
```

---

## 2. 🟢 Flutter SDK

### Prérequis
- Au moins 2 GB d'espace disque
- Android Studio (recommandé) ou VS Code

### Installation

1. **Télécharger Flutter** :
   - Aller sur [flutter.dev/docs/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)
   - Télécharger le SDK Flutter (fichier ZIP)
   - Extraire dans un dossier (ex: `C:\src\flutter`)
   - ⚠️ Ne pas extraire dans un dossier avec des espaces ou des caractères spéciaux

2. **Ajouter Flutter au PATH** :
   - Ouvrir "Variables d'environnement" dans Windows
   - Dans "Variables système", trouver "Path" et cliquer sur "Modifier"
   - Cliquer sur "Nouveau" et ajouter : `C:\src\flutter\bin` (ou votre chemin)
   - Cliquer sur "OK" partout

3. **Vérifier l'installation** :
   ```powershell
   flutter doctor
   ```
   - Cette commande vérifie tous les prérequis

4. **Installer les dépendances manquantes** :
   ```powershell
   flutter doctor --android-licenses
   ```
   - Accepter les licences en tapant `y`

### Configuration Android Studio (recommandé)

1. **Télécharger Android Studio** :
   - Aller sur [developer.android.com/studio](https://developer.android.com/studio)
   - Télécharger et installer

2. **Installer les plugins Flutter** :
   - Ouvrir Android Studio
   - File > Settings > Plugins
   - Chercher "Flutter" et installer
   - Installer aussi "Dart" (installé automatiquement avec Flutter)

3. **Configurer l'émulateur** :
   - Tools > Device Manager
   - Créer un appareil virtuel (AVD)
   - Choisir un modèle (ex: Pixel 5)
   - Télécharger une image système (ex: Android 13)

### ✅ Test de Flutter

```powershell
flutter --version
flutter doctor -v
```

---

## 3. 🐘 PostgreSQL

### Installation

1. **Télécharger PostgreSQL** :
   - Aller sur [postgresql.org/download/windows](https://www.postgresql.org/download/windows/)
   - Cliquer sur "Download the installer"
   - Télécharger la dernière version (15.x ou 16.x)

2. **Installer PostgreSQL** :
   - Exécuter le fichier téléchargé
   - Suivre l'assistant d'installation
   - **Port** : Garder 5432 (par défaut)
   - **Mot de passe** : Choisir un mot de passe pour l'utilisateur `postgres` (⚠️ À NOTER IMPÉRATIVEMENT)
   - Installer pgAdmin 4 (recommandé)

3. **Vérifier l'installation** :
   - Chercher "pgAdmin 4" dans le menu Démarrer
   - Ouvrir pgAdmin 4
   - Se connecter avec le mot de passe choisi

4. **Créer la base de données Hunger-Talk** :
   - Dans pgAdmin, cliquer droit sur "Databases"
   - Create > Database
   - Nom : `hungertalk_db`
   - Owner : `postgres`
   - Cliquer sur "Save"

### Configuration via ligne de commande

1. **Ouvrir SQL Shell (psql)** :
   - Chercher "SQL Shell (psql)" dans le menu Démarrer

2. **Se connecter** :
   - Server : appuyer sur Entrée (localhost)
   - Database : appuyer sur Entrée (postgres)
   - Port : appuyer sur Entrée (5432)
   - Username : appuyer sur Entrée (postgres)
   - Password : Entrer le mot de passe choisi

3. **Créer la base de données** :
   ```sql
   CREATE DATABASE hungertalk_db;
   \q
   ```

### ✅ Test de PostgreSQL

```powershell
psql --version
```

---

## 4. 🤖 Ollama (IA - LLaMA)

### Installation

1. **Télécharger Ollama** :
   - Aller sur [ollama.ai/download](https://ollama.ai/download)
   - Télécharger pour Windows
   - Exécuter le fichier téléchargé

2. **Vérifier l'installation** :
   ```powershell
   ollama --version
   ```

3. **Télécharger le modèle LLaMA 3.1 8B** :
   ```powershell
   ollama pull llama3.1:8b
   ```
   - ⚠️ Cela peut prendre plusieurs minutes (modèle de ~4.7 GB)
   - Vérifier votre connexion internet

4. **Tester le modèle** :
   ```powershell
   ollama run llama3.1:8b "Bonjour, comment allez-vous ?"
   ```
   - Le modèle devrait répondre en français

5. **Vérifier les modèles installés** :
   ```powershell
   ollama list
   ```

### Démarrer Ollama

Ollama se lance automatiquement. Si ce n'est pas le cas :
```powershell
ollama serve
```

### ✅ Test d'Ollama

```powershell
ollama run llama3.1:8b "Test de fonctionnement"
```

---

## 5. 📦 Git

### Installation

1. **Télécharger Git** :
   - Aller sur [git-scm.com/download/win](https://git-scm.com/download/win)
   - Télécharger l'installateur

2. **Installer Git** :
   - Exécuter l'installateur
   - Utiliser les options par défaut (recommandé)
   - Installer Git Bash (optionnel mais utile)

3. **Configurer Git** :
   ```powershell
   git config --global user.name "Votre Nom"
   git config --global user.email "votre@email.com"
   ```

4. **Vérifier l'installation** :
   ```powershell
   git --version
   ```

### ✅ Test de Git

```powershell
git --version
git config --list
```

---

## 📝 Récapitulatif des outils

| Outil | Version | Commande de vérification |
|-------|---------|-------------------------|
| Python | 3.10+ | `python --version` |
| Flutter | Latest | `flutter --version` |
| PostgreSQL | 15+ | `psql --version` |
| Ollama | Latest | `ollama --version` |
| Git | Latest | `git --version` |

---

## ✅ Checklist finale

Avant de continuer, vérifiez que tout est installé :

```powershell
# Vérifier Python
python --version

# Vérifier pip
pip --version

# Vérifier Flutter
flutter doctor

# Vérifier PostgreSQL
psql --version

# Vérifier Ollama
ollama --version

# Vérifier Git
git --version

# Vérifier le modèle LLaMA
ollama list
```

---

## 🐛 Résolution des problèmes courants

### Python non reconnu
- **Solution** : Réinstaller Python en cochant "Add Python to PATH"
- Ou ajouter manuellement Python au PATH système

### Flutter doctor affiche des erreurs
- **Solution** : Lire les messages et installer les outils manquants
- Exécuter `flutter doctor --android-licenses` pour accepter les licences

### PostgreSQL ne démarre pas
- **Solution** : Vérifier que le service PostgreSQL est démarré
- Services Windows > Chercher "postgresql" > Démarrer

### Ollama ne trouve pas le modèle
- **Solution** : Vérifier votre connexion internet
- Réessayer : `ollama pull llama3.1:8b`

### Git non reconnu
- **Solution** : Redémarrer le terminal après l'installation
- Ou redémarrer Windows

---

## 🚀 Prochaines étapes

Une fois tous les outils installés :

1. **Initialiser le backend** :
   ```powershell
   cd backend
   .\init_setup.bat
   ```

2. **Configurer la base de données** :
   - Créer la base `hungertalk_db` dans PostgreSQL
   - Mettre à jour le fichier `.env` dans `backend/`

3. **Tester Ollama** :
   ```powershell
   ollama run llama3.1:8b "Test"
   ```

4. **Créer un projet Flutter** (quand vous serez prêt) :
   ```powershell
   cd mobile
   flutter create .
   ```

---

## 📚 Ressources supplémentaires

- [Documentation Python](https://docs.python.org/)
- [Documentation Flutter](https://docs.flutter.dev/)
- [Documentation PostgreSQL](https://www.postgresql.org/docs/)
- [Documentation Ollama](https://github.com/ollama/ollama)
- [Documentation Git](https://git-scm.com/doc)

---

**Bon développement ! 🎉**

