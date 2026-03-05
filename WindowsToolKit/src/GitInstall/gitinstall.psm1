$Global:ErrorActionPreference = "Stop"

#======================================================================
# Importation des modules
#======================================================================
Import-Module "$PSScriptRoot\module\searchgit.psm1" -Force -DisableNameChecking
Import-Module "$PSScriptRoot\module\clonerepo.psm1" -Force -DisableNameChecking
Import-Module "$PSScriptRoot\module\removerepo.psm1" -Force -DisableNameChecking

#======================================================================
# Affichage du menu principal
#======================================================================
function Show-Main {
    Clear-Host
    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║               GIT TOOLKIT            ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "[1]  Install git" -ForegroundColor DarkCyan
    Write-Host "[2]  Clone repo from user" -ForegroundColor DarkYellow
    Write-Host "[3]  Remove repo" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "[0]  Back to main menu" -ForegroundColor DarkGray
    Write-Host ""
}


#======================================================================
# Fonction du menu principal
#======================================================================
function Start-Git {
    do {
        Show-Main
        $choice = Read-Host "Choose an option"
        switch ($choice) {
            "1" { Install-Git }
            "2" { Search-InstallGit; Clone-Repo }
            "3" { Search-InstallGit; Remove-Repo }
            "0" {
                Clear-Host
                return
            }
            default {
                Write-Host "Invalid choice." -ForegroundColor Red
                Pause
            }
        }
    } until ($choice -eq "0")
}

Export-ModuleMember -Function Start-Git
