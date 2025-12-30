@echo off
REM Script de nettoyage complet et build propre de l'APK Flutter
REM Ce script supprime tous les caches et fichiers de build pour forcer une compilation propre

echo.
echo ========================================
echo   NETTOYAGE COMPLET FLUTTER
echo ========================================
echo.

cd /d "%~dp0"

echo [1/9] Nettoyage du cache Flutter global...
call flutter clean
echo.

echo [2/9] Suppression du dossier build...
if exist "build" (
    rmdir /s /q "build"
    echo    OK: Dossier build supprime
) else (
    echo    INFO: Dossier build n'existe pas
)
echo.

echo [3/9] Suppression de .dart_tool...
if exist ".dart_tool" (
    rmdir /s /q ".dart_tool"
    echo    OK: .dart_tool supprime
) else (
    echo    INFO: .dart_tool n'existe pas
)
echo.

echo [4/9] Suppression des fichiers de plugins...
if exist ".flutter-plugins" del /q ".flutter-plugins"
if exist ".flutter-plugins-dependencies" del /q ".flutter-plugins-dependencies"
if exist ".packages" del /q ".packages"
echo    OK: Fichiers de plugins supprimes
echo.

echo [5/9] Nettoyage du cache pub...
call flutter pub cache clean
echo.

echo [6/9] Recuperation des dependances...
call flutter pub get
echo.

echo [7/9] Nettoyage du cache Gradle (Android)...
if exist "android\.gradle" (
    rmdir /s /q "android\.gradle"
    echo    OK: Cache Gradle supprime
)
if exist "android\build" (
    rmdir /s /q "android\build"
    echo    OK: Dossier android\build supprime
)
if exist "android\app\build" (
    rmdir /s /q "android\app\build"
    echo    OK: Dossier android\app\build supprime
)
echo.

echo [8/9] Verification de l'etat Flutter...
call flutter doctor -v
echo.

echo [9/9] Construction de l'APK en mode release...
call flutter build apk --release
echo.

if %ERRORLEVEL% EQU 0 (
    echo ========================================
    echo   SUCCES !
    echo ========================================
    echo.
    echo APK construit avec succes !
    echo Fichier: build\app\outputs\flutter-apk\app-release.apk
    echo.
) else (
    echo ========================================
    echo   ERREUR
    echo ========================================
    echo.
    echo Erreur lors de la construction de l'APK
    echo.
)

pause
