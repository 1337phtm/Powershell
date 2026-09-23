# if masque ou @ip = pb 
#   alors write-host error masque ou ip mauvaise ou deja utilisé
# GESTION D'ERREUR
# option 5 : vérifier config réseau
# dans option ajouter :
#   si passerelle alors ne pas demander 
#   sinon 

Clear-Host

. $PSScriptRoot\src\Setup.ps1

#======================================================================
# Démarrage en admin :
#======================================================================

# ANTI-BOUCLE : Vérif fichier temporaire
$restartMarker = "$env:TEMP\$($MyInvocation.MyCommand.Name).restart"
if (Test-Path $restartMarker) {
    Remove-Item $restartMarker -Force
    # 2ème lancement → ON CONTINUE (admin OU user)
}
else {
    # 1er lancement
    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        Write-Status INFO "Elevation requise. Relance en administrateur..."
        $allArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        New-Item $restartMarker -ItemType File | Out-Null
        Start-Process powershell.exe -ArgumentList $allArgs -Verb RunAs -WorkingDirectory $PSScriptRoot
        exit
    }
}

#======================================================================
# Script :
#======================================================================

function Show-MainMenu {
    Clear-Host
    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║             IPv4 TOOLKIT             ║" -ForegroundColor Green
    Write-Host "║          WRITTEN BY 1337phtm         ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "[1]  Ajouter adresse IPv4" -ForegroundColor Green
    Write-Host "[2]  Modifier adresse IPv4" -ForegroundColor Yellow
    Write-Host "[3]  Supprimer adresse IPv4" -ForegroundColor Red
    Write-Host "[4]  DHCP mode" -ForegroundColor Blue
    Write-Host ""
    Write-Host "[0]  Exit" -ForegroundColor DarkGray
    Write-Host ""
}

function Add-IPAddress {
    Clear-Host
    Show-SectionHeader "Ajouter addresse IPv4"
    $Local:ifAlias = Read-Host "Interface souhaité : Ethernet ou Wifi "
    $Local:ip = Read-Host "Adresse IPv4 souhaitée "
    $Local:cidr = Read-Host "Masque en CIDR (Exemple : 24) "
    New-NetIPAddress -InterfaceAlias $Local:ifAlias -AddressFamily IPV4 -IPAddress $Local:ip -PrefixLength $Local:cidr -ErrorAction Stop # si non présente : -DefaultGateway $gateway
    Write-Host
    Write-Status Success "Adresse IPv4 ajouté avec succès : $($Local:ip)/$($Local:cidr)"
    Write-Host
    Pause
}

function ModifIPv4 {
    Clear-Host
    Show-SectionHeader "Modifier addresse IPv4"
    $ifAlias = Read-Host "Interface souhaité : Ethernet ou Wifi " 
    Write-Host
    $ips = Get-NetIPAddress -InterfaceAlias $ifAlias -AddressFamily IPv4 | Select-Object IPAddress, InterfaceIndex, AddressFamily, PrefixLength
    if($ips.count -gt 1) {
        for ($i = 0; $i -lt $ips.Count; $i++) {
            Write-Host "[$($i+1)] $($ips[$i].IPAddress)" -ForegroundColor Cyan
            Write-Host ""
        }
        #======================================================================
        # Choix de l'utilisateur
        #======================================================================
        $ipchoice = Read-Host "Enter your choice"
        switch ($ipchoice.ToUpper()) {
            "0" {
                Clear-Host
                return
            }

            default {
                # Convertit le choix en index (1 → 0, 2 → 1, etc.)
                $index = [int]$ipchoice - 1

                if ($index -ge 0 -and $index -lt $ips.Count) {
                    $selectedIPs = $ips[$index]

                    Write-Host ""
                    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Blue
                    Write-Host "║ You selected IP : $($selectedIPs.IPAddress)               ║" -ForegroundColor Blue
                    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Blue
                    Write-Host ""

                    Remove-NetIPAddress -InterfaceAlias $ifalias -IPAddress $selectedIPs.IPAddress -AddressFamily IPv4 -Confirm:$false
                    $ip = Read-Host "Enter new IPv4 address "
                    $cidr = Read-Host "Enter CIDR mask (Exemple : 24) "
                    New-NetIPAddress -InterfaceAlias $ifAlias -AddressFamily IPV4 -IPAddress $ip -PrefixLength $cidr #-DefaultGateway $gateway
                    Pause
                }
                else {
                    Write-Status ERROR "Invalid choice."
                    Pause
                    return
                }
            }
        }
    }
    else {
        Write-Host "Actual IP : $($ips.IPAddress)" -ForegroundColor Cyan
        Write-Host ""
        $ip = Read-Host "Enter new IPv4 address "
        $cidr = Read-Host "Enter CIDR mask (Exemple : 24) " 
        Remove-NetIPAddress -InterfaceAlias $ifalias -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
        New-NetIPAddress -InterfaceAlias $ifAlias -AddressFamily IPV4 -IPAddress $ip -PrefixLength $cidr #-DefaultGateway $gateway
    }
}

function Remove-IPAddress {
    Clear-Host
    Show-SectionHeader "Supprimer addresse IPv4"
    $ifAlias = Read-Host "Interface souhaité : Ethernet ou Wifi " 
    Write-Host
    $ips = Get-NetIPAddress -InterfaceAlias $ifAlias -AddressFamily IPv4 | Select-Object IPAddress, InterfaceIndex, AddressFamily, PrefixLength
    if($ips.count -gt 1) {
        for ($i = 0; $i -lt $ips.Count; $i++) {
            Write-Host "[$($i+1)] $($ips[$i].IPAddress)" -ForegroundColor Cyan
            Write-Host ""
        }
        $choice = Read-Host "Are you sure you want to delete all of these IP address [y/n] "
        if($choice -match "^[oOyY]") {
            Remove-NetIPAddress -InterfaceAlias $ifalias -AddressFamily IPv4 -Confirm:$false
            Pause
        }
        else {
            Write-Status ERROR "Invalid choice."
            Pause
            return
        }
    }
    else {
        Write-Host "Actual IP : $($ips.IPAddress)" -ForegroundColor Cyan
        Write-Host ""
        $choice = Read-Host "Are you sure you want to delete this IP address [y/n] "
        if($choice -match "^[oOyY]") {
            Remove-NetIPAddress -InterfaceAlias $ifalias -AddressFamily IPv4 -Confirm:$false
            Pause
        }
    }
}
<#

FAIRE UN SOUS MENU AVEC : 
    quand affichage de toutes les @ip demander quoi faire :
        supprimer une 
        supprimer plusieurs
            si une seule @ip :
                demande si veut bien supprimers

Supprimer Addresse IPv4 :
    if plusieurs addresse ip alors :
        Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4 | Select-Object IPAddress, InterfaceIndex, AddressFamily, PrefixLength
        quel ip voulez vous modifier (choisir nombre comme pour disk)
    else :
        modifier par défaut l'ip présente ($ip = ip de la seule adresse présente)
    Remove-NetIPAddress -InterfaceAlias $ifalias -IPAddress $ip -AddressFamily IPv4 -Confirm:$false
#>


function DHCPMode {
    Clear-Host
    Show-SectionHeader "Passage en mode DHCP"
}
<#
Passer en Statique :
- Set-NetIPInterface -dhcp disabled
- Remove-NetIPAddress
- Remove-NetRoute
- New-NetIpadress
- Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses $dns
#>

<#
Passer en DHCP :
- Remove-NetIPAddress
- Remove-NetRoute
- Set-NetIPInterface -dhcp Enabled
- Set-DnsClientServerAddress -InterfaceAlias Ethernet -ResetServerAddresses
#>

do {
    Show-MainMenu
    $choice = Read-Host "Choose an option"
    switch ($choice) {
        "1" {
            Add-IPAddress
        }
        "2" {
            ModifIPv4
        }
        "3" {
            Remove-IPAddress
        }
        "4" {
            DHCPMode
        }
        "0" {
            Clear-Host
            return
        }
        default {
            Write-Status Error "Invalid choice." -ForegroundColor Red
            Pause
        }
    }
} until ($choice -eq "0")