"""
Script pour créer la table system_config dans Railway
Utilise DATABASE_URL depuis Railway (via variable d'environnement)
"""
import os
import sys
from pathlib import Path

# Ajouter le chemin backend
backend_path = Path(__file__).parent / "backend"
sys.path.insert(0, str(backend_path))

from sqlalchemy import create_engine, text
from config import settings

# Utiliser DATABASE_URL depuis les variables d'environnement ou settings
database_url = os.getenv("DATABASE_URL", settings.DATABASE_URL)

print(f"🔌 Connexion à la base de données Railway...")
print(f"   URL: {database_url[:50]}...")  # Afficher seulement le début pour sécurité

try:
    engine = create_engine(database_url, pool_pre_ping=True)
    
    with engine.connect() as conn:
        print("📋 Vérification si la table system_config existe...")
        
        # Vérifier si la table existe
        check_table = text("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'system_config'
            );
        """)
        result = conn.execute(check_table)
        table_exists = result.scalar()
        
        if table_exists:
            print("✅ La table system_config existe déjà !")
        else:
            print("📋 Création de la table system_config...")
            
            # Créer la table
            conn.execute(text("""
                CREATE TABLE system_config (
                    key VARCHAR(100) PRIMARY KEY,
                    value VARCHAR(500) NOT NULL,
                    description VARCHAR(500),
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
                    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
                );
            """))
            
            # Créer l'index
            conn.execute(text("""
                CREATE INDEX ix_system_config_key ON system_config (key);
            """))
            
            conn.commit()
            print("✅ Table system_config créée avec succès !")
        
        # Vérifier le contenu
        result = conn.execute(text("SELECT COUNT(*) FROM system_config"))
        count = result.scalar()
        print(f"📊 Nombre d'enregistrements: {count}")
        
except Exception as e:
    print(f"❌ Erreur: {e}")
    print("\n💡 Vérifiez que:")
    print("   1. DATABASE_URL est correct (depuis Railway → Variables)")
    print("   2. La connexion à Railway fonctionne")
    sys.exit(1)

