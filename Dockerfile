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
# Railway définit PORT automatiquement
# Créer un script de démarrage pour gérer le PORT correctement
RUN echo '#!/bin/sh\necho "Starting Uvicorn on port: $PORT"\nuvicorn main:app --host 0.0.0.0 --port $PORT' > /app/start.sh && chmod +x /app/start.sh

CMD ["/app/start.sh"]
