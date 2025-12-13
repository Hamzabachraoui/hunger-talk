# 🐳 Docker - Démarrage Rapide

## Prérequis

- Docker Desktop installé et démarré

## Commandes essentielles

```bash
# Démarrer tous les services
docker-compose up -d

# Voir les logs
docker-compose logs -f

# Arrêter
docker-compose down

# Reconstruire
docker-compose build
```

## Accès

- **API Backend** : http://localhost:8000
- **Documentation** : http://localhost:8000/docs
- **PostgreSQL** : localhost:5432

## Configuration Ollama

Ollama reste en local. Le backend y accède via `host.docker.internal:11434`.

Assurez-vous qu'Ollama est démarré sur votre machine.

---

Pour plus de détails, voir `docs/DOCKER_GUIDE.md`

