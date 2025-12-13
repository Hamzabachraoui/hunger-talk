"""
Script pour créer et appliquer la migration initiale avec Alembic
"""
import os
import sys
import subprocess
from pathlib import Path

def run_command(cmd, description):
    """Exécuter une commande et afficher le résultat"""
    print(f"\n🔄 {description}...")
    print("-" * 60)
    
    result = subprocess.run(
        cmd,
        shell=True,
        capture_output=True,
        text=True,
        cwd=Path(__file__).parent.parent
    )
    
    if result.stdout:
        print(result.stdout)
    if result.stderr:
        print(result.stderr, file=sys.stderr)
    
    if result.returncode != 0:
        print(f"❌ Erreur: {description} a échoué")
        return False
    
    print(f"✅ {description} réussi")
    return True

def main():
    backend_path = Path(__file__).parent.parent
    os.chdir(backend_path)
    
    print("=" * 60)
    print("  Création et application de la migration Alembic")
    print("=" * 60)
    
    # Vérifier que l'environnement virtuel est activé
    if not hasattr(sys, 'real_prefix') and not (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix):
        print("\n⚠️  Attention: L'environnement virtuel ne semble pas être activé")
        print("   Activez-le avec: .\\venv\\Scripts\\Activate.ps1")
        response = input("\nContinuer quand même ? (o/n): ")
        if response.lower() != 'o':
            return 1
    
    # Étape 1: Créer la migration
    success = run_command(
        'python -m alembic revision --autogenerate -m "Initial migration - Create all tables"',
        "Création de la migration initiale"
    )
    
    if not success:
        return 1
    
    # Vérifier qu'un fichier de migration a été créé
    versions_dir = backend_path / "alembic" / "versions"
    migration_files = list(versions_dir.glob("*.py"))
    
    if not migration_files:
        print("\n❌ Aucun fichier de migration créé. Vérifiez les erreurs ci-dessus.")
        return 1
    
    print(f"\n📁 Migration créée: {migration_files[0].name}")
    
    # Étape 2: Appliquer la migration
    response = input("\n⚠️  Appliquer la migration maintenant ? (o/n): ")
    if response.lower() == 'o':
        success = run_command(
            'python -m alembic upgrade head',
            "Application de la migration"
        )
        
        if success:
            print("\n" + "=" * 60)
            print("✅ Migration appliquée avec succès !")
            print("=" * 60)
            print("\n💡 Vous pouvez maintenant initialiser les catégories:")
            print("   python scripts/init_categories.py")
            return 0
        else:
            return 1
    else:
        print("\n💡 Pour appliquer la migration plus tard, exécutez:")
        print("   alembic upgrade head")
        return 0

if __name__ == "__main__":
    sys.exit(main())

