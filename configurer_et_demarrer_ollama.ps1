# Script complet pour configurer et demarrer Ollama avec acces reseau
# Arrete Ollama s'il est en cours, puis le redemarre avec la bonne configuration

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Configuration Ollama pour acces reseau" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Arreter Ollama s'il est en cours d'execution
Write-Host "Verification des processus Ollama..." -ForegroundColor Yellow
$ollamaProcesses = Get-Process -Name ollama -ErrorAction SilentlyContinue
if ($ollamaProcesses) {
    Write-Host "Ollama est en cours d'execution, arret..." -ForegroundColor Yellow
    Stop-Process -Name ollama -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    Write-Host "Ollama arrete" -ForegroundColor Green
} else {
    Write-Host "Aucun processus Ollama en cours" -ForegroundColor Green
}

Write-Host ""

# Recuperer l'IP locale
Write-Host "Recuperation de l'IP locale..." -ForegroundColor Yellow
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

if ($localIp) {
    Write-Host "IP locale: $localIp" -ForegroundColor Green
    Write-Host "URL Ollama: http://$localIp:11434" -ForegroundColor Cyan
} else {
    Write-Host "IP locale non detectee" -ForegroundColor Yellow
}

Write-Host ""

# Configurer et demarrer Ollama
Write-Host "Demarrage d'Ollama avec acces reseau..." -ForegroundColor Cyan
Write-Host "Configuration: OLLAMA_HOST=0.0.0.0:11434" -ForegroundColor Gray
Write-Host ""
Write-Host "Cette fenetre va rester ouverte pendant qu'Ollama tourne" -ForegroundColor Yellow
Write-Host "Pour arreter, fermez cette fenetre ou appuyez sur Ctrl+C" -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configurer la variable d'environnement et demarrer Ollama
$env:OLLAMA_HOST = "0.0.0.0:11434"

# Demarrer Ollama dans une nouvelle fenetre PowerShell pour que la variable d'environnement soit persistante
$scriptPath = $PSScriptRoot
$ollamaScript = @"
`$env:OLLAMA_HOST = "0.0.0.0:11434"
ollama serve
"@

$tempScript = Join-Path $env:TEMP "start_ollama_network.ps1"
$ollamaScript | Out-File -FilePath $tempScript -Encoding UTF8

Start-Process powershell -ArgumentList "-NoExit", "-File", "`"$tempScript`""

Write-Host "Ollama demarre dans une nouvelle fenetre" -ForegroundColor Green
Write-Host ""
Write-Host "Attente de 5 secondes pour verification..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Verifier que Ollama repond
Write-Host ""
Write-Host "Verification qu'Ollama repond..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 3 -ErrorAction Stop
    Write-Host "Ollama repond correctement sur localhost" -ForegroundColor Green
    
    if ($localIp) {
        try {
            $responseNetwork = Invoke-RestMethod -Uri "http://$localIp:11434/api/tags" -Method Get -TimeoutSec 3 -ErrorAction Stop
            Write-Host "Ollama est accessible depuis le reseau ($localIp)" -ForegroundColor Green
            Write-Host "Votre telephone peut maintenant se connecter a: http://$localIp:11434" -ForegroundColor Cyan
        } catch {
            Write-Host "Ollama repond sur localhost mais pas encore sur le reseau (peut prendre quelques secondes)" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "Ollama ne repond pas encore, attendez quelques secondes de plus" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuration terminee!" -ForegroundColor Green
Write-Host ""
if ($localIp) {
    Write-Host "Pour votre telephone:" -ForegroundColor Cyan
    Write-Host "URL Ollama: http://$localIp:11434" -ForegroundColor White
}
Write-Host ""
Write-Host "Le serveur IP Ollama peut maintenant etre demarre avec:" -ForegroundColor Cyan
Write-Host '.\demarrer_ollama_ip_server.ps1' -ForegroundColor White
Write-Host ""
