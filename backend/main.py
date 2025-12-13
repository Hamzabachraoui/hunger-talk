"""
Main FastAPI application - Hunger-Talk
"""
import sys
from pathlib import Path

# Ajouter le répertoire backend au path pour les imports
backend_path = Path(__file__).parent
sys.path.insert(0, str(backend_path))

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from config import settings
from database import engine, init_db

# Créer l'application FastAPI
app = FastAPI(
    title=settings.APP_NAME,
    description="API pour l'application mobile de gestion nutritionnelle et alimentaire",
    version=settings.APP_VERSION
)

# Configuration CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Importer les routers
from app.routers import auth, stock, chat, recipes, recommendations, nutrition, notifications, shopping_list, user

# Inclure les routers
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(stock.router, prefix="/api/stock", tags=["stock"])
app.include_router(chat.router, prefix="/api/chat", tags=["chat"])
app.include_router(recipes.router, prefix="/api/recipes", tags=["recipes"])
app.include_router(recommendations.router, prefix="/api/recommendations", tags=["recommendations"])
app.include_router(nutrition.router, prefix="/api/nutrition", tags=["nutrition"])
app.include_router(notifications.router, prefix="/api/notifications", tags=["notifications"])
app.include_router(shopping_list.router, prefix="/api/shopping-list", tags=["shopping-list"])
app.include_router(user.router, prefix="/api/user", tags=["user"])


@app.on_event("startup")
async def startup_event():
    """Actions à effectuer au démarrage de l'application"""
    # Initialiser la base de données (créer les tables si elles n'existent pas)
    init_db()
    print("✅ Base de données initialisée")
    
    # Initialiser les données de base (catégories, recettes) si nécessaire
    # Cette initialisation est idempotente (peut être exécutée plusieurs fois)
    try:
        from scripts.init_database import init_database
        init_database()
    except Exception as e:
        # Ne pas bloquer le démarrage si l'initialisation échoue
        import logging
        logger = logging.getLogger(__name__)
        logger.warning(f"Initialisation des données de base échouée (non bloquant): {e}")


@app.get("/")
async def root():
    """Point d'entrée de l'API"""
    return {
        "message": "Bienvenue sur l'API Hunger-Talk",
        "version": settings.APP_VERSION,
        "status": "running",
        "docs": "/docs"
    }


@app.get("/health")
async def health_check():
    """Vérification de l'état de l'API"""
    return {
        "status": "healthy",
        "service": "hunger-talk-api",
        "version": settings.APP_VERSION
    }


if __name__ == "__main__":
    import uvicorn
    import os
    # Railway fournit le port via la variable d'environnement PORT
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port, reload=settings.DEBUG)
