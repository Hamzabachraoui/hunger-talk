#!/bin/sh
# Script de démarrage pour Railway
# Railway définit automatiquement la variable PORT

echo "🚀 Starting Hunger-Talk API..."
echo "📦 PORT environment variable: $PORT"

# Si PORT n'est pas défini, utiliser 8000 par défaut
if [ -z "$PORT" ]; then
  PORT=8000
  echo "⚠️  PORT not set, using default: $PORT"
else
  echo "✅ Using PORT: $PORT"
fi

# Démarrer Uvicorn
echo "🌐 Starting Uvicorn on 0.0.0.0:$PORT"
exec uvicorn main:app --host 0.0.0.0 --port $PORT
