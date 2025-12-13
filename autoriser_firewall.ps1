# Script pour autoriser le port 8000 dans le firewall Windows
# Nécessite des droits administrateur

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Configuration du Firewall Windows" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier les droits administrateur
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ Ce script nécessite des droits administrateur" -ForegroundColor Red
    Write-Host "   Cliquez-droit sur le script et sélectionnez 'Exécuter en tant qu'administrateur'" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 1
}

# Vérifier si la règle existe déjà
$existingRule = Get-NetFirewallRule -DisplayName "Hunger-Talk API - Port 8000" -ErrorAction SilentlyContinue

if ($existingRule) {
    Write-Host "✅ La règle firewall existe déjà" -ForegroundColor Green
    Write-Host "   Suppression de l'ancienne règle..." -ForegroundColor Yellow
    Remove-NetFirewallRule -DisplayName "Hunger-Talk API - Port 8000" -ErrorAction SilentlyContinue
}

# Créer la règle firewall pour le port 8000 (entrant)
Write-Host "🔧 Création de la règle firewall pour le port 8000 (entrant)..." -ForegroundColor Yellow
New-NetFirewallRule -DisplayName "Hunger-Talk API - Port 8000" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 8000 `
    -Action Allow `
    -Profile Domain,Private,Public `
    -Description "Autorise l'accès au serveur FastAPI Hunger-Talk depuis le réseau local" | Out-Null

if ($?) {
    Write-Host "✅ Règle firewall créée avec succès!" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors de la création de la règle firewall" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Configuration terminée!" -ForegroundColor Green
Write-Host "   Le port 8000 est maintenant accessible depuis votre réseau local" -ForegroundColor Cyan
Write-Host ""
