# Guide d'installation - Hunger-Talk

## 🎯 Étape 0 : Préparation de l'environnement

### 0.1 : Installation des outils de développement

#### Python 3.10+
1. Télécharger Python depuis [python.org](https://www.python.org/downloads/)
2. Installer en cochant "Add Python to PATH"
3. Vérifier l'installation : `python --version`

#### Flutter SDK
1. Télécharger Flutter depuis [flutter.dev](https://flutter.dev/docs/get-started/install/windows)
2. Extraire dans un dossier (ex: `C:\src\flutter`)
3. Ajouter Flutter au PATH système
4. Vérifier l'installation : `flutter doctor`

#### PostgreSQL
1. Télécharger PostgreSQL depuis [postgresql.org](https://www.postgresql.org/download/windows/)
2. Installer avec pgAdmin 4
3. Noter le mot de passe du superutilisateur (postgres)

#### Git
1. Télécharger Git depuis [git-scm.com](https://git-scm.com/download/win)
2. Installer avec les options par défaut
3. Configurer avec : `git config --global user.name "Votre Nom"` et `git config --global user.email "votre@email.com"`

### 0.2 : Configuration de l'environnement backend

1. Ouvrir un terminal dans le dossier `backend`
2. Créer un environnement virtuel :
```bash
python -m venv venv
```

3. Activer l'environnement virtuel :
```bash
# Windows PowerShell
venv\Scripts\Activate.ps1

# Windows CMD
venv\Scripts\activate.bat

# Linux/Mac
source venv/bin/activate
```

4. Installer les dépendances :
```bash
pip install -r requirements.txt
```

5. Configurer la base de données :
   - Créer une base de données PostgreSQL nommée `hungertalk_db`
   - Copier `.env.example` en `.env`
   - Modifier `DATABASE_URL` dans `.env` avec vos identifiants

### 0.3 : Configuration de l'environnement IA

1. Télécharger Ollama depuis [ollama.ai](https://ollama.ai/download)
2. Installer Ollama
3. Télécharger le modèle LLaMA 3.1 8B :
```bash
ollama pull llama3.1:8b
```

4. Vérifier que Ollama fonctionne :
```bash
ollama list
```

5. Tester le modèle :
```bash
ollama run llama3.1:8b "Bonjour, comment allez-vous ?"
```

### 0.4 : Configuration du projet mobile (Flutter)

1. Aller dans le dossier `mobile`
2. Installer les dépendances :
```bash
flutter pub get
```

3. Configurer les émulateurs :
   - Android Studio : Tools > Device Manager > Create Device
   - Ou utiliser un appareil physique avec USB Debugging activé

### 0.5 : Vérification de l'installation

Exécuter ces commandes pour vérifier que tout est installé :

```bash
# Python
python --version

# Flutter
flutter doctor

# PostgreSQL
psql --version

# Git
git --version

# Ollama
ollama --version
```

## ✅ Checklist de vérification

- [ ] Python 3.10+ installé
- [ ] Flutter SDK installé
- [ ] PostgreSQL installé et base de données créée
- [ ] Git installé
- [ ] Ollama installé et modèle LLaMA téléchargé
- [ ] Environnement virtuel Python créé
- [ ] Dépendances backend installées
- [ ] Fichier .env configuré
- [ ] Émulateur Android/iOS configuré (ou appareil physique)

## 🚀 Prochaines étapes

Une fois l'environnement configuré, vous pouvez passer à la Phase 2 : Développement Backend.

Voir `details.txt` pour les prochaines étapes détaillées.

