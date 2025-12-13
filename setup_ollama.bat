@echo off
REM Script d'aide pour installer et configurer Ollama - Hunger-Talk
echo ========================================
echo Configuration Ollama - Hunger-Talk
echo ========================================
echo.

echo ETAPE 1: Installation de Ollama
echo --------------------------------
echo 1. Téléchargez Ollama depuis: https://ollama.ai/download
echo 2. Exécutez l'installateur (ollama-windows-amd64.exe)
echo 3. Ollama se lance automatiquement
echo.
pause

echo.
echo ETAPE 2: Vérification de l'installation
echo ---------------------------------------
ollama --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Ollama n'est pas installe ou n'est pas dans le PATH
    echo Veuillez redemarrer votre terminal apres l'installation
    pause
    exit /b 1
) else (
    echo [OK] Ollama detecte
    ollama --version
)

echo.
echo ETAPE 3: Téléchargement du modèle LLaMA 3.1 8B
echo -----------------------------------------------
echo Cette etape peut prendre plusieurs minutes (modele de ~4.7 GB)
echo Assurez-vous d'avoir une bonne connexion internet
echo.
set /p confirm="Voulez-vous telecharger le modele maintenant? (O/N): "
if /i "%confirm%"=="O" (
    echo.
    echo Telechargement en cours...
    ollama pull llama3.1:8b
    if errorlevel 1 (
        echo [ERREUR] Le telechargement a echoue
        echo Verifiez votre connexion internet et reessayez
        pause
        exit /b 1
    ) else (
        echo [OK] Modele LLaMA 3.1:8b telecharge avec succes!
    )
) else (
    echo.
    echo Vous pouvez telecharger le modele plus tard avec:
    echo   ollama pull llama3.1:8b
)

echo.
echo ETAPE 4: Vérification du modèle
echo --------------------------------
ollama list
echo.
if errorlevel 1 (
    echo [ATTENTION] Impossible de lister les modeles
    echo Assurez-vous qu'Ollama est demarre
) else (
    echo [OK] Verifiez que llama3.1:8b apparaît dans la liste ci-dessus
)

echo.
echo ETAPE 5: Test du modèle
echo -----------------------
set /p test="Voulez-vous tester le modele maintenant? (O/N): "
if /i "%test%"=="O" (
    echo.
    echo Test du modele (tapez 'exit' pour quitter)...
    ollama run llama3.1:8b "Bonjour, comment allez-vous?"
) else (
    echo.
    echo Vous pouvez tester le modele plus tard avec:
    echo   ollama run llama3.1:8b "Votre question ici"
)

echo.
echo ========================================
echo Configuration Ollama terminee!
echo ========================================
echo.
echo Prochaines etapes:
echo  1. Verifiez que Ollama est bien demarre
echo  2. Le serveur Ollama devrait etre accessible sur http://localhost:11434
echo  3. N'oubliez pas de mettre a jour le fichier backend/.env avec:
echo     OLLAMA_BASE_URL=http://localhost:11434
echo     OLLAMA_MODEL=llama3.1:8b
echo.

