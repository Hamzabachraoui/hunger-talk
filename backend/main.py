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
# redirect_slashes=True par défaut - FastAPI redirige automatiquement /api/stock vers /api/stock/
# Mais cela peut causer la perte des headers lors de la redirection
# On garde le comportement par défaut mais on ajoute des routes explicites pour les deux formats
app = FastAPI(
    title=settings.APP_NAME,
    description="API pour l'application mobile de gestion nutritionnelle et alimentaire",
    version=settings.APP_VERSION,
    # Évite les redirections 307 qui suppriment parfois les headers Authorization
    redirect_slashes=False
)

# Configuration CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Middleware de logging pour déboguer les problèmes d'authentification
@app.middleware("http")
async def log_requests(http_request, call_next):
    import logging
    logger = logging.getLogger(__name__)
    
    # Logger les informations de la requête
    auth_header = http_request.headers.get("authorization") or http_request.headers.get("Authorization")
    logger.info(f"📥 [REQUEST] {http_request.method} {http_request.url.path}")
    logger.info(f"   🔗 Full URL: {http_request.url}")
    if auth_header:
        logger.info(f"   🔑 Authorization: {auth_header[:50]}...")
    else:
        logger.warning(f"   ⚠️ Pas de header Authorization")
    
    try:
        response = await call_next(http_request)
        logger.info(f"📤 [RESPONSE] {http_request.method} {http_request.url.path} - {response.status_code}")
        return response
    except Exception as e:
        logger.error(f"❌ [ERROR] {http_request.method} {http_request.url.path} - {e}")
        raise

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
    import logging
    logger = logging.getLogger(__name__)
    
    # Initialiser la base de données (créer les tables si elles n'existent pas)
    try:
        # Vérifier si DATABASE_URL est configuré (pas la valeur par défaut localhost)
        if "localhost" in settings.DATABASE_URL or "127.0.0.1" in settings.DATABASE_URL:
            logger.error("❌ DATABASE_URL n'est pas configuré dans Railway !")
            logger.error("⚠️ L'application utilise la valeur par défaut (localhost) qui ne fonctionne pas sur Railway")
            logger.error("📋 Pour corriger : Railway → Service → Variables → Ajouter DATABASE_URL = ${{Postgres.DATABASE_URL}}")
        init_db()
        logger.info("✅ Base de données initialisée")
    except Exception as e:
        # Ne pas bloquer le démarrage si la connexion échoue
        logger.error(f"❌ Erreur lors de l'initialisation de la base de données: {e}")
        if "localhost" in str(e) or "127.0.0.1" in str(e):
            logger.error("📋 SOLUTION : Ajoute DATABASE_URL dans Railway → Variables")
            logger.error("   Nom: DATABASE_URL")
            logger.error("   Valeur: Clique 'Add Reference' → Sélectionne PostgreSQL → DATABASE_URL")
        logger.warning("⚠️ L'application démarre mais la base de données n'est pas accessible")
    
    # Initialiser les données de base (catégories, recettes) si nécessaire
    # Cette initialisation est idempotente (peut être exécutée plusieurs fois)
    try:
        from scripts.init_database import init_database
        init_database()
    except Exception as e:
        # Ne pas bloquer le démarrage si l'initialisation échoue
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
