# Backend FastAPI - Hunger-Talk

## 🚀 Démarrage rapide

### Avec l'environnement virtuel local

```bash
# Activer l'environnement virtuel
.\venv\Scripts\Activate.ps1  # Windows PowerShell
# ou
venv\Scripts\activate.bat    # Windows CMD

# Lancer le serveur
uvicorn main:app --reload
```

### Avec Docker

```bash
# Depuis la racine du projet
docker-compose up -d backend
```

## 📁 Structure du projet

```
backend/
├── app/
│   ├── models/          # Modèles SQLAlchemy
│   ├── schemas/         # Schemas Pydantic
│   ├── routers/         # Routes API
│   ├── services/        # Services métier
│   ├── core/            # Utilitaires de base (security, dependencies)
│   └── utils/           # Fonctions utilitaires
├── alembic/             # Migrations de base de données
├── main.py              # Point d'entrée de l'application
├── config.py            # Configuration
├── database.py          # Configuration SQLAlchemy
└── requirements.txt     # Dépendances Python
```

## 🔧 Configuration

1. Copier `env.example` en `.env`
2. Configurer les variables :
   - `DATABASE_URL` : URL de connexion PostgreSQL
   - `SECRET_KEY` : Clé secrète pour JWT
   - `OLLAMA_BASE_URL` : URL d'Ollama (http://localhost:11434)

## 🗄️ Migrations Alembic

```bash
# Créer une nouvelle migration
alembic revision --autogenerate -m "Description"

# Appliquer les migrations
alembic upgrade head

# Revenir en arrière
alembic downgrade -1
```

## 📚 Documentation API

Une fois le serveur démarré :
- Swagger UI : http://localhost:8000/docs
- ReDoc : http://localhost:8000/redoc

## 🧪 Tests

```bash
pytest
```

## 📝 Variables d'environnement

Voir `env.example` pour la liste complète des variables.

