#======================================================================
# Importation des modules
#======================================================================
Import-Module "$PSScriptRoot\module\installapps.psm1" -Force -DisableNameChecking

#======================================================================
# Affichage du menu principal
#======================================================================
function Show-MainMenu {
    Write-Log "Starting Main Menu"
    Clear-Host
    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║              WINGET MENU             ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "[1]  Install apps" -ForegroundColor DarkCyan
    Write-Host "[2]  Remove apps" -ForegroundColor DarkYellow
    Write-Host "[3]  Upgrade apps" -ForegroundColor Magenta
    Write-Host "[4]  Search apps" -ForegroundColor Blue
    Write-Host ""
    Write-Host "[0]  Back to main menu" -ForegroundColor DarkGray
    Write-Host ""
}
#======================================================================
# Fonction du menu principal
#======================================================================
function Start-WingetMenu {
    do {
        Clear-Host
        Show-MainMenu
        $choice = Read-Host "Choose an option"
        switch ($choice) {
            "1" { Install-Menu }
            "2" {

            }
            "3" {

            }
            "4" {

            }
            "0" {
                Clear-Host
                return
            }
            default {
                Write-Host "Invalid choice." -ForegroundColor Red
            }
        }
    } until ($choice -eq "0")
}
#======================================================================
# Démarrage du programme
#======================================================================

Export-ModuleMember -Function Start-WingetMenu
