# Script pour pousser le projet sur GitHub
# Remplace USERNAME par ton nom d'utilisateur GitHub

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Push vers GitHub" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Demander le nom d'utilisateur GitHub
$username = Read-Host "Entre ton nom d'utilisateur GitHub"

# Demander le nom du repository
$repoName = Read-Host "Entre le nom du repository (ex: hunger-talk)"

Write-Host ""
Write-Host "Configuration du remote GitHub..." -ForegroundColor Yellow

# Vérifier si le remote existe déjà
$existingRemote = git remote get-url origin 2>$null
if ($existingRemote) {
    Write-Host "Remote 'origin' existe déjà. Suppression..." -ForegroundColor Yellow
    git remote remove origin
}

# Ajouter le remote
$remoteUrl = "https://github.com/$username/$repoName.git"
Write-Host "Ajout du remote: $remoteUrl" -ForegroundColor Green
git remote add origin $remoteUrl

Write-Host ""
Write-Host "Renommage de la branche en 'main'..." -ForegroundColor Yellow
git branch -M main

Write-Host ""
Write-Host "Push vers GitHub..." -ForegroundColor Yellow
Write-Host "Tu devras peut-etre entrer tes identifiants GitHub" -ForegroundColor Cyan
Write-Host ""

git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✅ Code poussé sur GitHub avec succès!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Repository: https://github.com/$username/$repoName" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Prochaine etape: Connecter Railway a ce repository!" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  ❌ Erreur lors du push" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifie que:" -ForegroundColor Yellow
    Write-Host "  1. Le repository existe sur GitHub" -ForegroundColor Yellow
    Write-Host "  2. Tu as les droits d'ecriture" -ForegroundColor Yellow
    Write-Host "  3. Tes identifiants GitHub sont corrects" -ForegroundColor Yellow
}
