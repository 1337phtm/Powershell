<#
.SYNOPSIS
    Organise automatiquement les scripts PowerShell dans une arborescence propre.

.DESCRIPTION
    Crée les dossiers :
    - Modules/System
    - Modules/Network
    - Modules/Files
    - Modules/QR
    - Modules/GUI
    - Scripts
    - Data

    Puis déplace chaque fichier dans la bonne catégorie.
#>

Write-Host "`n=== Organisation des scripts PowerShell ===`n" -ForegroundColor Cyan

# --- 1. Définition des dossiers ---
$folders = @(
    "Modules/System",
    "Modules/Network",
    "Modules/Files",
    "Modules/QR",
    "Modules/GUI",
    "Scripts",
    "Data"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
        Write-Host "[+] Création du dossier : $folder" -ForegroundColor Green
    }
}

# --- 2. Table de routage des fichiers ---
$mapping = @{
    # System
    "batteryreport.ps1"        = "Modules/System"
    "Show-BsodBestView.ps1"    = "Modules/System"
    "Show-FakeBsod.ps1"        = "Modules/System"
    "recupWindowsKey.ps1"      = "Modules/System"
    "Show-Licence.ps1"         = "Modules/System"
    "repair.ps1"               = "Modules/System"
    "hide.ps1"                 = "Modules/System"
    "showlect.ps1"             = "Modules/System"

    # Network
    "Network-Scanner.ps1"      = "Modules/Network"
    "Install-ssh.ps1"          = "Modules/Network"
    "Open-Gmail.ps1"           = "Modules/Network"
    "Open-GmailFile.ps1"       = "Modules/Network"

    # Files
    "Organize-Folder.ps1"      = "Modules/Files"
    "Organize-Project.ps1"     = "Modules/Files"
    "Search file.ps1"          = "Modules/Files"
    "Search file with ext.ps1" = "Modules/Files"
    "Convert-ImageFormat.ps1"  = "Modules/Files"
    "Make-Arbo.ps1"            = "Modules/Files"
    "Make-arbo-USEFULL.ps1"    = "Modules/Files"

    # QR
    "New-QrCode.ps1"           = "Modules/QR"
    "New-WifiQrCode.ps1"       = "Modules/QR"

    # GUI
    "gui.ps1"                  = "Modules/GUI"
    "guiusb.ps1"               = "Modules/GUI"
    "noguidtclub.ps1"          = "Modules/GUI"

    # Scripts généraux
    "Setup.ps1"                = "Scripts"
    "Post-Install.ps1"         = "Scripts"
    "usefull1.ps1"             = "Scripts"
    "usefull2.ps1"             = "Scripts"
    "test.ps1"                 = "Scripts"

    # Data
    "scripts_status.json"      = "Data"
    "Post-Install.txt"         = "Data"

    # Racine
    "README.md"                = "."
    "Main.ps1"                 = "."
}

# --- 3. Déplacement des fichiers ---
foreach ($file in $mapping.Keys) {
    if (Test-Path $file) {
        $dest = $mapping[$file]
        Move-Item -Path $file -Destination $dest -Force
        Write-Host "[OK] $file → $dest" -ForegroundColor Yellow
    }
    else {
        Write-Host "[!] Fichier introuvable : $file" -ForegroundColor DarkGray
    }
}

Write-Host "`n=== Organisation terminée ===`n" -ForegroundColor Cyan
