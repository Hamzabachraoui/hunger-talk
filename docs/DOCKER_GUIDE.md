# 🐳 Guide Docker - Hunger-Talk

Ce guide explique comment utiliser Docker pour développer et déployer Hunger-Talk.

## 📋 Prérequis

- Docker Desktop installé et démarré
- Docker Compose installé (inclus avec Docker Desktop)

## 🚀 Démarrage rapide

### 1. Démarrer tous les services

```bash
docker-compose up -d
```

Cette commande va :
- Télécharger et démarrer PostgreSQL
- Construire et démarrer le backend FastAPI
- Créer la base de données `hungertalk_db`
- Configurer le réseau entre les services

### 2. Vérifier que tout fonctionne

```bash
# Voir les logs
docker-compose logs -f

# Vérifier les conteneurs
docker-compose ps
```

### 3. Accéder aux services

- **Backend API** : http://localhost:8000
- **Documentation Swagger** : http://localhost:8000/docs
- **PostgreSQL** : localhost:5432

### 4. Arrêter les services

```bash
docker-compose down
```

Pour supprimer aussi les volumes (base de données) :
```bash
docker-compose down -v
```

---

## 📁 Structure des fichiers Docker

```
hunger-talk/
├── docker-compose.yml          # Configuration principale
├── docker-compose.prod.yml     # Configuration production
├── .dockerignore               # Fichiers à ignorer
├── backend/
│   ├── Dockerfile              # Image du backend
│   └── .dockerignore           # Fichiers backend à ignorer
└── database/
    └── init.sql                # Script d'initialisation SQL
```

---

## 🔧 Commandes utiles

### Construire les images

```bash
# Construire toutes les images
docker-compose build

# Reconstruire sans cache
docker-compose build --no-cache

# Construire seulement le backend
docker-compose build backend
```

### Gérer les conteneurs

```bash
# Démarrer
docker-compose up -d

# Arrêter
docker-compose down

# Redémarrer
docker-compose restart

# Voir les logs
docker-compose logs -f backend
docker-compose logs -f postgres

# Exécuter une commande dans un conteneur
docker-compose exec backend bash
docker-compose exec postgres psql -U postgres -d hungertalk_db
```

### Gérer la base de données

```bash
# Accéder à PostgreSQL
docker-compose exec postgres psql -U postgres -d hungertalk_db

# Exécuter les migrations Alembic
docker-compose exec backend alembic upgrade head

# Créer une nouvelle migration
docker-compose exec backend alembic revision --autogenerate -m "Description"
```

### Nettoyer

```bash
# Arrêter et supprimer les conteneurs
docker-compose down

# Supprimer aussi les volumes (⚠️ supprime les données)
docker-compose down -v

# Supprimer les images
docker-compose down --rmi all

# Nettoyer tout Docker (⚠️ attention)
docker system prune -a
```

---

## 🎯 Configuration

### Variables d'environnement

Les variables d'environnement sont définies dans `docker-compose.yml` :

```yaml
environment:
  DATABASE_URL: postgresql://postgres:hamza@postgres:5432/hungertalk_db
  OLLAMA_BASE_URL: http://host.docker.internal:11434
  # ... autres variables
```

### Modifier les variables

1. **Pour le développement local** : Modifier `docker-compose.yml`
2. **Pour la production** : Utiliser `docker-compose.prod.yml` ou des variables d'environnement système

### Accès à Ollama depuis Docker

Ollama reste en local (pas containerisé). Le backend y accède via :
```
OLLAMA_BASE_URL: http://host.docker.internal:11434
```

Cela permet au conteneur Docker d'accéder à Ollama sur votre machine hôte.

---

## 🔄 Workflow de développement

### Option 1 : Développement avec Docker (recommandé)

```bash
# 1. Démarrer les services
docker-compose up -d

# 2. Développer localement (le code est monté en volume)
# Les modifications sont reflétées automatiquement grâce à --reload

# 3. Accéder aux logs
docker-compose logs -f backend

# 4. Arrêter
docker-compose down
```

**Avantages** :
- Environnement isolé et reproductible
- PostgreSQL géré automatiquement
- Pas besoin d'installer PostgreSQL localement

### Option 2 : Développement mixte

- **PostgreSQL** : Via Docker
- **Backend** : Localement (avec venv)
- **Ollama** : Localement

```bash
# Démarrer seulement PostgreSQL
docker-compose up -d postgres

# Backend en local
cd backend
.\venv\Scripts\Activate.ps1
uvicorn main:app --reload
```

---

## 🐛 Résolution des problèmes

### Le backend ne démarre pas

```bash
# Vérifier les logs
docker-compose logs backend

# Vérifier que PostgreSQL est prêt
docker-compose exec postgres pg_isready -U postgres

# Reconstruire l'image
docker-compose build --no-cache backend
```

### Problème de connexion à la base de données

```bash
# Vérifier que PostgreSQL est démarré
docker-compose ps

# Tester la connexion
docker-compose exec postgres psql -U postgres -d hungertalk_db -c "SELECT 1;"

# Vérifier les variables d'environnement
docker-compose exec backend env | grep DATABASE
```

### Ollama n'est pas accessible

- Vérifier qu'Ollama est démarré sur votre machine
- Vérifier qu'il écoute sur le port 11434
- Pour Windows/Mac, `host.docker.internal` devrait fonctionner
- Pour Linux, vous devrez peut-être utiliser `172.17.0.1` ou configurer le réseau différemment

### Port déjà utilisé

Si le port 5432 (PostgreSQL) ou 8000 (Backend) est déjà utilisé :

```yaml
# Modifier dans docker-compose.yml
ports:
  - "5433:5432"  # Utiliser 5433 au lieu de 5432
  - "8001:8000"  # Utiliser 8001 au lieu de 8000
```

Pensez aussi à mettre à jour `DATABASE_URL` si vous changez le port PostgreSQL.

---

## 📦 Production

Pour la production, utilisez :

```bash
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

Cela applique les configurations de production (pas de reload, plus de workers, etc.).

---

## 🔐 Sécurité

⚠️ **Important pour la production** :

1. **Ne pas commiter les mots de passe** : Utiliser des secrets Docker ou des variables d'environnement
2. **Changer le mot de passe PostgreSQL** par défaut
3. **Utiliser HTTPS** pour le backend
4. **Configurer les limites de ressources** dans docker-compose.prod.yml

---

## 📚 Ressources

- [Documentation Docker](https://docs.docker.com/)
- [Documentation Docker Compose](https://docs.docker.com/compose/)
- [FastAPI avec Docker](https://fastapi.tiangolo.com/deployment/docker/)

---

**Bon développement avec Docker ! 🐳**

