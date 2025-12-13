@echo off
REM Script d'initialisation de l'environnement backend - Hunger-Talk
echo ========================================
echo Initialisation de l'environnement backend
echo ========================================
echo.

REM Vérifier si Python est installé
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python n'est pas installe ou n'est pas dans le PATH
    echo Veuillez installer Python 3.10 ou superieur
    pause
    exit /b 1
)

echo [OK] Python detecte
echo.

REM Créer l'environnement virtuel
echo Creation de l'environnement virtuel...
python -m venv venv
if errorlevel 1 (
    echo [ERREUR] Impossible de creer l'environnement virtuel
    pause
    exit /b 1
)
echo [OK] Environnement virtuel cree
echo.

REM Activer l'environnement virtuel
echo Activation de l'environnement virtuel...
call venv\Scripts\activate.bat

REM Mettre à jour pip
echo Mise a jour de pip...
python -m pip install --upgrade pip
echo.

REM Installer les dépendances
echo Installation des dependances...
pip install -r requirements.txt
if errorlevel 1 (
    echo [ERREUR] Impossible d'installer les dependances
    pause
    exit /b 1
)
echo [OK] Dependances installees
echo.

REM Créer le fichier .env s'il n'existe pas
if not exist .env (
    echo Creation du fichier .env...
    copy env.example .env
    echo [OK] Fichier .env cree a partir de env.example
    echo [ATTENTION] N'oubliez pas de configurer les variables dans .env
) else (
    echo [INFO] Le fichier .env existe deja
)
echo.

echo ========================================
echo Initialisation terminee avec succes !
echo ========================================
echo.
echo Prochaines etapes :
echo 1. Configurez le fichier .env avec vos parametres
echo 2. Creez la base de donnees PostgreSQL
echo 3. Lancez le serveur avec: uvicorn main:app --reload
echo.
pause

