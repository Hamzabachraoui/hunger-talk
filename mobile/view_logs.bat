@echo off
echo ========================================
echo   AFFICHAGE DES LOGS FLUTTER
echo ========================================
echo.

REM Trouver le chemin d'ADB
set ADB_PATH=
set ANDROID_SDK=%LOCALAPPDATA%\Android\Sdk
set ADB_PATH=%ANDROID_SDK%\platform-tools\adb.exe

REM Vérifier si adb existe
if not exist "%ADB_PATH%" (
    echo [ERREUR] ADB introuvable a: %ADB_PATH%
    echo.
    echo Tentative avec flutter logs...
    echo.
    goto :use_flutter
)

REM Vérifier si flutter est disponible
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Flutter n'est pas dans le PATH, utilisation d'ADB direct
    goto :use_adb
)

REM Demander quelle méthode utiliser
echo ADB trouve: %ADB_PATH%
echo Flutter disponible
echo.
goto :menu

:use_flutter
echo Utilisation de Flutter pour les logs...
echo.
flutter logs
pause
exit /b 0

:use_adb
echo Utilisation d'ADB direct...
echo.

:menu

REM Vérifier les appareils connectés
echo Verification des appareils connectes...
adb devices
echo.

REM Demander quelle méthode utiliser
echo Choisissez une option:
echo 1. Flutter logs (recommandé - fonctionne toujours)
echo 2. Logs Flutter filtres (via ADB)
echo 3. Tous les logs Android (via ADB)
echo 4. Logs d'erreur uniquement (via ADB)
echo 5. Logs avec filtre personnalise (via ADB)
echo.
set /p choice="Votre choix (1-5): "

if "%choice%"=="1" (
    echo.
    echo Option 1: Utiliser Flutter logs (recommandé)
    echo Appuyez sur Ctrl+C pour arreter
    echo.
    flutter logs
) else if "%choice%"=="2" (
    echo.
    echo Option 2: Logs Flutter filtres (via ADB)
    echo Appuyez sur Ctrl+C pour arreter
    echo.
    "%ADB_PATH%" logcat | findstr /i "flutter"
) else if "%choice%"=="3" (
    echo.
    echo Option 3: Tous les logs Android
    echo Appuyez sur Ctrl+C pour arreter
    echo.
    "%ADB_PATH%" logcat
) else if "%choice%"=="4" (
    echo.
    echo Option 4: Logs d'erreur uniquement
    echo Appuyez sur Ctrl+C pour arreter
    echo.
    "%ADB_PATH%" logcat *:E
) else if "%choice%"=="5" (
    echo.
    set /p filter="Entrez le filtre (ex: hunger_talk, API, Error): "
    echo.
    echo [LOGS FILTRES] Appuyez sur Ctrl+C pour arreter
    echo.
    "%ADB_PATH%" logcat | findstr /i "%filter%"
) else (
    echo Choix invalide
    pause
    exit /b 1
)

pause

