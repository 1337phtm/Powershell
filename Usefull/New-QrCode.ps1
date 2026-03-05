param(
    [Parameter(Mandatory = $true)]
    [string]$Text,

    [string]$OutputPath = ".\QRCode.png",

    [int]$Size = 500
)

# Encodage du texte pour l'URL
$encodedText = [System.Uri]::EscapeDataString($Text)

# URL du service de génération de QR Code
$qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=${Size}x${Size}&data=$encodedText"

Write-Host "Génération du QR Code..."
Write-Host "Texte : $Text"
Write-Host "Taille : ${Size}x${Size}"
Write-Host "Fichier de sortie : $OutputPath"

# Téléchargement de l'image
Invoke-WebRequest -Uri $qrUrl -OutFile $OutputPath

Write-Host "✅ QR Code généré et enregistré dans '$OutputPath'"
