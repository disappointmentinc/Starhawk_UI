# NPM Quick Fix - PowerShell Script
# Run this from Windows to fix NPM on Starhawk server

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "NPM Configuration Fix - PowerShell" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$server = "145.223.73.242"
$user = "root"

Write-Host "Uploading fix script to Starhawk..." -ForegroundColor Yellow
scp fix_npm_config.sh ${user}@${server}:/tmp/fix_npm_config.sh

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to upload script. Make sure SSH is accessible." -ForegroundColor Red
    Write-Host ""
    Write-Host "Alternative: Copy fix_npm_config.sh to the server manually, then run:" -ForegroundColor Yellow
    Write-Host "  bash /tmp/fix_npm_config.sh" -ForegroundColor White
    exit 1
}

Write-Host "Making script executable..." -ForegroundColor Yellow
ssh ${user}@${server} "chmod +x /tmp/fix_npm_config.sh"

Write-Host "Running fix script..." -ForegroundColor Yellow
ssh ${user}@${server} "/tmp/fix_npm_config.sh"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Fix Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Test your services:" -ForegroundColor Cyan
Write-Host "  https://n8n.cyberspace.business" -ForegroundColor White
Write-Host "  https://grafana.cyberspace.business" -ForegroundColor White
Write-Host "  https://portainer.cyberspace.business" -ForegroundColor White
Write-Host "  https://proxmox.cyberspace.business" -ForegroundColor White
Write-Host ""
