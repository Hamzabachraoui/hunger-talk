# Script PowerShell pour créer la base de données Hunger-Talk
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Création de la base de données" -ForegroundColor Cyan
Write-Host "  Hunger-Talk" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Activer l'environnement virtuel
Write-Host "🔄 Activation de l'environnement virtuel..." -ForegroundColor Yellow
& ".\venv\Scripts\Activate.ps1"

Write-Host ""
Write-Host "🔄 Création des tables de la base de données..." -ForegroundColor Yellow
python scripts/create_database.py

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "🔄 Initialisation des catégories..." -ForegroundColor Yellow
    python scripts/init_categories.py
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✅ Base de données créée avec succès !" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  ❌ Erreur lors de la création" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
}

