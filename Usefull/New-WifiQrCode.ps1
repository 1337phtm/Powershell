. $PSScriptRoot\Setup.ps1

Show-SectionHeader "Générateur de QR Code Wi-Fi"

# Récupération des profils Wi-Fi enregistrés
$profilesRaw = netsh wlan show profiles

# Extraction des noms de profils
$profiles = ($profilesRaw | Select-String "Profil Tous les utilisateurs").ForEach({
        $_.ToString().Split(":")[1].Trim()
    })

if (-not $profiles) {
    Write-Status ERROR "Aucun profil Wi-Fi trouvé."
    exit
}

Write-Host "Profils Wi-Fi détectés :`n"
$index = 1
foreach ($p in $profiles) {
    Write-Status SKIP "[$index] $p"
    $index++
}

# Choix utilisateur
Write-Host ""
$choice = Read-Host "Entrez le numéro du profil à utiliser "
$selectedProfile = $profiles[$choice - 1]

Write-Host ""
Write-Status INFO "Vous avez choisi : $selectedProfile"

# Récupération des détails du profil
$profileDetails = netsh wlan show profile name="$selectedProfile" key=clear

# Extraction du SSID réel
$ssidLine = $profileDetails | Select-String "SSID name|Nom du SSID"
$ssid = $ssidLine.ToString().Split(":")[1].Trim().Trim('"')

# Extraction du mot de passe (clé)
$passwordLine = $profileDetails | Select-String "Key Content|Contenu de la clé|Contenu de la cl├®"
$password = $passwordLine.ToString().Split(":")[1].Trim()

# Extraction du type de sécurité
$security = $profileDetails | Select-String "Authentication|Authentification"

# Normalisation du type pour QR Code
switch -Regex ($security) {
    "WPA2┬á-┬áPersonnel" { $securityType = "WPA" }
    "WEP" { $securityType = "WEP" }
    default { $securityType = "nopass" }
}

# Construction du texte Wi-Fi
$wifiString = "WIFI:T:$securityType;S:$ssid;P:$password;;"

$encoded = [System.Uri]::EscapeDataString($wifiString)

# Génération du QR Code
$size = 300
$output = ".\$($ssid).png"
$url = "https://api.qrserver.com/v1/create-qr-code/?size=${Size}x${Size}&data=$encoded"

Invoke-WebRequest -Uri $url -OutFile $output

Write-Status SUCCESS "QR Code Wi-Fi généré : $output`n"
