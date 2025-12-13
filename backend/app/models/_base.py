"""
Fichier pour centraliser les imports de Base
Permet d'éviter les problèmes d'imports circulaires
"""
import sys
from pathlib import Path

# Ajouter le chemin backend au sys.path
backend_path = Path(__file__).parent.parent.parent
if str(backend_path) not in sys.path:
    sys.path.insert(0, str(backend_path))

from database import Base

__all__ = ["Base"]

