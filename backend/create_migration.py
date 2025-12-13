"""
Script pour créer la migration initiale avec Alembic
"""
import subprocess
import sys
from pathlib import Path

def main():
    backend_path = Path(__file__).parent
    os.chdir(backend_path)
    
    print("=" * 60)
    print("Création de la migration initiale avec Alembic")
    print("=" * 60)
    print()
    
    # Vérifier que Alembic est installé
    try:
        import alembic
        print("✅ Alembic est installé")
    except ImportError:
        print("❌ Alembic n'est pas installé. Installez-le avec : pip install alembic")
        return 1
    
    print()
    print("🔄 Création de la migration initiale...")
    print()
    
    # Créer la migration
    result = subprocess.run(
        ["python", "-m", "alembic", "revision", "--autogenerate", "-m", "Initial migration - Create all tables"],
        capture_output=True,
        text=True,
        cwd=backend_path
    )
    
    if result.returncode == 0:
        print(result.stdout)
        print("✅ Migration créée avec succès !")
        print()
        print("📋 Pour appliquer la migration, exécutez :")
        print("   alembic upgrade head")
        return 0
    else:
        print("❌ Erreur lors de la création de la migration :")
        print(result.stderr)
        return 1

if __name__ == "__main__":
    import os
    sys.exit(main())

