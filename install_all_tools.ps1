# Script PowerShell pour vérifier et installer les outils nécessaires - Hunger-Talk
# Exécuter en tant qu'administrateur pour certains outils

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation des outils - Hunger-Talk" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Fonction pour vérifier si une commande existe
function Test-Command {
    param($command)
    $null = Get-Command $command -ErrorAction SilentlyContinue
    return $?
}

# Fonction pour afficher le statut
function Show-Status {
    param($tool, $installed)
    if ($installed) {
        Write-Host "[OK] $tool est installe" -ForegroundColor Green
    } else {
        Write-Host "[X] $tool n'est PAS installe" -ForegroundColor Red
    }
}

Write-Host "Verification des outils installes..." -ForegroundColor Yellow
Write-Host ""

# 1. Vérifier Python
$pythonInstalled = Test-Command "python"
Show-Status "Python" $pythonInstalled
if ($pythonInstalled) {
    $pythonVersion = python --version 2>&1
    Write-Host "   Version: $pythonVersion" -ForegroundColor Gray
}

# 2. Vérifier pip
$pipInstalled = Test-Command "pip"
Show-Status "pip" $pipInstalled

# 3. Vérifier Flutter
$flutterInstalled = Test-Command "flutter"
Show-Status "Flutter" $flutterInstalled
if ($flutterInstalled) {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "   Version: $flutterVersion" -ForegroundColor Gray
}

# 4. Vérifier PostgreSQL
$psqlInstalled = Test-Command "psql"
Show-Status "PostgreSQL" $psqlInstalled
if ($psqlInstalled) {
    $psqlVersion = psql --version 2>&1
    Write-Host "   Version: $psqlVersion" -ForegroundColor Gray
}

# 5. Vérifier Ollama
$ollamaInstalled = Test-Command "ollama"
Show-Status "Ollama" $ollamaInstalled
if ($ollamaInstalled) {
    $ollamaVersion = ollama --version 2>&1
    Write-Host "   Version: $ollamaVersion" -ForegroundColor Gray
    
    # Verifier si le modele LLaMA est installe
    Write-Host "   Verification du modele LLaMA 3.1..." -ForegroundColor Gray
    $models = ollama list 2>&1
    if ($models -match "llama3.1") {
        Write-Host "   [OK] Modele LLaMA 3.1:8b installe" -ForegroundColor Green
    } else {
        Write-Host "   [X] Modele LLaMA 3.1:8b non installe" -ForegroundColor Red
        Write-Host "   Telecharger avec: ollama pull llama3.1:8b" -ForegroundColor Yellow
    }
}

# 6. Vérifier Git
$gitInstalled = Test-Command "git"
Show-Status "Git" $gitInstalled
if ($gitInstalled) {
    $gitVersion = git --version 2>&1
    Write-Host "   Version: $gitVersion" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Résumé" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$tools = @(
    @{Name="Python"; Installed=$pythonInstalled; URL="https://www.python.org/downloads/"},
    @{Name="Flutter"; Installed=$flutterInstalled; URL="https://docs.flutter.dev/get-started/install/windows"},
    @{Name="PostgreSQL"; Installed=$psqlInstalled; URL="https://www.postgresql.org/download/windows/"},
    @{Name="Ollama"; Installed=$ollamaInstalled; URL="https://ollama.ai/download"},
    @{Name="Git"; Installed=$gitInstalled; URL="https://git-scm.com/download/win"}
)

$allInstalled = $true
foreach ($tool in $tools) {
    if (-not $tool.Installed) {
        $allInstalled = $false
        Write-Host "[X] $($tool.Name) - Telecharger: $($tool.URL)" -ForegroundColor Red
    }
}

if ($allInstalled) {
    Write-Host "[OK] Tous les outils sont installes!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Prochaines etapes:" -ForegroundColor Yellow
    Write-Host "1. Configurer PostgreSQL: Creer la base de donnees 'hungertalk_db'" -ForegroundColor White
    Write-Host "2. Telecharger le modele LLaMA (si pas fait): ollama pull llama3.1:8b" -ForegroundColor White
    Write-Host "3. Initialiser le backend: cd backend && .\init_setup.bat" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "Veuillez installer les outils manquants." -ForegroundColor Yellow
    Write-Host "Voir docs/INSTALLATION_TOOLS.md pour les instructions detaillees." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Appuyez sur une touche pour continuer..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

