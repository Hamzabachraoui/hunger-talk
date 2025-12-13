# Script pour afficher l'adresse IP actuelle
# Utile pour savoir quelle adresse utiliser sur le telephone

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Adresses IP pour acces mobile" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.IPAddress -notlike "127.*" -and 
    $_.IPAddress -notlike "169.254.*"
} | Select-Object -ExpandProperty IPAddress

if ($ipAddresses.Count -eq 0) {
    Write-Host "Aucune adresse IP trouvee" -ForegroundColor Red
} else {
    Write-Host "Adresses IP disponibles:" -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($ip in $ipAddresses) {
        if ($ip -like "192.168.*") {
            Write-Host "   http://$ip:8000" -ForegroundColor Green
        } else {
            Write-Host "   http://$ip:8000" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Write-Host "Utilisez l'adresse qui commence par 192.168.* sur votre telephone" -ForegroundColor Cyan
    Write-Host "Assurez-vous que votre telephone est sur le meme reseau Wi-Fi" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Verification du serveur..." -ForegroundColor Yellow
$portInUse = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "Le serveur est en cours d'execution sur le port 8000" -ForegroundColor Green
} else {
    Write-Host "Le serveur n'est pas en cours d'execution" -ForegroundColor Red
    Write-Host "Executez demarrer_serveur.bat pour demarrer le serveur" -ForegroundColor Yellow
}

Write-Host ""
