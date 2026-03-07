. $PSScriptRoot\Setup.ps1

Clear-Host
# Chemin du fichier contenant les emails

$filePath = "..\src\gmail\email.psm1"

# Vérifier si le fichier existe
if (-not (Test-Path $filePath)) {
    Write-Status ERROR "File not found: $filePath"
    return
}

# Lire les emails
$emails = Get-Content $filePath |
ForEach-Object { $_.Split("#")[0].Trim() } |
Where-Object { $_ -ne "" }


# Vérifier qu'il y a au moins un email
if ($emails.Count -eq 0) {
    Write-Status ERROR "The file is empty."
    return
}

# Ouvrir une page Gmail pour chaque email
foreach ($email in $emails) {

    # Nettoyage (au cas où il y a des espaces)
    $email = $email.Trim()

    if ($email -eq "") { continue }

    $url = "https://accounts.google.com/AccountChooser?Email=$email"

    Write-Host ""
    Write-Status INFO "Opening Gmail login for: $email"
    Write-Host ""
    Start-Process $url
}
Pause
Clear-Host
