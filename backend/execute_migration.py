"""
Script pour créer et appliquer la migration Alembic
"""
import subprocess
import sys
import os
from pathlib import Path

def run_command(command, description):
    """Exécuter une commande et afficher le résultat"""
    print(f"\n{'='*60}")
    print(f"{description}")
    print('='*60)
    
    try:
        # Exécuter la commande
        result = subprocess.run(
            command,
            shell=True,
            cwd=Path(__file__).parent,
            capture_output=True,
            text=True,
            encoding='utf-8',
            errors='replace'
        )
        
        # Afficher la sortie
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print("STDERR:", file=sys.stderr)
            print(result.stderr, file=sys.stderr)
        
        return result.returncode == 0, result.stdout, result.stderr
        
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False, "", str(e)

def main():
    backend_path = Path(__file__).parent
    
    print("="*60)
    print("  CRÉATION ET APPLICATION DE LA MIGRATION ALEMBIC")
    print("="*60)
    
    # Étape 1: Créer la migration
    print("\n📝 ÉTAPE 1: Création de la migration initiale...")
    success, stdout, stderr = run_command(
        'python -m alembic revision --autogenerate -m "Initial migration - Create all tables"',
        "Création de la migration"
    )
    
    if not success:
        print("\n❌ Échec de la création de la migration")
        if stderr:
            print(f"\nErreur: {stderr}")
        return 1
    
    # Vérifier si un fichier a été créé
    versions_dir = backend_path / "alembic" / "versions"
    if versions_dir.exists():
        migration_files = list(versions_dir.glob("*.py"))
        if migration_files:
            print(f"\n✅ Migration créée: {migration_files[-1].name}")
        else:
            print("\n⚠️  Aucun fichier de migration trouvé")
            if "No changes" in stdout:
                print("   (Aucun changement détecté - peut-être que les tables existent déjà)")
    else:
        print("\n⚠️  Le dossier alembic/versions n'existe pas")
        versions_dir.mkdir(parents=True, exist_ok=True)
    
    # Étape 2: Appliquer la migration
    print("\n\n📝 ÉTAPE 2: Application de la migration...")
    success, stdout, stderr = run_command(
        'python -m alembic upgrade head',
        "Application de la migration"
    )
    
    if success:
        print("\n" + "="*60)
        print("✅ MIGRATION APPLIQUÉE AVEC SUCCÈS !")
        print("="*60)
        
        # Étape 3: Initialiser les catégories
        print("\n\n📝 ÉTAPE 3: Initialisation des catégories...")
        success, stdout, stderr = run_command(
            'python scripts/init_categories.py',
            "Initialisation des catégories"
        )
        
        if success:
            print("\n" + "="*60)
            print("✅ BASE DE DONNÉES COMPLÈTEMENT INITIALISÉE !")
            print("="*60)
            return 0
        else:
            print("\n⚠️  Les catégories n'ont pas pu être initialisées")
            print("   Vous pouvez le faire manuellement plus tard avec:")
            print("   python scripts/init_categories.py")
            return 0
    else:
        print("\n❌ Échec de l'application de la migration")
        if stderr:
            print(f"\nErreur: {stderr}")
        return 1

if __name__ == "__main__":
    sys.exit(main())












