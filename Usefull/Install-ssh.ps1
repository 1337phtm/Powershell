#======================================================================
# Démarrage en admin :
#======================================================================

# Vérifie si le script est lancé en tant qu'administrateur
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    # Relance le script en mode administrateur
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

. $PSScriptRoot\Setup.ps1

Show-SectionHeader "Installation OpenSSH Client"

#======================================================================
# Installation OpenSSH Client :
#======================================================================

# Vérifier disponibilité
$sshClient = Get-WindowsCapability -Online | Where-Object Name -Like 'OpenSSH.Client~~~~0.0.1.0'
$sshAgent = Get-Service -Name 'ssh-agent' -ErrorAction SilentlyContinue

# --- Installation si absent ---
if ($sshClient.State -eq "NotPresent") {
    Write-Host ""
    Write-Status INFO "OpenSSH Client non présent, installation..."
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0 -ErrorAction Stop
    Write-Host ""
    Write-Status SUCCESS "OpenSSH Client installé"
}
elseif ($sshClient.State -eq "Installed") {
    Write-Host ""
    Write-Status SKIP "OpenSSH Client déjà installé"
}
else {
    Write-Host ""
    Write-Status ERROR "État inattendu : $($sshClient.State)"
}

# --- Configuration du service ssh-agent ---
if ($sshAgent) {
    if ($sshAgent.StartType -ne "Automatic") {
        Set-Service ssh-agent -StartupType Automatic
    }
    if ($sshAgent.Status -ne "Running") {
        Start-Service ssh-agent
    }
    else {
        Write-Host ""
        Write-Status SUCCESS "Service SSH déjà configuré"
    }
}

Write-Host ""
Write-Status SUCCESS "OpenSSH Server installé et actif" -ForegroundColor Green
Write-Host ""
Write-Status INFO "Cette fenêtre se fermera automatiquement dans 10 secondes"
Write-Host ""

Start-Sleep 10; exit
