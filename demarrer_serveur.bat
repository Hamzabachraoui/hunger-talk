@echo off
REM Script pour démarrer le serveur FastAPI
REM Affiche l'adresse IP actuelle pour accès depuis mobile

echo ========================================
echo   Démarrage du serveur Hunger-Talk
echo ========================================
echo.

REM Vérifier si on est dans le bon répertoire
if not exist "backend\main.py" (
    echo ❌ Erreur: Ce script doit être exécuté depuis la racine du projet
    pause
    exit /b 1
)

REM Afficher les adresses IP
echo 📡 Adresses IP disponibles:
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    set ip=%%a
    set ip=!ip:~1!
    echo    → http://!ip!:8000
)

echo.
echo 💡 Utilisez l'une de ces adresses sur votre téléphone
echo 💡 Assurez-vous que votre téléphone est sur le même réseau Wi-Fi
echo.

REM Vérifier si le port 8000 est déjà utilisé
netstat -ano | findstr :8000 >nul
if %errorlevel% == 0 (
    echo ⚠️  Le port 8000 est déjà utilisé!
    echo    Arrêt du processus existant...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8000 ^| findstr LISTENING') do (
        taskkill /F /PID %%a >nul 2>&1
    )
    timeout /t 2 /nobreak >nul
)

REM Activer l'environnement virtuel et démarrer le serveur
cd backend
if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
) else (
    echo ⚠️  Environnement virtuel non trouvé. Vérifiez votre installation.
)

echo.
echo 🚀 Démarrage du serveur FastAPI...
echo    Le serveur écoute sur 0.0.0.0:8000 (toutes les interfaces)
echo    Appuyez sur Ctrl+C pour arrêter le serveur
echo.

python main.py

pause
