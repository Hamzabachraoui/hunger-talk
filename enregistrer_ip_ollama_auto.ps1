# Script pour démarrer Cloudflare Tunnel et enregistrer l'URL dans Railway
# Ce script démarre le tunnel qui expose Ollama local, puis enregistre l'URL dans Railway

param(
    [string]$RailwayUrl = "https://hunger-talk-production.up.railway.app"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Tunnel Cloudflare + Enregistrement Railway" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier qu'Ollama répond
Write-Host "🔍 Vérification qu'Ollama répond sur localhost:11434..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 5 -ErrorAction Stop
    Write-Host "✅ Ollama fonctionne localement" -ForegroundColor Green
} catch {
    Write-Host "❌ Ollama ne répond pas sur localhost:11434" -ForegroundColor Red
    Write-Host "   Assurez-vous qu'Ollama est démarré" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🌐 Démarrage du tunnel Cloudflare..." -ForegroundColor Yellow
Write-Host "   Cela expose Ollama (localhost:11434) via Cloudflare Tunnel" -ForegroundColor Gray
Write-Host ""

# Vérifier si cloudflared est installé
$cloudflared = Get-Command cloudflared -ErrorAction SilentlyContinue
if (-not $cloudflared) {
    Write-Host "❌ cloudflared n'est pas installé" -ForegroundColor Red
    Write-Host "   Installez-le avec: winget install --id Cloudflare.cloudflared" -ForegroundColor Yellow
    exit 1
}

# Démarrer cloudflared tunnel en arrière-plan et capturer l'URL
Write-Host "⏳ Démarrage du tunnel (cela peut prendre quelques secondes)..." -ForegroundColor Yellow

# Créer un script temporaire pour capturer l'URL
$tempScript = @"
Start-Process -FilePath "cloudflared" -ArgumentList "tunnel", "--url", "http://localhost:11434" -NoNewWindow -RedirectStandardOutput "cloudflared_output.txt" -RedirectStandardError "cloudflared_error.txt"
Start-Sleep -Seconds 10
"@

$tempScriptPath = "$env:TEMP\start_cloudflared.ps1"
$tempScript | Out-File -FilePath $tempScriptPath -Encoding UTF8

# Lancer cloudflared dans une nouvelle fenêtre
Start-Process powershell -ArgumentList "-NoExit", "-File", $tempScriptPath

Write-Host "⏳ Attente de la génération de l'URL du tunnel..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Essayer de trouver l'URL dans les logs
$outputFile = "cloudflared_output.txt"
$errorFile = "cloudflared_error.txt"

$tunnelUrl = $null

# Chercher l'URL dans les fichiers de sortie
if (Test-Path $outputFile) {
    $content = Get-Content $outputFile -ErrorAction SilentlyContinue
    $urlLine = $content | Select-String -Pattern "https://.*\.trycloudflare\.com" | Select-Object -First 1
    if ($urlLine) {
        $tunnelUrl = ($urlLine -split " " | Where-Object { $_ -match "https://.*\.trycloudflare\.com" }) | Select-Object -First 1
    }
}

if (Test-Path $errorFile) {
    $errorContent = Get-Content $errorFile -ErrorAction SilentlyContinue
    $urlLine = $errorContent | Select-String -Pattern "https://.*\.trycloudflare\.com" | Select-Object -First 1
    if ($urlLine -and -not $tunnelUrl) {
        $tunnelUrl = ($urlLine -split " " | Where-Object { $_ -match "https://.*\.trycloudflare\.com" }) | Select-Object -First 1
    }
}

# Si on n'a pas trouvé l'URL, essayer une autre méthode
if (-not $tunnelUrl) {
    Write-Host ""
    Write-Host "⚠️ Impossible de capturer automatiquement l'URL du tunnel" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 Veuillez:" -ForegroundColor Cyan
    Write-Host "   1. Regarder la fenêtre cloudflared qui s'est ouverte" -ForegroundColor White
    Write-Host "   2. Copier l'URL qui ressemble à: https://xxx.trycloudflare.com" -ForegroundColor White
    Write-Host "   3. Entrer cette URL ci-dessous" -ForegroundColor White
    Write-Host ""
    $tunnelUrl = Read-Host "URL du tunnel Cloudflare"
}

if (-not $tunnelUrl -or -not ($tunnelUrl -match "https://.*\.trycloudflare\.com")) {
    Write-Host "❌ URL invalide ou non fournie" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Tunnel Cloudflare actif !" -ForegroundColor Green
Write-Host "   URL: $tunnelUrl" -ForegroundColor White
Write-Host ""

# Obtenir le token JWT
$token = $env:RAILWAY_TOKEN

if (-not $token) {
    Write-Host "⚠️ Token JWT non trouvé dans la variable d'environnement RAILWAY_TOKEN" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 Pour obtenir un token:" -ForegroundColor Cyan
    Write-Host "   1. Connectez-vous à l'app mobile" -ForegroundColor White
    Write-Host "   2. Récupérez le token depuis les logs" -ForegroundColor White
    Write-Host "   3. Définissez: `$env:RAILWAY_TOKEN = 'votre_token'" -ForegroundColor White
    Write-Host ""
    $token = Read-Host "OU entrez votre token JWT maintenant"
    
    if (-not $token) {
        Write-Host "❌ Token requis pour continuer" -ForegroundColor Red
        exit 1
    }
}

# Enregistrer l'URL du tunnel dans Railway
Write-Host ""
Write-Host "💾 Enregistrement de l'URL du tunnel dans Railway..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

try {
    $encodedUrl = [System.Web.HttpUtility]::UrlEncode($tunnelUrl)
    $response = Invoke-RestMethod -Uri "$RailwayUrl/api/system-config/ollama/base-url?value=$encodedUrl" -Method Put -Headers $headers -ErrorAction Stop
    
    Write-Host ""
    Write-Host "✅ URL du tunnel enregistrée avec succès dans Railway !" -ForegroundColor Green
    Write-Host "   URL: $tunnelUrl" -ForegroundColor White
    Write-Host "   Railway utilisera cette URL pour appeler Ollama" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "⚠️ IMPORTANT: Gardez la fenêtre cloudflared ouverte !" -ForegroundColor Yellow
    Write-Host "   Le tunnel doit rester actif pour que Railway puisse appeler Ollama" -ForegroundColor Yellow
} catch {
    Write-Host ""
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
Write-Host ""
Write-Host "📋 Résumé:" -ForegroundColor Cyan
Write-Host "   - Tunnel Cloudflare: $tunnelUrl" -ForegroundColor White
Write-Host "   - URL enregistrée dans Railway" -ForegroundColor White
Write-Host "   - Railway peut maintenant appeler Ollama via le tunnel" -ForegroundColor White
Write-Host ""
