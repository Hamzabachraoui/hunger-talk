# 📋 Vérifier et Créer la Table system_config dans Railway

## Option 1 : Vérifier les Logs Railway

1. Allez sur Railway → Votre service backend
2. Deployments → Dernier déploiement → Logs
3. Cherchez "Base de données initialisée" ou des erreurs
4. Si vous voyez des erreurs, la table n'a peut-être pas été créée

## Option 2 : Créer la Table avec le Script Python

Le script `creer_table_railway.py` crée la table directement dans Railway.

**Pour l'utiliser, vous devez :**

1. Récupérer DATABASE_URL depuis Railway :
   - Railway → PostgreSQL → Variables → DATABASE_URL
   - Copiez la valeur

2. Définir la variable d'environnement :
   ```powershell
   $env:DATABASE_URL = "postgresql://postgres:xxx@postgres.railway.internal:5432/railway"
   ```

3. Exécuter le script :
   ```powershell
   python creer_table_railway.py
   ```

**OU** utilisez Railway CLI si disponible.

## Option 3 : La Table sera Créée Automatiquement

Le code dans `main.py` appelle `init_db()` qui utilise `Base.metadata.create_all()`.
Cela devrait créer toutes les tables manquantes, y compris `system_config`.

Si Railway redéploie, la table devrait être créée automatiquement au prochain démarrage.

