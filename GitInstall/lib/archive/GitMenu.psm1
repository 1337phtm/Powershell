Import-Module "$PSScriptRoot\Git.psm1"

function Show-GitMenu {
    #do {
    Clear-Host
    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║            GITHUB TOOLKIT            ║" -ForegroundColor Green
    Write-Host "║          WRITTEN BY 1337phtm         ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "[1]  Install git" -ForegroundColor DarkCyan
    Write-Host "[2]  Clone repo from user" -ForegroundColor DarkYellow
    Write-Host "[3]  Remove repo" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "[0]  Exit" -ForegroundColor DarkGray
    Write-Host ""

    $choice = Read-Host "Choose an option"

    switch ($choice) {
        "1" { Install-Git }
        "2" { Clone-Repo }
        "3" { Remove-Repo }
        "0" {
            Clear-Host
            return
        }
        default {
            Write-Host "Invalid choice." -ForegroundColor Red
            Pause
        }
    }
    #} until ($choice -ne "0")
}

Export-ModuleMember -Function Show-GitMenu
