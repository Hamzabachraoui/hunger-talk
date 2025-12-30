@echo off
chcp 65001 >nul
echo ========================================
echo Compilation de la bibliographie LaTeX
echo ========================================
echo.

cd /d "%~dp0"

echo [1/4] Nettoyage des fichiers auxiliaires...
del /Q main.aux main.bbl main.blg 2>nul
echo Fichiers supprimes.

echo.
echo [2/4] Premiere compilation LaTeX (generation du .aux)...
pdflatex -interaction=nonstopmode -halt-on-error main.tex
if %errorlevel% neq 0 (
    echo ERREUR lors de la premiere compilation!
    pause
    exit /b 1
)

echo.
echo [3/4] Compilation BibTeX (generation du .bbl)...
bibtex main
if %errorlevel% neq 0 (
    echo ERREUR lors de la compilation BibTeX!
    pause
    exit /b 1
)

echo.
echo [4/4] Compilations finales LaTeX (resolution des references)...
pdflatex -interaction=nonstopmode -halt-on-error main.tex
if %errorlevel% neq 0 (
    echo ERREUR lors de la deuxieme compilation!
    pause
    exit /b 1
)

pdflatex -interaction=nonstopmode -halt-on-error main.tex
if %errorlevel% neq 0 (
    echo ERREUR lors de la troisieme compilation!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Compilation terminee avec succes!
echo Les citations devraient maintenant etre numerotees [1], [2], etc.
echo ========================================
pause
