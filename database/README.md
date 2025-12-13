# Base de données - Hunger-Talk

Ce dossier contiendra les scripts SQL et les migrations de la base de données.

## Structure prévue

- `schema.sql` - Schéma complet de la base de données (à créer)
- `migrations/` - Fichiers de migration Alembic (à créer)
- `seeds/` - Données de test/exemple (à créer)

## Création de la base de données

### Méthode 1 : Via pgAdmin
1. Ouvrir pgAdmin 4
2. Se connecter avec les identifiants PostgreSQL
3. Clic droit sur "Databases" > Create > Database
4. Nom : `hungertalk_db`
5. Owner : `postgres`

### Méthode 2 : Via psql
```bash
psql -U postgres -c "CREATE DATABASE hungertalk_db;"
```

### Méthode 3 : Via script SQL
```bash
psql -U postgres -f ../backend/create_db.sql
```

## Prochaines étapes

Une fois la base de données créée, les tables seront créées automatiquement par :
1. Alembic (migrations)
2. Ou via le schéma SQL (à créer dans PHASE 1)

## Configuration

La connexion à la base de données se fait via le fichier `backend/.env` :
```
DATABASE_URL=postgresql://postgres:mot_de_passe@localhost:5432/hungertalk_db
```

