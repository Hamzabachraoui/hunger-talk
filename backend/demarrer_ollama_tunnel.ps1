# Script PowerShell pour démarrer Ollama et créer un tunnel ngrok
# Usage: .\demarrer_ollama_tunnel.ps1
# Ce script fait TOUT automatiquement !

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🚀 SETUP AUTOMATIQUE OLLAMA + TUNNEL" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Vérifier si Ollama est installé
Write-Host "🔍 Vérification d'Ollama..." -ForegroundColor Cyan
$ollamaInstalled = Get-Command ollama -ErrorAction SilentlyContinue
if (-not $ollamaInstalled) {
    Write-Host "❌ Ollama n'est pas installé" -ForegroundColor Red
    Write-Host "📥 Installation automatique d'Ollama..." -ForegroundColor Yellow
    
    # Essayer d'installer Ollama automatiquement
    try {
        $ollamaInstaller = "$env:TEMP\ollama-setup.exe"
        Write-Host "   Téléchargement d'Ollama..." -ForegroundColor Gray
        Invoke-WebRequest -Uri "https://ollama.com/download/windows" -OutFile $ollamaInstaller -UseBasicParsing
        Write-Host "   Installation en cours..." -ForegroundColor Gray
        Start-Process -FilePath $ollamaInstaller -ArgumentList "/S" -Wait
        Start-Sleep -Seconds 3
        
        # Vérifier à nouveau
        $ollamaInstalled = Get-Command ollama -ErrorAction SilentlyContinue
        if (-not $ollamaInstalled) {
            Write-Host "❌ Installation échouée. Installez manuellement depuis: https://ollama.com/download" -ForegroundColor Red
            exit 1
        }
        Write-Host "✅ Ollama installé avec succès!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Impossible d'installer automatiquement. Installez depuis: https://ollama.com/download" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Ollama est installé" -ForegroundColor Green
}

# Vérifier si ngrok est installé
Write-Host "🔍 Vérification de ngrok..." -ForegroundColor Cyan
$ngrokInstalled = Get-Command ngrok -ErrorAction SilentlyContinue
if (-not $ngrokInstalled) {
    Write-Host "❌ ngrok n'est pas installé" -ForegroundColor Red
    Write-Host "📥 Installation automatique de ngrok..." -ForegroundColor Yellow
    
    try {
        $ngrokPath = "$env:USERPROFILE\ngrok"
        New-Item -ItemType Directory -Force -Path $ngrokPath | Out-Null
        
        Write-Host "   Téléchargement de ngrok..." -ForegroundColor Gray
        $ngrokZip = "$ngrokPath\ngrok.zip"
        Invoke-WebRequest -Uri "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip" -OutFile $ngrokZip -UseBasicParsing
        
        Write-Host "   Extraction..." -ForegroundColor Gray
        Expand-Archive -Path $ngrokZip -DestinationPath $ngrokPath -Force
        Remove-Item $ngrokZip
        
        # Ajouter au PATH pour cette session
        $env:Path += ";$ngrokPath"
        
        # Vérifier
        $ngrokInstalled = Get-Command "$ngrokPath\ngrok.exe" -ErrorAction SilentlyContinue
        if ($ngrokInstalled) {
            Write-Host "✅ ngrok installé dans: $ngrokPath" -ForegroundColor Green
            Write-Host "⚠️ IMPORTANT: Configurez votre token ngrok:" -ForegroundColor Yellow
            Write-Host "   1. Créez un compte gratuit: https://ngrok.com" -ForegroundColor Cyan
            Write-Host "   2. Récupérez votre token" -ForegroundColor Cyan
            Write-Host "   3. Exécutez: ngrok config add-authtoken VOTRE_TOKEN" -ForegroundColor Cyan
            Write-Host ""
            $continue = Read-Host "Appuyez sur Entrée après avoir configuré votre token"
        } else {
            Write-Host "❌ Installation échouée. Installez manuellement depuis: https://ngrok.com/download" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "❌ Impossible d'installer automatiquement. Installez depuis: https://ngrok.com/download" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ ngrok est installé" -ForegroundColor Green
}

# Vérifier si Ollama est déjà en cours d'exécution
Write-Host ""
Write-Host "🔄 Démarrage d'Ollama..." -ForegroundColor Cyan
$ollamaRunning = Get-Process -Name ollama -ErrorAction SilentlyContinue
if ($ollamaRunning) {
    Write-Host "✅ Ollama est déjà en cours d'exécution" -ForegroundColor Green
} else {
    Write-Host "   Démarrage du serveur Ollama..." -ForegroundColor Gray
    Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Minimized
    Start-Sleep -Seconds 5
    Write-Host "✅ Ollama démarré" -ForegroundColor Green
}

# Vérifier que le modèle est installé
Write-Host ""
Write-Host "🔍 Vérification du modèle llama3.1:8b..." -ForegroundColor Cyan
$maxRetries = 5
$retryCount = 0
$connected = $false

while (-not $connected -and $retryCount -lt $maxRetries) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -TimeoutSec 5 -ErrorAction Stop
        $models = ($response.Content | ConvertFrom-Json).models
        $modelExists = $models | Where-Object { $_.name -like "*llama3.1:8b*" }
        $connected = $true
        
        if (-not $modelExists) {
            Write-Host "⚠️ Le modèle llama3.1:8b n'est pas installé" -ForegroundColor Yellow
            Write-Host "📥 Téléchargement du modèle (cela peut prendre 5-10 minutes)..." -ForegroundColor Yellow
            Write-Host "   ⏳ Veuillez patienter..." -ForegroundColor Gray
            ollama pull llama3.1:8b
            Write-Host "✅ Modèle installé avec succès!" -ForegroundColor Green
        } else {
            Write-Host "✅ Modèle déjà installé" -ForegroundColor Green
        }
    } catch {
        $retryCount++
        if ($retryCount -lt $maxRetries) {
            Write-Host "   ⏳ Attente qu'Ollama soit prêt... ($retryCount/$maxRetries)" -ForegroundColor Gray
            Start-Sleep -Seconds 2
        } else {
            Write-Host "❌ Impossible de se connecter à Ollama après $maxRetries tentatives" -ForegroundColor Red
            Write-Host "💡 Vérifiez qu'Ollama est bien démarré" -ForegroundColor Yellow
            exit 1
        }
    }
}

# Démarrer ngrok
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "🌐 DÉMARRAGE DU TUNNEL NGROK" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️ IMPORTANT: Notez l'URL 'Forwarding' qui apparaîtra ci-dessous" -ForegroundColor Yellow
Write-Host "⚠️ Vous devrez l'ajouter dans Railway comme variable OLLAMA_BASE_URL" -ForegroundColor Yellow
Write-Host ""
Write-Host "📋 PROCHAINES ÉTAPES:" -ForegroundColor Cyan
Write-Host "1. Notez l'URL 'Forwarding' dans la fenêtre ngrok (ex: https://abc123.ngrok-free.app)" -ForegroundColor White
Write-Host "2. Allez sur Railway Dashboard → Votre Service → Variables" -ForegroundColor White
Write-Host "3. Ajoutez/modifiez: OLLAMA_BASE_URL = votre_url_ngrok" -ForegroundColor White
Write-Host "4. Attendez le redéploiement (2-3 minutes)" -ForegroundColor White
Write-Host ""
Write-Host "Appuyez sur Ctrl+C pour arrêter le tunnel" -ForegroundColor Gray
Write-Host ""

# Démarrer ngrok dans une nouvelle fenêtre pour voir l'URL
Start-Process -FilePath "ngrok" -ArgumentList "http", "11434"

Write-Host ""
Write-Host "✅ Tunnel démarré dans une nouvelle fenêtre !" -ForegroundColor Green
Write-Host "👀 Regardez la fenêtre ngrok pour voir l'URL" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Pour arrêter: Fermez cette fenêtre et la fenêtre ngrok" -ForegroundColor Gray
Write-Host ""

