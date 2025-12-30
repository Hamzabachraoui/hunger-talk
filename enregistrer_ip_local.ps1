# Script simple pour enregistrer l'IP Ollama localement
# Ce script enregistre directement dans la base de données locale

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Enregistrement IP Ollama Localement" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Détecter l'IP locale
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.IPAddress -like "192.168.*" -or 
    $_.IPAddress -like "10.*" -or 
    $_.IPAddress -like "172.16.*"
} | Select-Object -ExpandProperty IPAddress

if (-not $ipAddresses) {
    Write-Host "❌ Aucune adresse IP locale trouvée" -ForegroundColor Red
    exit 1
}

# Prendre la première IP (généralement celle du WiFi)
$localIP = $ipAddresses[0]
$ollamaURL = "http://$localIP:11434"

Write-Host "📍 IP locale détectée: $localIP" -ForegroundColor Green
Write-Host "🔗 URL Ollama: $ollamaURL" -ForegroundColor Green
Write-Host ""

# Vérifier qu'Ollama répond
Write-Host "🔍 Vérification qu'Ollama répond sur localhost:11434..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 5 -ErrorAction Stop
    Write-Host "✅ Ollama fonctionne localement" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Ollama ne répond pas sur localhost:11434" -ForegroundColor Yellow
    Write-Host "   Assurez-vous qu'Ollama est démarré" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continuer quand même ? (O/N)"
    if ($continue -ne "O" -and $continue -ne "o") {
        exit 1
    }
}

Write-Host ""
Write-Host "💾 Enregistrement dans la base de données locale..." -ForegroundColor Yellow

# Script Python pour enregistrer dans la DB
$pythonScript = @"
import sys
from pathlib import Path
sys.path.insert(0, str(Path('backend').absolute()))

from database import SessionLocal
from app.services.system_config_service import set_ollama_base_url

db = SessionLocal()
try:
    config = set_ollama_base_url(db, '$ollamaURL')
    print(f'✅ IP Ollama enregistrée: {config.value}')
    print(f'   Clé: {config.key}')
    print(f'   Mis à jour: {config.updated_at}')
except Exception as e:
    print(f'❌ Erreur: {e}')
    sys.exit(1)
finally:
    db.close()
"@

# Exécuter le script Python
try {
    $result = python -c $pythonScript 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host $result -ForegroundColor Green
        Write-Host ""
        Write-Host "✅ IP Ollama enregistrée avec succès dans la base de données locale !" -ForegroundColor Green
        Write-Host "   Railway utilisera automatiquement cette IP" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "❌ Erreur lors de l'enregistrement:" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host ""
    Write-Host "❌ Erreur lors de l'exécution du script Python:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Terminé ! L'IP Ollama est maintenant enregistrée." -ForegroundColor Green

