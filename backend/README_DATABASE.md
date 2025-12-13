# Guide de gestion des bases de données

## ⚠️ Important : Deux environnements de base de données

Ce projet utilise **deux bases de données distinctes** selon l'environnement :

### 1. Base de données locale (développement hors Docker)
- **URL** : `postgresql://postgres:hamza@localhost:5433/hungertalk_db`
- **Port** : `5433` (pour éviter les conflits avec PostgreSQL local)
- **Utilisation** : Développement local avec Python directement

### 2. Base de données Docker
- **URL** : `postgresql://postgres:hamza@postgres:5432/hungertalk_db`
- **Port** : `5432` (interne au réseau Docker)
- **Utilisation** : Développement avec Docker Compose

## 🔍 Vérifier quelle base de données est utilisée

```bash
# Depuis le répertoire backend
python scripts/check_database.py
```

Ce script affiche :
- L'URL de la base de données (mot de passe masqué)
- L'environnement (Docker ou Local)
- Le nombre d'enregistrements dans chaque table
- Des avertissements si des données manquent

## 🚀 Initialisation automatique

**Lors du démarrage du backend dans Docker**, les données de base sont automatiquement initialisées :
- Catégories
- Recettes d'exemple

Cette initialisation est **idempotente** : elle peut être exécutée plusieurs fois sans créer de doublons.

## 📝 Initialisation manuelle

Si vous devez initialiser manuellement :

### Dans Docker :
```bash
docker exec hungertalk_backend python scripts/init_database.py
```

### En local :
```bash
python scripts/init_database.py
```

## 🔧 Scripts disponibles

### `scripts/check_database.py`
Vérifie l'état de la base de données actuelle.

### `scripts/init_database.py`
Initialise toutes les données de base (catégories + recettes).

### `scripts/init_categories.py`
Initialise uniquement les catégories.

### `scripts/add_sample_recipes.py`
Ajoute uniquement les recettes d'exemple.

## 💡 Bonnes pratiques

1. **Toujours vérifier l'environnement** avant d'ajouter des données :
   ```bash
   python scripts/check_database.py
   ```

2. **Utiliser Docker en production** : Les données sont persistées dans le volume Docker `postgres_data`.

3. **Synchronisation** : Si vous ajoutez des données en local, elles ne seront **pas** disponibles dans Docker (et vice versa).

4. **Migrations** : Les migrations Alembic fonctionnent dans les deux environnements, mais doivent être exécutées dans le bon contexte.

## 🐛 Dépannage

### Problème : "Aucune recette trouvée" dans l'API
**Solution** : Vérifiez d'abord quelle base de données est utilisée :
```bash
python scripts/check_database.py
```

Si vous êtes dans Docker et qu'il n'y a pas de recettes :
```bash
docker exec hungertalk_backend python scripts/add_sample_recipes.py
```

### Problème : Conflit de port
Si le port 5433 est déjà utilisé, modifiez-le dans :
- `docker-compose.yml` (ligne 13)
- `backend/.env` (DATABASE_URL)

