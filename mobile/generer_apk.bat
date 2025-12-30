@echo off
REM Script batch pour générer l'APK de l'application Hunger-Talk
REM Usage: generer_apk.bat

echo.
echo ===============================================================
echo 📱 GENERATION DE L'APK - HUNGER-TALK
echo ===============================================================
echo.

REM Vérifier que Flutter est installé
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter n'est pas installé ou n'est pas dans le PATH
    echo 📥 Installez Flutter depuis: https://flutter.dev/docs/get-started/install/windows
    pause
    exit /b 1
)

REM Vérifier que nous sommes dans le bon dossier
if not exist "pubspec.yaml" (
    echo ❌ Ce script doit être exécuté depuis le dossier mobile/
    pause
    exit /b 1
)

echo 🔍 Vérification de Flutter...
flutter --version
echo.

echo 🧹 Nettoyage des builds précédents...
flutter clean
echo.

echo 📦 Récupération des dépendances...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Erreur lors de la récupération des dépendances
    pause
    exit /b 1
)
echo ✅ Dépendances récupérées
echo.

echo 🔍 Vérification du code...
flutter analyze
echo.

echo 🔨 Génération de l'APK (mode release)...
echo ⏳ Cela peut prendre plusieurs minutes...
echo.

flutter build apk --release

if %errorlevel% neq 0 (
    echo.
    echo ❌ Erreur lors de la génération de l'APK
    echo 💡 Vérifiez les erreurs ci-dessus
    pause
    exit /b 1
)

REM Vérifier que l'APK existe
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo.
    echo ===============================================================
    echo ✅ APK GENERÉ AVEC SUCCÈS !
    echo ===============================================================
    echo.
    echo 📱 Fichier APK:
    echo    build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo 📋 PROCHAINES ÉTAPES:
    echo 1. Transférez l'APK sur votre téléphone Android
    echo 2. Activez 'Sources inconnues' dans les paramètres de sécurité
    echo 3. Installez l'APK en le tapant dessus
    echo.
    
    REM Ouvrir le dossier
    explorer build\app\outputs\flutter-apk
) else (
    echo.
    echo ❌ L'APK n'a pas été trouvé
    echo 💡 Vérifiez les erreurs ci-dessus
)

pause

