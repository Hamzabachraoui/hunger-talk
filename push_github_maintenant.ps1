# Script pour pousser directement sur GitHub
# Le repository doit exister sur GitHub

Write-Host "Push vers GitHub..." -ForegroundColor Yellow

$username = "hamzabachraoui"
$repoName = "hunger-talk"

# Vérifier si le remote existe
$remoteExists = git remote get-url origin 2>$null
if (-not $remoteExists) {
    Write-Host "Configuration du remote..." -ForegroundColor Yellow
    git remote add origin "https://github.com/$username/$repoName.git"
}

# Renommer la branche en main
git branch -M main 2>$null

Write-Host ""
Write-Host "Tentative de push..." -ForegroundColor Yellow
Write-Host "Si le repository n'existe pas, crée-le d'abord sur: https://github.com/new" -ForegroundColor Cyan
Write-Host ""

git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Code poussé avec succès!" -ForegroundColor Green
    Write-Host "Repository: https://github.com/$username/$repoName" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "❌ Le repository n'existe pas encore sur GitHub" -ForegroundColor Red
    Write-Host ""
    Write-Host "Crée-le rapidement:" -ForegroundColor Yellow
    Write-Host "1. Va sur: https://github.com/new" -ForegroundColor White
    Write-Host "2. Nom: $repoName" -ForegroundColor White
    Write-Host "3. NE COCHE PAS 'Initialize with README'" -ForegroundColor Red
    Write-Host "4. Clique 'Create repository'" -ForegroundColor White
    Write-Host ""
    Write-Host "Ensuite relance ce script ou exécute: git push -u origin main" -ForegroundColor Cyan
}
