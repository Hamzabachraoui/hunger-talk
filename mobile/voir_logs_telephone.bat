@echo off
echo ========================================
echo   LOGS FLUTTER - TELEPHONE ANDROID
echo ========================================
echo.

REM Vérifier si Flutter est disponible
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] Flutter n'est pas dans le PATH
    echo Installez Flutter ou ajoutez-le au PATH
    pause
    exit /b 1
)

echo Verification des appareils connectes...
echo.
flutter devices
echo.

echo ========================================
echo   INSTRUCTIONS
echo ========================================
echo.
echo 1. Assurez-vous que votre telephone est connecte via USB
echo 2. Activez le Mode Developpeur sur votre telephone
echo 3. Activez le Debogage USB
echo 4. Autorisez cet ordinateur sur votre telephone
echo.
echo Appuyez sur Entree pour lancer les logs...
pause >nul

echo.
echo ========================================
echo   LOGS EN TEMPS REEL
echo ========================================
echo Appuyez sur Ctrl+C pour arreter
echo.

flutter logs

pause

