@echo off
echo ========================================
echo   Creation de la base de donnees
echo   Hunger-Talk
echo ========================================
echo.

cd /d "%~dp0"

echo [1/3] Activation de l'environnement virtuel...
call venv\Scripts\activate.bat

echo.
echo [2/3] Creation des tables...
python scripts\create_database.py
if errorlevel 1 (
    echo.
    echo ERREUR lors de la creation des tables
    pause
    exit /b 1
)

echo.
echo [3/3] Initialisation des categories...
python scripts\init_categories.py
if errorlevel 1 (
    echo.
    echo ERREUR lors de l'initialisation des categories
    pause
    exit /b 1
)

echo.
echo ========================================
echo   Base de donnees creee avec succes !
echo ========================================
echo.
pause

