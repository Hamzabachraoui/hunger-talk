# Script de nettoyage complet et build propre de l'APK Flutter
# Ce script supprime tous les caches et fichiers de build pour forcer une compilation propre

Write-Host "🧹 Nettoyage complet du projet Flutter..." -ForegroundColor Cyan
Write-Host ""

# Aller dans le dossier mobile
Set-Location $PSScriptRoot

# 1. Nettoyer le cache Flutter global
Write-Host "1️⃣ Nettoyage du cache Flutter global..." -ForegroundColor Yellow
flutter clean

# 2. Supprimer le dossier build
Write-Host "2️⃣ Suppression du dossier build..." -ForegroundColor Yellow
if (Test-Path "build") {
    Remove-Item -Recurse -Force "build"
    Write-Host "   ✅ Dossier build supprimé" -ForegroundColor Green
} else {
    Write-Host "   ℹ️ Dossier build n'existe pas" -ForegroundColor Gray
}

# 3. Supprimer .dart_tool
Write-Host "3️⃣ Suppression de .dart_tool..." -ForegroundColor Yellow
if (Test-Path ".dart_tool") {
    Remove-Item -Recurse -Force ".dart_tool"
    Write-Host "   ✅ .dart_tool supprimé" -ForegroundColor Green
} else {
    Write-Host "   ℹ️ .dart_tool n'existe pas" -ForegroundColor Gray
}

# 4. Supprimer .flutter-plugins
Write-Host "4️⃣ Suppression des fichiers de plugins..." -ForegroundColor Yellow
@(".flutter-plugins", ".flutter-plugins-dependencies", ".packages") | ForEach-Object {
    if (Test-Path $_) {
        Remove-Item -Force $_
        Write-Host "   ✅ $_ supprimé" -ForegroundColor Green
    }
}

# 5. Nettoyer le cache pub
Write-Host "5️⃣ Nettoyage du cache pub..." -ForegroundColor Yellow
flutter pub cache clean

# 6. Récupérer les dépendances à nouveau
Write-Host "6️⃣ Récupération des dépendances..." -ForegroundColor Yellow
flutter pub get

# 7. Nettoyer le cache Gradle (Android)
Write-Host "7️⃣ Nettoyage du cache Gradle (Android)..." -ForegroundColor Yellow
if (Test-Path "android\.gradle") {
    Remove-Item -Recurse -Force "android\.gradle"
    Write-Host "   ✅ Cache Gradle supprimé" -ForegroundColor Green
}

if (Test-Path "android\build") {
    Remove-Item -Recurse -Force "android\build"
    Write-Host "   ✅ Dossier android\build supprimé" -ForegroundColor Green
}

if (Test-Path "android\app\build") {
    Remove-Item -Recurse -Force "android\app\build"
    Write-Host "   ✅ Dossier android\app\build supprimé" -ForegroundColor Green
}

# 8. Nettoyer le cache Gradle global (optionnel mais recommandé)
Write-Host "8️⃣ Nettoyage du cache Gradle global..." -ForegroundColor Yellow
$gradleCache = "$env:USERPROFILE\.gradle\caches"
if (Test-Path $gradleCache) {
    $cacheSize = (Get-ChildItem -Path $gradleCache -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "   📊 Taille du cache: $([math]::Round($cacheSize, 2)) MB" -ForegroundColor Gray
    Write-Host "   ⚠️ Cache Gradle global trouvé à: $gradleCache" -ForegroundColor Yellow
    Write-Host "   💡 Pour nettoyer complètement, exécutez: Remove-Item -Recurse -Force '$gradleCache'" -ForegroundColor Cyan
    Write-Host "   ℹ️ Ou utilisez l'option -CleanGradleCache pour nettoyer automatiquement" -ForegroundColor Cyan
}

# 9. Vérifier l'état Flutter
Write-Host ""
Write-Host "9️⃣ Vérification de l'état Flutter..." -ForegroundColor Yellow
flutter doctor -v

Write-Host ""
Write-Host "✅ Nettoyage terminé !" -ForegroundColor Green
Write-Host ""
Write-Host "📦 Pour construire l'APK maintenant, exécutez:" -ForegroundColor Cyan
Write-Host "   flutter build apk --release" -ForegroundColor White
Write-Host ""
Write-Host "💡 Ou exécutez ce script avec l'option -Build pour build automatiquement:" -ForegroundColor Cyan
Write-Host "   .\clean_build.ps1 -Build" -ForegroundColor White
Write-Host ""

# Options pour build automatiquement et nettoyer Gradle
param(
    [switch]$Build,
    [switch]$CleanGradleCache
)

# Nettoyer le cache Gradle global si demandé
if ($CleanGradleCache) {
    Write-Host ""
    Write-Host "🗑️ Nettoyage du cache Gradle global..." -ForegroundColor Yellow
    $gradleCache = "$env:USERPROFILE\.gradle\caches"
    if (Test-Path $gradleCache) {
        Remove-Item -Recurse -Force $gradleCache -ErrorAction SilentlyContinue
        Write-Host "   ✅ Cache Gradle global supprimé" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️ Cache Gradle global n'existe pas" -ForegroundColor Gray
    }
}

if ($Build) {
    Write-Host "🚀 Construction de l'APK en mode release..." -ForegroundColor Cyan
    Write-Host ""
    flutter build apk --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ APK construit avec succès !" -ForegroundColor Green
        Write-Host "📱 Fichier: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "❌ Erreur lors de la construction de l'APK" -ForegroundColor Red
    }
}
