# Script pour démarrer le serveur FastAPI
# Affiche l'adresse IP actuelle pour accès depuis mobile

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Démarrage du serveur Hunger-Talk" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier si on est dans le bon répertoire
if (-not (Test-Path "backend\main.py")) {
    Write-Host "❌ Erreur: Ce script doit être exécuté depuis la racine du projet" -ForegroundColor Red
    exit 1
}

# Activer l'environnement virtuel
if (Test-Path "backend\venv\Scripts\Activate.ps1") {
    Write-Host "✅ Activation de l'environnement virtuel..." -ForegroundColor Green
    & "backend\venv\Scripts\Activate.ps1"
} else {
    Write-Host "⚠️  Environnement virtuel non trouvé. Vérifiez votre installation." -ForegroundColor Yellow
}

# Obtenir l'adresse IP actuelle
Write-Host ""
Write-Host "📡 Adresses IP disponibles:" -ForegroundColor Yellow
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" } | Select-Object -ExpandProperty IPAddress

foreach ($ip in $ipAddresses) {
    Write-Host "   → http://$ip:8000" -ForegroundColor Green
}

Write-Host ""
Write-Host "💡 Utilisez l'une de ces adresses sur votre téléphone" -ForegroundColor Cyan
Write-Host "💡 Assurez-vous que votre téléphone est sur le même réseau Wi-Fi" -ForegroundColor Cyan
Write-Host ""

# Vérifier si le port 8000 est déjà utilisé
$portInUse = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "⚠️  Le port 8000 est déjà utilisé!" -ForegroundColor Yellow
    Write-Host "   Arrêt du processus existant..." -ForegroundColor Yellow
    $process = Get-Process -Id ($portInUse | Select-Object -First 1 -ExpandProperty OwningProcess) -ErrorAction SilentlyContinue
    if ($process) {
        Stop-Process -Id $process.Id -Force
        Start-Sleep -Seconds 2
    }
}

# Changer vers le répertoire backend
Set-Location backend

Write-Host "🚀 Démarrage du serveur FastAPI..." -ForegroundColor Green
Write-Host "   Le serveur écoute sur 0.0.0.0:8000 (toutes les interfaces)" -ForegroundColor Gray
Write-Host "   Appuyez sur Ctrl+C pour arrêter le serveur" -ForegroundColor Gray
Write-Host ""

# Démarrer le serveur
python main.py
