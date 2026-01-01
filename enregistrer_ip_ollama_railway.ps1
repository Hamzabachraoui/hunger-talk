# Script pour enregistrer l'IP Ollama locale dans Railway
# Ce script recupere l'IP locale du PC et l'enregistre dans Railway via l'API

param(
    [string]$RailwayUrl = "https://hunger-talk-production.up.railway.app",
    [string]$Token = "",
    [string]$Email = "",
    [string]$Password = ""
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Enregistrement IP Ollama dans Railway" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Fonction pour recuperer l'IP locale
function Get-LocalIP {
    $ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
        $_.IPAddress -notlike "127.*" -and 
        $_.IPAddress -notlike "169.254.*"
    } | Select-Object -ExpandProperty IPAddress

    $localIp = $null
    foreach ($ip in $ipAddresses) {
        if ($ip -like "192.168.*") {
            $localIp = $ip
            break
        }
    }

    if (-not $localIp) {
        foreach ($ip in $ipAddresses) {
            if ($ip -like "10.*") {
                $localIp = $ip
                break
            }
        }
    }

    return $localIp
}

# Recuperer l'IP locale
Write-Host "Recuperation de l'IP locale..." -ForegroundColor Yellow
$localIp = Get-LocalIP

if (-not $localIp) {
    Write-Host "Erreur: Impossible de recuperer l'IP locale" -ForegroundColor Red
    exit 1
}

$ollamaUrl = "http://$localIp:11434"
Write-Host "IP locale detectee: $localIp" -ForegroundColor Green
Write-Host "URL Ollama: $ollamaUrl" -ForegroundColor Cyan
Write-Host ""

# Verifier qu'Ollama repond localement
Write-Host "Verification qu'Ollama repond localement..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 3 -ErrorAction Stop
    Write-Host "Ollama fonctionne localement" -ForegroundColor Green
} catch {
    Write-Host "Attention: Ollama ne repond pas sur localhost:11434" -ForegroundColor Yellow
    Write-Host "Assurez-vous qu'Ollama est demarre avec: .\configurer_et_demarrer_ollama.ps1" -ForegroundColor Yellow
}

Write-Host ""

# Obtenir le token si non fourni
if (-not $Token) {
    if (-not $Email -or -not $Password) {
        Write-Host "Token JWT requis pour l'authentification" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Options:" -ForegroundColor Cyan
        Write-Host "1. Passer le token directement:" -ForegroundColor White
        Write-Host '   .\enregistrer_ip_ollama_railway.ps1 -Token "votre_token_jwt"' -ForegroundColor Gray
        Write-Host ""
        Write-Host "2. Passer email et mot de passe:" -ForegroundColor White
        Write-Host '   .\enregistrer_ip_ollama_railway.ps1 -Email "votre@email.com" -Password "votre_mot_de_passe"' -ForegroundColor Gray
        Write-Host ""
        exit 1
    }

    Write-Host "Authentification avec email et mot de passe..." -ForegroundColor Yellow
    try {
        $loginBody = @{
            email = $Email
            password = $Password
        } | ConvertTo-Json

        $loginResponse = Invoke-RestMethod -Uri "$RailwayUrl/api/auth/login" -Method Post -Body $loginBody -ContentType "application/json" -ErrorAction Stop
        $Token = $loginResponse.access_token
        Write-Host "Authentification reussie" -ForegroundColor Green
    } catch {
        Write-Host "Erreur lors de l'authentification: $_" -ForegroundColor Red
        exit 1
    }
}

# Enregistrer l'IP dans Railway
Write-Host ""
Write-Host "Enregistrement de l'IP Ollama dans Railway..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type" = "application/json"
    }

    # L'endpoint FastAPI attend un paramètre query "value"
    $uri = "$RailwayUrl/api/system-config/ollama/base-url?value=$([uri]::EscapeDataString($ollamaUrl))"
    $response = Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -ErrorAction Stop
    
    Write-Host "IP Ollama enregistree avec succes dans Railway!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Configuration:" -ForegroundColor Cyan
    Write-Host "  URL Ollama: $ollamaUrl" -ForegroundColor White
    Write-Host "  Enregistree dans Railway" -ForegroundColor White
    Write-Host ""
    Write-Host "Votre application mobile pourra maintenant recuperer cette IP depuis Railway" -ForegroundColor Green
    Write-Host ""
    
} catch {
    Write-Host "Erreur lors de l'enregistrement: $_" -ForegroundColor Red
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "Token invalide ou expire. Reconnectez-vous." -ForegroundColor Yellow
    } elseif ($_.Exception.Response.StatusCode -eq 400) {
        Write-Host "URL invalide. Verifiez le format." -ForegroundColor Yellow
    }
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan

