#!/bin/bash
# Script d'initialisation de l'environnement backend - Hunger-Talk

echo "========================================"
echo "Initialisation de l'environnement backend"
echo "========================================"
echo ""

# Vérifier si Python est installé
if ! command -v python3 &> /dev/null; then
    echo "[ERREUR] Python n'est pas installé ou n'est pas dans le PATH"
    echo "Veuillez installer Python 3.10 ou supérieur"
    exit 1
fi

echo "[OK] Python détecté"
echo ""

# Créer l'environnement virtuel
echo "Création de l'environnement virtuel..."
python3 -m venv venv
if [ $? -ne 0 ]; then
    echo "[ERREUR] Impossible de créer l'environnement virtuel"
    exit 1
fi
echo "[OK] Environnement virtuel créé"
echo ""

# Activer l'environnement virtuel
echo "Activation de l'environnement virtuel..."
source venv/bin/activate

# Mettre à jour pip
echo "Mise à jour de pip..."
pip install --upgrade pip
echo ""

# Installer les dépendances
echo "Installation des dépendances..."
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "[ERREUR] Impossible d'installer les dépendances"
    exit 1
fi
echo "[OK] Dépendances installées"
echo ""

# Créer le fichier .env s'il n'existe pas
if [ ! -f .env ]; then
    echo "Création du fichier .env..."
    cp env.example .env
    echo "[OK] Fichier .env créé à partir de env.example"
    echo "[ATTENTION] N'oubliez pas de configurer les variables dans .env"
else
    echo "[INFO] Le fichier .env existe déjà"
fi
echo ""

echo "========================================"
echo "Initialisation terminée avec succès !"
echo "========================================"
echo ""
echo "Prochaines étapes :"
echo "1. Configurez le fichier .env avec vos paramètres"
echo "2. Créez la base de données PostgreSQL"
echo "3. Lancez le serveur avec: uvicorn main:app --reload"
echo ""

