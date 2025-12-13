# Script pour créer la base de données hungertalk_db
Write-Host "Creation de la base de donnees hungertalk_db" -ForegroundColor Cyan
Write-Host ""

# Chemin vers psql
$psql18 = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$psql17 = "C:\Program Files\PostgreSQL\17\bin\psql.exe"

$psqlPath = $null
if (Test-Path $psql18) {
    $psqlPath = $psql18
    $pgVersion = "18"
} elseif (Test-Path $psql17) {
    $psqlPath = $psql17
    $pgVersion = "17"
} else {
    Write-Host "[ERREUR] PostgreSQL non trouve" -ForegroundColor Red
    exit 1
}

Write-Host "PostgreSQL $pgVersion detecte" -ForegroundColor Green
Write-Host ""

# Demander le mot de passe
$password = Read-Host "Entrez le mot de passe PostgreSQL pour l'utilisateur 'postgres'"

# Essayer avec PGPASSWORD
$env:PGPASSWORD = $password

Write-Host ""
Write-Host "Tentative de connexion..." -ForegroundColor Yellow

# Essayer de créer la base de données
$result = & $psqlPath -h 127.0.0.1 -U postgres -d postgres -c "SELECT 1;" 2>&1

if ($LASTEXITCODE -eq 0 -or $result -match "SELECT 1") {
    Write-Host "[OK] Connexion reussie!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Creation de la base de donnees hungertalk_db..." -ForegroundColor Yellow
    
    # Vérifier si la base existe déjà
    $checkDB = & $psqlPath -h 127.0.0.1 -U postgres -d postgres -t -c "SELECT 1 FROM pg_database WHERE datname='hungertalk_db';" 2>&1
    
    if ($checkDB -match "1") {
        Write-Host "[INFO] La base de donnees hungertalk_db existe deja" -ForegroundColor Yellow
        Write-Host "Voulez-vous la supprimer et la recreer? (O/N)"
        $recreate = Read-Host
        if ($recreate -eq "O" -or $recreate -eq "o") {
            Write-Host "Suppression de l'ancienne base..." -ForegroundColor Yellow
            & $psqlPath -h 127.0.0.1 -U postgres -d postgres -c "DROP DATABASE hungertalk_db;" 2>&1 | Out-Null
            Write-Host "Creation de la nouvelle base..." -ForegroundColor Yellow
        } else {
            Write-Host "[OK] Base de donnees conservee" -ForegroundColor Green
            Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
            exit 0
        }
    }
    
    # Créer la base de données
    $createResult = & $psqlPath -h 127.0.0.1 -U postgres -d postgres -c "CREATE DATABASE hungertalk_db;" 2>&1
    
    if ($LASTEXITCODE -eq 0 -or $createResult -match "CREATE DATABASE" -or $createResult -match "already exists") {
        Write-Host "[OK] Base de donnees hungertalk_db creee avec succes!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Verification..." -ForegroundColor Yellow
        & $psqlPath -h 127.0.0.1 -U postgres -d hungertalk_db -c "\conninfo" 2>&1 | Out-Null
        Write-Host "[OK] Connexion a hungertalk_db fonctionne!" -ForegroundColor Green
    } else {
        Write-Host "[ERREUR] Impossible de creer la base de donnees" -ForegroundColor Red
        Write-Host $createResult
    }
} else {
    Write-Host "[ERREUR] Impossible de se connecter a PostgreSQL" -ForegroundColor Red
    Write-Host ""
    Write-Host "Le mot de passe semble incorrect ou PostgreSQL n'est pas correctement configure." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Solutions alternatives:" -ForegroundColor Cyan
    Write-Host "1. Utiliser pgAdmin 4:" -ForegroundColor White
    Write-Host "   - Ouvrez pgAdmin 4"
    Write-Host "   - Connectez-vous avec votre mot de passe"
    Write-Host "   - Clic droit sur Databases > Create > Database"
    Write-Host "   - Nom: hungertalk_db"
    Write-Host ""
    Write-Host "2. Verifier le mot de passe:" -ForegroundColor White
    Write-Host "   - Le mot de passe peut contenir des majuscules ou caracteres speciaux"
    Write-Host "   - Essayez de vous connecter via pgAdmin pour confirmer"
    Write-Host ""
    Write-Host "3. Reinitialiser le mot de passe:" -ForegroundColor White
    Write-Host "   - Modifiez le fichier pg_hba.conf dans PostgreSQL"
    Write-Host "   - Changez 'md5' en 'trust' temporairement"
    Write-Host "   - Redemarrez le service PostgreSQL"
}

# Nettoyer
Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Appuyez sur une touche pour continuer..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

