@echo off
REM Script batch pour démarrer Ollama et créer un tunnel ngrok
REM Usage: demarrer_ollama_tunnel.bat

echo 🚀 Démarrage d'Ollama et création du tunnel...

REM Vérifier si Ollama est installé
where ollama >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Ollama n'est pas installé ou n'est pas dans le PATH
    echo 📥 Téléchargez Ollama depuis: https://ollama.com/download
    pause
    exit /b 1
)

REM Vérifier si ngrok est installé
where ngrok >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ngrok n'est pas installé ou n'est pas dans le PATH
    echo 📥 Téléchargez ngrok depuis: https://ngrok.com/download
    echo 💡 Après installation, configurez votre token: ngrok config add-authtoken VOTRE_TOKEN
    pause
    exit /b 1
)

REM Vérifier si Ollama est déjà en cours d'exécution
tasklist /FI "IMAGENAME eq ollama.exe" 2>NUL | find /I /N "ollama.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo ✅ Ollama est déjà en cours d'exécution
) else (
    echo 🔄 Démarrage d'Ollama...
    start /MIN ollama serve
    timeout /t 3 /nobreak >nul
    echo ✅ Ollama démarré
)

REM Vérifier que le modèle est installé
echo 🔍 Vérification du modèle llama3.1:8b...
curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Impossible de se connecter à Ollama. Vérifiez qu'il est démarré.
    pause
    exit /b 1
)

echo ✅ Ollama est accessible

REM Démarrer ngrok
echo.
echo 🌐 Démarrage du tunnel ngrok...
echo ⚠️ IMPORTANT: Notez l'URL 'Forwarding' qui apparaîtra ci-dessous
echo ⚠️ Vous devrez l'ajouter dans Railway comme variable OLLAMA_BASE_URL
echo.
echo Appuyez sur Ctrl+C pour arrêter le tunnel
echo.

start ngrok http 11434

echo.
echo ✅ Tunnel démarré !
echo.
echo 📋 PROCHAINES ÉTAPES:
echo 1. Notez l'URL 'Forwarding' dans la fenêtre ngrok (ex: https://abc123.ngrok-free.app)
echo 2. Allez sur Railway Dashboard → Votre Service → Variables
echo 3. Ajoutez/modifiez: OLLAMA_BASE_URL = votre_url_ngrok
echo 4. Attendez le redéploiement (2-3 minutes)
echo.
echo 💡 Pour arrêter: Fermez cette fenêtre et la fenêtre ngrok
echo.

pause

