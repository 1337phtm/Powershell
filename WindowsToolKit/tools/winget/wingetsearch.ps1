#si name au lieu de ID

Clear-Host
$filePath = "..\src\install\apps.json"

# Vérifier si le fichier existe
if (-not (Test-Path $filePath)) {
    Write-Host "❌ File not found: $filePath" -ForegroundColor Red
    return
}

# Récupère le contenu
$apps = Get-Content $filePath -Raw | ConvertFrom-Json


# Vérifier qu'il y a au moins une ligne écrite
if ($apps.Count -eq 0) {
    Write-Host "❌ The file is empty." -ForegroundColor Red
    return
}

foreach ($app in $apps) {
    Write-Host "Recherche de $($app.name) :" -ForegroundColor Yellow
    Write-Host ""
    winget search "$($app.name)"
    Write-Host ""

}
