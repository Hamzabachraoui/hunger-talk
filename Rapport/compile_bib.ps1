# Script PowerShell pour compiler la bibliographie LaTeX
# Usage: .\compile_bib.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Compilation de la bibliographie LaTeX" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "[1/4] Nettoyage des fichiers auxiliaires..." -ForegroundColor Yellow
Remove-Item -Path "main.aux","main.bbl","main.blg" -ErrorAction SilentlyContinue
Write-Host "Fichiers supprimes." -ForegroundColor Green
Write-Host ""

Write-Host "[2/4] Premiere compilation LaTeX (generation du .aux)..." -ForegroundColor Yellow
& pdflatex -interaction=nonstopmode -halt-on-error main.tex
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR lors de la premiere compilation!" -ForegroundColor Red
    Read-Host "Appuyez sur Entree pour quitter"
    exit 1
}

Write-Host ""
Write-Host "[3/4] Compilation BibTeX (generation du .bbl)..." -ForegroundColor Yellow
& bibtex main
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR lors de la compilation BibTeX!" -ForegroundColor Red
    Read-Host "Appuyez sur Entree pour quitter"
    exit 1
}

Write-Host ""
Write-Host "[4/4] Compilations finales LaTeX (resolution des references)..." -ForegroundColor Yellow
& pdflatex -interaction=nonstopmode -halt-on-error main.tex
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR lors de la deuxieme compilation!" -ForegroundColor Red
    Read-Host "Appuyez sur Entree pour quitter"
    exit 1
}

& pdflatex -interaction=nonstopmode -halt-on-error main.tex
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR lors de la troisieme compilation!" -ForegroundColor Red
    Read-Host "Appuyez sur Entree pour quitter"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Compilation terminee avec succes!" -ForegroundColor Green
Write-Host "Les citations devraient maintenant etre numerotees [1], [2], etc." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Read-Host "Appuyez sur Entree pour quitter"

