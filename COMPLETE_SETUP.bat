@echo off
REM Script complet de configuration - Hunger-Talk
echo ========================================
echo Configuration Complete - Hunger-Talk
echo ========================================
echo.
echo Ce script va vous guider dans la configuration complete du projet.
echo.
pause

REM Vérifier les outils installés
echo.
echo ========================================
echo ETAPE 1: Verification des outils
echo ========================================
echo.
powershell -ExecutionPolicy Bypass -File install_all_tools.ps1
if errorlevel 1 (
    echo [ATTENTION] Impossible d'executer le script de verification
    echo Continuez manuellement...
)

echo.
pause

REM PostgreSQL
echo.
echo ========================================
echo ETAPE 2: Configuration PostgreSQL
echo ========================================
echo.
echo Voulez-vous configurer PostgreSQL maintenant? (O/N)
set /p config_pg="> "
if /i "%config_pg%"=="O" (
    call setup_postgresql.bat
)

echo.
pause

REM Ollama
echo.
echo ========================================
echo ETAPE 3: Configuration Ollama
echo ========================================
echo.
echo Voulez-vous configurer Ollama maintenant? (O/N)
set /p config_ollama="> "
if /i "%config_ollama%"=="O" (
    call setup_ollama.bat
)

REM Backend setup
echo.
echo ========================================
echo ETAPE 4: Configuration du Backend
echo ========================================
echo.
echo Voulez-vous initialiser l'environnement backend maintenant? (O/N)
set /p config_backend="> "
if /i "%config_backend%"=="O" (
    cd backend
    call init_setup.bat
    cd ..
)

echo.
echo ========================================
echo Configuration terminee!
echo ========================================
echo.
echo Resume:
echo  - Outils: Verifiez avec install_all_tools.ps1
echo  - PostgreSQL: Base de donnees hungertalk_db creee
echo  - Ollama: Modele LLaMA 3.1:8b telecharge
echo  - Backend: Environnement virtuel Python configure
echo.
echo Prochaines etapes:
echo  1. Configurez le fichier backend/.env avec vos identifiants
echo  2. Lancez le serveur backend: cd backend && uvicorn main:app --reload
echo  3. Consultez docs/INSTALLATION_TOOLS.md pour plus de details
echo.
pause

