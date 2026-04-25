Clear-Host
# Récupère tous les lecteurs fichiers (C:, D:, E:, etc.)
$drives = Get-PSDrive -PSProvider FileSystem

Write-Host ""
Write-Host "Liste des lecteurs :" -ForegroundColor Cyan
Write-Host ""

Write-Host "Détails :" -ForegroundColor Cyan
Write-Host ""
foreach ($drive in $drives) {

    $isNetwork = if ($drive.DisplayRoot) { "Yes" } else { "No" }
    $usedGB = [math]::Round($drive.Used / 1GB, 2)
    $freeGB = [math]::Round($drive.Free / 1GB, 2)

    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║ Drive   : $($drive.Name)" -ForegroundColor Cyan
    Write-Host "║ Path    : $($drive.Root)" -ForegroundColor Cyan
    Write-Host "║ Network : $isNetwork" -ForegroundColor Cyan
    Write-Host "║ Used    : $usedGB GB" -ForegroundColor Cyan
    Write-Host "║ Free    : $freeGB GB" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}
