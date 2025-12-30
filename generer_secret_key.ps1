# Script pour générer une SECRET_KEY pour Railway

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Génération SECRET_KEY pour Railway" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$secretKey = python -c "import secrets; print(secrets.token_urlsafe(32))"

Write-Host "Copie cette valeur dans Railway (variable SECRET_KEY):" -ForegroundColor Yellow
Write-Host ""
Write-Host $secretKey -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
