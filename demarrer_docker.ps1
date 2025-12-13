# Script pour démarrer Docker - Hunger-Talk
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Démarrage des conteneurs Docker" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier que docker-compose.yml existe
if (-not (Test-Path "docker-compose.yml")) {
    Write-Host "[ERREUR] docker-compose.yml non trouvé" -ForegroundColor Red
    exit 1
}

Write-Host "1. Arrêt des conteneurs existants (si présents)..." -ForegroundColor Yellow
docker-compose down 2>&1 | Out-Null

Write-Host ""
Write-Host "2. Démarrage de PostgreSQL..." -ForegroundColor Yellow
docker-compose up -d postgres

if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] PostgreSQL démarré" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "3. Attente que PostgreSQL soit prêt..." -ForegroundColor Yellow
    $timeout = 30
    $elapsed = 0
    $ready = $false
    
    while ($elapsed -lt $timeout) {
        $health = docker-compose exec -T postgres pg_isready -U postgres 2>&1
        if ($health -match "accepting connections") {
            Write-Host "   [OK] PostgreSQL prêt" -ForegroundColor Green
            $ready = $true
            break
        }
        Start-Sleep -Seconds 2
        $elapsed += 2
        Write-Host "   En attente... ($elapsed/$timeout secondes)" -ForegroundColor Gray
    }
    
    if (-not $ready) {
        Write-Host "   [ATTENTION] Timeout, mais on continue..." -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "4. Démarrage du backend..." -ForegroundColor Yellow
    docker-compose up -d backend
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] Backend démarré" -ForegroundColor Green
    } else {
        Write-Host "   [ERREUR] Impossible de démarrer le backend" -ForegroundColor Red
        docker-compose logs backend
        exit 1
    }
    
} else {
    Write-Host "   [ERREUR] Impossible de démarrer PostgreSQL" -ForegroundColor Red
    docker-compose logs postgres
    exit 1
}

Write-Host ""
Write-Host "5. Vérification des conteneurs..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

$containers = docker ps --filter "name=hungertalk" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host $containers

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "[OK] Conteneurs démarrés!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Services disponibles:" -ForegroundColor Yellow
Write-Host "  - API Backend: http://localhost:8000" -ForegroundColor White
Write-Host "  - Documentation: http://localhost:8000/docs" -ForegroundColor White
Write-Host "  - PostgreSQL: localhost:5433 (5432 dans le conteneur)" -ForegroundColor White
Write-Host ""
Write-Host "Commandes utiles:" -ForegroundColor Yellow
Write-Host "  - Voir les logs: docker-compose logs -f" -ForegroundColor White
Write-Host "  - Arrêter: docker-compose down" -ForegroundColor White
Write-Host "  - Redémarrer: docker-compose restart" -ForegroundColor White
Write-Host ""

