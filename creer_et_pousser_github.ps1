# Script pour créer le repository GitHub et pousser le code
# Nécessite GitHub CLI (gh) ou création manuelle du repository

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Création Repository GitHub + Push" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Demander le nom d'utilisateur GitHub
$username = Read-Host "Entre ton nom d'utilisateur GitHub exact"

# Nom du repository
$repoName = "hunger-talk"

Write-Host ""
Write-Host "Vérification de GitHub CLI..." -ForegroundColor Yellow

# Vérifier si GitHub CLI est installé
$ghInstalled = Get-Command gh -ErrorAction SilentlyContinue

if ($ghInstalled) {
    Write-Host "GitHub CLI trouvé !" -ForegroundColor Green
    Write-Host "Création du repository sur GitHub..." -ForegroundColor Yellow
    
    # Créer le repository via GitHub CLI
    gh repo create $repoName --public --source=. --remote=origin --push
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "  ✅ Repository créé et code poussé!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Repository: https://github.com/$username/$repoName" -ForegroundColor Cyan
        exit 0
    } else {
        Write-Host "Erreur lors de la création via GitHub CLI" -ForegroundColor Red
        Write-Host "Passage à la méthode manuelle..." -ForegroundColor Yellow
    }
} else {
    Write-Host "GitHub CLI non installé" -ForegroundColor Yellow
    Write-Host "Utilisation de la méthode manuelle..." -ForegroundColor Yellow
}

# Méthode manuelle : le repository doit être créé sur GitHub d'abord
Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  Méthode Manuelle" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Crée le repository sur GitHub:" -ForegroundColor Cyan
Write-Host "   https://github.com/new" -ForegroundColor White
Write-Host ""
Write-Host "   Nom: $repoName" -ForegroundColor White
Write-Host "   NE COCHE PAS 'Initialize with README'" -ForegroundColor Red
Write-Host ""
$continue = Read-Host "Appuie sur Entrée une fois le repository créé"

Write-Host ""
Write-Host "Configuration du remote..." -ForegroundColor Yellow
$remoteUrl = "https://github.com/$username/$repoName.git"
git remote add origin $remoteUrl

Write-Host "Renommage de la branche..." -ForegroundColor Yellow
git branch -M main

Write-Host ""
Write-Host "Push vers GitHub..." -ForegroundColor Yellow
Write-Host "Tu devras entrer tes identifiants GitHub" -ForegroundColor Cyan
Write-Host ""

git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✅ Code poussé avec succès!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Repository: https://github.com/$username/$repoName" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Prochaine étape: Connecter Railway!" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  ❌ Erreur lors du push" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Vérifie que:" -ForegroundColor Yellow
    Write-Host "  1. Le repository existe sur GitHub" -ForegroundColor Yellow
    Write-Host "  2. Tu as les droits d'écriture" -ForegroundColor Yellow
    Write-Host "  3. Tes identifiants sont corrects" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Pour l'authentification GitHub, utilise un Personal Access Token" -ForegroundColor Cyan
    Write-Host "Voir: https://github.com/settings/tokens" -ForegroundColor Cyan
}
