# Script pour enregistrer automatiquement l'IP locale Ollama dans Railway
# À exécuter au démarrage du PC ou après chaque changement d'IP WiFi

param(
    [string]$RailwayUrl = "https://hunger-talk-production.up.railway.app",
    [string]$Email = "",
    [string]$Password = ""
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
$ollamaURL = "http://$localIP`:11434"

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
Write-Host "🔐 Connexion à Railway..." -ForegroundColor Yellow

# Si email et password sont fournis, se connecter
if ($Email -and $Password) {
    Write-Host "⚠️ L'authentification par email/password n'est pas implémentée" -ForegroundColor Yellow
    Write-Host "   Vous devez utiliser un token JWT" -ForegroundColor Yellow
    Write-Host ""
}

# Demander le token JWT
if (-not $env:RAILWAY_TOKEN) {
    Write-Host "📝 Pour enregistrer l'IP, vous avez besoin d'un token JWT de Railway" -ForegroundColor Cyan
    Write-Host "   1. Connectez-vous à votre app mobile" -ForegroundColor Cyan
    Write-Host "   2. Récupérez le token depuis les logs ou le code" -ForegroundColor Cyan
    Write-Host "   3. Ou utilisez l'endpoint directement depuis l'app" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "💡 Solution alternative: Créer un endpoint public avec une clé secrète" -ForegroundColor Yellow
    Write-Host ""
    
    $token = Read-Host "Token JWT (laisser vide pour skip)"
    if (-not $token) {
        Write-Host ""
        Write-Host "⚠️ Token non fourni. L'URL Ollama sera:" -ForegroundColor Yellow
        Write-Host "   $ollamaURL" -ForegroundColor White
        Write-Host ""
        Write-Host "📋 Pour l'enregistrer manuellement:" -ForegroundColor Cyan
        Write-Host "   1. Connectez-vous à Railway" -ForegroundColor Cyan
        Write-Host "   2. Allez dans votre service backend → Variables" -ForegroundColor Cyan
        Write-Host "   3. Ou utilisez l'API: PUT $RailwayUrl/api/system-config/ollama/base-url?value=$ollamaURL" -ForegroundColor Cyan
        exit 0
    }
} else {
    $token = $env:RAILWAY_TOKEN
}

# Enregistrer l'IP via l'API Railway
Write-Host ""
Write-Host "📤 Envoi de l'IP à Railway..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri "$RailwayUrl/api/system-config/ollama/base-url?value=$([System.Web.HttpUtility]::UrlEncode($ollamaURL))" -Method Put -Headers $headers -ErrorAction Stop
    Write-Host "✅ IP Ollama enregistrée avec succès !" -ForegroundColor Green
    Write-Host "   URL: $ollamaURL" -ForegroundColor White
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
Write-Host "   L'IP Ollama est maintenant enregistrée dans Railway" -ForegroundColor White

