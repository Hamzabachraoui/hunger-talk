# Script pour pousser le projet sur GitHub
# Utilisez ce script après avoir créé le repository sur GitHub

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Push du projet Hunger-Talk sur GitHub" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Demander l'URL du repository GitHub
Write-Host "⚠️ IMPORTANT: Vous devez d'abord créer le repository sur GitHub" -ForegroundColor Yellow
Write-Host "   1. Allez sur https://github.com/new" -ForegroundColor Cyan
Write-Host "   2. Nom du repository: hunger-talk (ou autre nom)" -ForegroundColor Cyan
Write-Host "   3. Visibilité: Public ou Private (selon votre choix)" -ForegroundColor Cyan
Write-Host "   4. NE PAS initialiser avec README, .gitignore, ou licence" -ForegroundColor Yellow
Write-Host "   5. Cliquez sur 'Create repository'" -ForegroundColor Cyan
Write-Host ""

$repoUrl = Read-Host "Entrez l'URL complète de votre repository GitHub (ex: https://github.com/username/hunger-talk.git)"

if ([string]::IsNullOrWhiteSpace($repoUrl)) {
    Write-Host "❌ URL vide. Arrêt." -ForegroundColor Red
    exit 1
}

# Vérifier que git est initialisé
if (-not (Test-Path ".git")) {
    Write-Host "❌ Git n'est pas initialisé. Exécutez d'abord: git init" -ForegroundColor Red
    exit 1
}

# Vérifier qu'il y a un commit
$hasCommit = git log --oneline -1 2>$null
if (-not $hasCommit) {
    Write-Host "❌ Aucun commit trouvé. Exécutez d'abord: git commit -m 'Initial commit'" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Git initialisé avec commits" -ForegroundColor Green
Write-Host ""

# Ajouter le remote origin
Write-Host "🔗 Configuration du remote origin..." -ForegroundColor Yellow
git remote remove origin 2>$null
git remote add origin $repoUrl

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Remote origin configuré: $repoUrl" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors de la configuration du remote" -ForegroundColor Red
    exit 1
}

# Pousser sur GitHub
Write-Host ""
Write-Host "📤 Push vers GitHub..." -ForegroundColor Yellow
Write-Host ""

git branch -M main
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✅ Code poussé sur GitHub avec succès!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Repository: $repoUrl" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🎉 Prochaines étapes:" -ForegroundColor Yellow
    Write-Host "   1. Allez sur Railway Dashboard" -ForegroundColor Cyan
    Write-Host "   2. Settings → Connect GitHub Repository" -ForegroundColor Cyan
    Write-Host "   3. Sélectionnez votre repository" -ForegroundColor Cyan
    Write-Host "   4. Railway redéploiera automatiquement!" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "❌ Erreur lors du push" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Vérifiez que:" -ForegroundColor Yellow
    Write-Host "   - L'URL du repository est correcte" -ForegroundColor Yellow
    Write-Host "   - Vous avez les permissions d'écriture" -ForegroundColor Yellow
    Write-Host "   - Le repository existe sur GitHub" -ForegroundColor Yellow
    exit 1
}

