# 📁 Fichiers Essentiels du Projet

## 🎯 Fichiers Principaux à la Racine

### Configuration Ollama (Solution Actuelle)
- `configurer_et_demarrer_ollama.ps1` - Démarre Ollama avec accès réseau
- `enregistrer_ip_ollama_railway.ps1` - Enregistre l'IP Ollama dans Railway
- `SOLUTION_RAILWAY_IP.md` - Documentation de la solution Railway
- `START_HERE_OLLAMA.md` - Guide de démarrage rapide pour Ollama

### Configuration et Déploiement
- `README.md` - Documentation principale
- `requirements.txt` - Dépendances Python
- `runtime.txt` - Version Python pour Railway
- `railway.json` - Configuration Railway
- `nixpacks.toml` - Configuration build Railway
- `Dockerfile` - Configuration Docker
- `docker-compose.yml` - Configuration Docker Compose (dev)
- `docker-compose.prod.yml` - Configuration Docker Compose (production)

### Scripts Utilitaires
- `demarrer_serveur.ps1` - Démarre le serveur backend local
- `demarrer_docker.ps1` - Démarre avec Docker
- `creer_base_donnees.ps1` - Crée la base de données
- `generer_secret_key.ps1` - Génère une clé secrète
- `autoriser_firewall.ps1` - Configure le firewall
- `install_all_tools.ps1` - Vérifie les outils installés
- `main.py` - Fichier de détection pour Railway (pointant vers backend/main.py)

### Documentation
- `START_HERE.md` - Guide de démarrage général
- `INSTALLATION_RAPIDE.md` - Guide d'installation rapide
- `COMMENT_OBTENIR_LE_TOKEN.md` - Comment obtenir un token JWT
- `DOCKER_QUICK_START.md` - Démarrage rapide avec Docker

## 📂 Dossiers Importants

- `backend/` - Code backend (FastAPI)
- `mobile/` - Application mobile (Flutter)
- `database/` - Scripts de base de données
- `docs/` - Documentation supplémentaire
- `Rapport/` - Rapport du projet
- `autre/` - Autres fichiers (cahier des charges, etc.)

## 🗑️ Fichiers Supprimés (Nettoyage)

Tous les fichiers obsolètes ont été supprimés, notamment :
- Scripts d'enregistrement IP obsolètes (remplacés par Railway)
- Documentation de solutions temporaires
- Fichiers de diagnostic/fix obsolètes
- Scripts dupliqués

