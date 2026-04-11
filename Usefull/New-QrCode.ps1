param(
    [Parameter(Mandatory = $true)]
    [string]$Text,
    [int]$Size = 500
)

. ".\Setup.ps1"

$OutputPath = "$env:USERPROFILE\Downloads"

# Encodage du texte pour l'URL
$encodedText = [System.Uri]::EscapeDataString($Text)

# URL du service de génération de QR Code
$qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=${Size}x${Size}&data=$encodedText"

Write-Status Info "Génération du QR Code...`n"
Write-Host "Text : $Text" -ForegroundColor Cyan
Write-Host "Size : ${Size}x${Size}" -ForegroundColor Cyan
Write-Host "Exit file : $OutputPath`n" -ForegroundColor Cyan

# Téléchargement de l'image
try {
    Invoke-WebRequest -Uri $qrUrl -OutFile $OutputPath
    Write-Status Success "QR Code généré et enregistré dans '$OutputPath'`n"
}
catch {
    Write-Status Error "Network connection required`n"
}
