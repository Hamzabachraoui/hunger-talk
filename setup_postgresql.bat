@echo off
REM Script d'aide pour installer et configurer PostgreSQL - Hunger-Talk
echo ========================================
echo Configuration PostgreSQL - Hunger-Talk
echo ========================================
echo.

echo [INFO] Ce script vous guide dans l'installation de PostgreSQL
echo.
echo ETAPE 1: Installation de PostgreSQL
echo -----------------------------------
echo 1. Téléchargez PostgreSQL depuis: https://www.postgresql.org/download/windows/
echo 2. Exécutez l'installateur
echo 3. IMPORTANT: Notez le mot de passe du superutilisateur (postgres)
echo 4. Port par défaut: 5432 (gardez-le)
echo 5. Installez pgAdmin 4 (recommandé)
echo.
pause

echo.
echo ETAPE 2: Vérification de l'installation
echo ---------------------------------------
psql --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] PostgreSQL n'est pas dans le PATH
    echo Veuillez redémarrer votre terminal après l'installation
    echo Ou ajouter manuellement PostgreSQL au PATH
    pause
    exit /b 1
) else (
    echo [OK] PostgreSQL detecte
    psql --version
)

echo.
echo ETAPE 3: Création de la base de données
echo ---------------------------------------
echo Vous devez maintenant créer la base de données 'hungertalk_db'
echo.
echo Option 1: Via pgAdmin 4
echo  1. Ouvrez pgAdmin 4
echo  2. Connectez-vous avec le mot de passe que vous avez choisi
echo  3. Clic droit sur "Databases" ^> Create ^> Database
echo  4. Nom: hungertalk_db
echo  5. Owner: postgres
echo  6. Cliquez sur Save
echo.
echo Option 2: Via SQL Shell (psql)
echo  1. Ouvrez "SQL Shell (psql)" depuis le menu Démarrer
echo  2. Appuyez sur Entrée pour chaque question (localhost, postgres, 5432, postgres)
echo  3. Entrez votre mot de passe
echo  4. Exécutez: CREATE DATABASE hungertalk_db;
echo  5. Puis: \q
echo.
echo Option 3: Via ligne de commande (si psql est dans le PATH)
echo  psql -U postgres -c "CREATE DATABASE hungertalk_db;"
echo.
pause

echo.
echo ETAPE 4: Test de connexion
echo ---------------------------
echo Testez la connexion avec:
echo   psql -U postgres -d hungertalk_db
echo.
echo Si la connexion fonctionne, PostgreSQL est correctement configure!
echo.
pause

echo.
echo ========================================
echo Configuration PostgreSQL terminee!
echo ========================================
echo.
echo N'oubliez pas de mettre a jour le fichier backend/.env avec:
echo   DATABASE_URL=postgresql://postgres:VOTRE_MOT_DE_PASSE@localhost:5432/hungertalk_db
echo.

