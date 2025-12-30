# Script pour détecter automatiquement l'IP locale d'Ollama et l'enregistrer dans Railway
# À exécuter au démarrage du PC ou périodiquement

param(
    [string]$RailwayUrl = "https://hunger-talk-production.up.railway.app"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Enregistrement IP Ollama dans Railway" -ForegroundColor Cyan
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
    exit 1
}

Write-Host ""
Write-Host "🔐 Enregistrement dans Railway..." -ForegroundColor Yellow

# Obtenir un token JWT depuis l'API Railway
# On va utiliser un compte système ou demander à l'utilisateur de fournir les credentials
# Pour l'instant, on essaie de se connecter avec un utilisateur système

# Option 1 : Si vous avez des credentials système, utilisez-les
# $loginBody = @{
#     email = "votre_email@example.com"
#     password = "votre_password"
# } | ConvertTo-Json
# 
# $loginResponse = Invoke-RestMethod -Uri "$RailwayUrl/api/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
# $token = $loginResponse.access_token

# Option 2 : Utiliser une variable d'environnement avec un token
$token = $env:RAILWAY_TOKEN

if (-not $token) {
    Write-Host "⚠️ Token JWT non trouvé dans la variable d'environnement RAILWAY_TOKEN" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 Pour obtenir un token:" -ForegroundColor Cyan
    Write-Host "   1. Connectez-vous à l'app mobile" -ForegroundColor White
    Write-Host "   2. Récupérez le token depuis les logs ou le storage" -ForegroundColor White
    Write-Host "   3. Définissez: `$env:RAILWAY_TOKEN = 'votre_token'" -ForegroundColor White
    Write-Host ""
    Write-Host "   OU créez un compte système dédié pour cette fonctionnalité" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Enregistrer l'IP via l'API Railway
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

try {
    $encodedUrl = [System.Web.HttpUtility]::UrlEncode($ollamaURL)
    $response = Invoke-RestMethod -Uri "$RailwayUrl/api/system-config/ollama/base-url?value=$encodedUrl" -Method Put -Headers $headers -ErrorAction Stop
    
    Write-Host "✅ IP Ollama enregistrée avec succès dans Railway !" -ForegroundColor Green
    Write-Host "   URL: $ollamaURL" -ForegroundColor White
    Write-Host "   Railway utilisera cette IP pour appeler Ollama" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Erreur lors de l'enregistrement:" -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "   Réponse: $responseBody" -ForegroundColor Red
    }
    exit 1
}

Write-Host ""
Write-Host "✅ Terminé !" -ForegroundColor Green

