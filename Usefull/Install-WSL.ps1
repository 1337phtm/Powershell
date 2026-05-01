
<#
A faire :

- voir pour mode admin car pas besoin je crois
- plus function qui lance les distrib installé au pire si superieur à 2 ou 3 affiche juste le nomp des distro


FAIRE tool

1 lancer wsl
    - lsite toutes les version demande laquelle lancer (wsl -d $choice)

2 supprimer distro

99999 affiche toutes les distros et demande que FAIRE
    1 lancer
    2 supprimer

    3 mettre a jour wsl pour 1 ou plusieurs distro

    puis demande sur quels distros le faire

#>


#======================================================================
# Démarrage en admin :
#======================================================================

#$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
#
#if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
#    # Relance le script en mode administrateur
#    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
#    exit
#}

. $PSScriptRoot\src\Setup.ps1

# en function car obligé de démarrer chaque distro pour récup la version
function Show-DistribAlreadyInstalled {

    Show-SectionHeader "Distribution already installed"

    # Force UTF-8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $env:WSL_UTF8 = "1"

    $install = wsl --list --quiet | Where-Object { $_.Trim() -ne "" }
    $result = @()

    foreach ($line in $install) {

        $name = $line.Trim()
        $version = wsl --distribution $name --exec cat /etc/os-release | Where-Object { $_ -match "^NAME=" } | ForEach-Object { $_.Split('=')[1].Trim('"') }
        $result += [PSCustomObject]@{
            Name    = $name
            Version = $version
        }
    }

    for ($i = 0; $i -lt $result.Count; $i++) {
        Write-Host "[$($i+1)] " -NoNewline -ForegroundColor Green
        Write-Host "$($result[$i].Name)" -NoNewline -ForegroundColor Green
        Write-Host " - " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($result[$i].Version)" -ForegroundColor DarkGray
    }

}

Show-SectionHeader "Distributions WSL"

#======================================================================
# Installation WSL :
#======================================================================

# Pour avoir que les 23 distros en non admin et si admin on a quand memme les 23 car select object 7
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
$distrib = wsl --list --online | Select-Object -Skip 4 |
    ForEach-Object {
        $line = $_.Trim()
        if ($line -ne "") {

            # Trouve la première séquence d'espaces (peu importe le type)
            $match = [regex]::Match($line, "\S+(\s+)\S")

            if ($match.Success) {
                $pos = $match.Groups[1].Index
                $name = $line.Substring(0, $pos).Trim()
                $friendly = $line.Substring($pos).Trim()
            }
            else {
                # fallback
                $name = $line
                $friendly = $line
            }

            $friendly = $($friendly -replace '\s+', ' ').Trim()

            [PSCustomObject]@{
                Name = $name
                FriendlyName = $friendly
            }
        }
    }
}
else {
$distrib = wsl --list --online | Select-Object -Skip 7 |
    ForEach-Object {
        $line = $_.Trim()
        if ($line -ne "") {

            # Trouve la première séquence d'espaces (peu importe le type)
            $match = [regex]::Match($line, "\S+(\s+)\S")

            if ($match.Success) {
                $pos = $match.Groups[1].Index
                $name = $line.Substring(0, $pos).Trim()
                $friendly = $line.Substring($pos).Trim()
            }
            else {
                # fallback
                $name = $line
                $friendly = $line
            }

            $friendly = $($friendly -replace '\s+', ' ').Trim()

            [PSCustomObject]@{
                Name = $name
                FriendlyName = $friendly
            }
        }
    }
}



for ($i = 0; $i -lt $distrib.Count; $i++) {

    # 1. Supprimer les caractères NULL (U+0000)
    $clean = $distrib[$i].FriendlyName.Replace([string][char]0x0000, '')

    # 2. Normaliser les espaces restants
    $label = ($clean -replace '\s+', ' ').Trim()

    Write-Host "[$($i+1)] $label" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "[0] Exit" -ForegroundColor DarkGray
Write-Host ""

$choice = Read-Host "Enter your choice "

Switch ($choice.ToUpper()) {

    "0" {
        Clear-Host
        return
    }

    default {
        $index = [int]$choice - 1

        if ($index -ge 0 -and $index -lt $distrib.Count) {

            $selectedDistrib = $distrib[$index]
            $cleanName = $selectedDistrib.Name.Replace([string][char]0x0000, '')

            Show-SectionHeader "Installing $($cleanName) distribution"

            Write-Status INFO "Installing $($cleanName) distribution ...`n"
            wsl --install -d $($cleanName) | Out-Null
        }
        else {
            Write-Status ERROR "Invalid choice. Please select a valid option." -ForegroundColor Red
        }
    }
}

# Deja installé
$err = $LASTEXITCODE
if ($err -eq -1) {
    Write-Status INFO "$($cleanName) is already installed."

    Write-Status INFO "Do you want to install another $($cleanName) with a new name ? (Y/N)"
    Write-Host ""
    $choice = Read-Host "Enter your choice "
    if ($choice.ToUpper() -eq "Y") {
        $newName = Read-Host "Enter the new name for the distribution "
        wsl --install -d $($cleanName) --name $newName | Out-Null
    }
}

#Pause
