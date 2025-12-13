# Dockerfile pour Railway - Build depuis backend/
FROM python:3.11-slim

WORKDIR /app

# Installer les dépendances système nécessaires pour psycopg2
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copier seulement le dossier backend
COPY backend/ /app/

# Installer les dépendances Python
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Exposer le port (Railway définit PORT automatiquement)
EXPOSE ${PORT:-8000}

# Démarrer l'application
# Railway définit PORT automatiquement, on utilise sh pour interpréter la variable
# Si PORT n'est pas défini, utiliser 8000 par défaut
CMD sh -c "uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}"
