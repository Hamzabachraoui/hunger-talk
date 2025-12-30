# Script pour générer l'APK de l'application Hunger-Talk
# Usage: .\generer_apk.ps1

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📱 GÉNÉRATION DE L'APK - HUNGER-TALK" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Vérifier que Flutter est installé
Write-Host "🔍 Vérification de Flutter..." -ForegroundColor Cyan
$flutterInstalled = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterInstalled) {
    Write-Host "❌ Flutter n'est pas installé ou n'est pas dans le PATH" -ForegroundColor Red
    Write-Host "📥 Installez Flutter depuis: https://flutter.dev/docs/get-started/install/windows" -ForegroundColor Yellow
    exit 1
}

# Afficher la version de Flutter
$flutterVersion = flutter --version | Select-String "Flutter" | Select-Object -First 1
Write-Host "✅ Flutter trouvé: $flutterVersion" -ForegroundColor Green
Write-Host ""

# Vérifier que nous sommes dans le bon dossier
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Ce script doit être exécuté depuis le dossier mobile/" -ForegroundColor Red
    exit 1
}

# Nettoyer les builds précédents
Write-Host "🧹 Nettoyage des builds précédents..." -ForegroundColor Cyan
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Erreur lors du nettoyage, mais on continue..." -ForegroundColor Yellow
}
Write-Host ""

# Récupérer les dépendances
Write-Host "📦 Récupération des dépendances..." -ForegroundColor Cyan
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors de la récupération des dépendances" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Dépendances récupérées" -ForegroundColor Green
Write-Host ""

# Vérifier qu'il n'y a pas d'erreurs
Write-Host "🔍 Vérification du code..." -ForegroundColor Cyan
flutter analyze
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Des avertissements ont été détectés, mais on continue..." -ForegroundColor Yellow
}
Write-Host ""

# Générer l'APK en mode release
Write-Host "🔨 Génération de l'APK (mode release)..." -ForegroundColor Cyan
Write-Host "⏳ Cela peut prendre plusieurs minutes..." -ForegroundColor Yellow
Write-Host ""

flutter build apk --release

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Erreur lors de la génération de l'APK" -ForegroundColor Red
    Write-Host "💡 Vérifiez les erreurs ci-dessus" -ForegroundColor Yellow
    exit 1
}

# Trouver l'APK généré
$apkPath = "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $apkPath) {
    $apkFullPath = Resolve-Path $apkPath
    $apkSize = (Get-Item $apkPath).Length / 1MB
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "✅ APK GÉNÉRÉ AVEC SUCCÈS !" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "📱 Fichier APK:" -ForegroundColor Cyan
    Write-Host "   $apkFullPath" -ForegroundColor White
    Write-Host ""
    Write-Host "📊 Taille: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📋 PROCHAINES ÉTAPES:" -ForegroundColor Cyan
    Write-Host "1. Transférez l'APK sur votre téléphone Android" -ForegroundColor White
    Write-Host "2. Activez 'Sources inconnues' dans les paramètres de sécurité" -ForegroundColor White
    Write-Host "3. Installez l'APK en le tapant dessus" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Pour ouvrir le dossier:" -ForegroundColor Gray
    Write-Host "   explorer build\app\outputs\flutter-apk" -ForegroundColor Gray
    Write-Host ""
    
    # Ouvrir le dossier automatiquement
    Start-Process explorer.exe -ArgumentList "build\app\outputs\flutter-apk"
} else {
    Write-Host ""
    Write-Host "❌ L'APK n'a pas été trouvé à l'emplacement attendu" -ForegroundColor Red
    Write-Host "💡 Vérifiez les erreurs ci-dessus" -ForegroundColor Yellow
    exit 1
}

