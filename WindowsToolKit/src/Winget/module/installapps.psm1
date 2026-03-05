function Show-Menu {
    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║             Install Apps             ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "[1]  Systeme" -ForegroundColor DarkCyan
    Write-Host "[2]  Gaming" -ForegroundColor DarkYellow
    Write-Host "[3]  All apps"
    Write-Host ""
    Write-Host "[0]  Back to main menu" -ForegroundColor DarkGray
    Write-Host ""
}

function Install-Menu {
    do {
        Clear-Host
        Show-Menu
        $choice = Read-Host "Choose an option"
        switch ($choice) {
            "1" { Install-Sys }
            "2" { }
            "3" { }
            "4" { }
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

function Install-Sys {
    Clear-Host
    $filePath = "$PSScriptroot\apps.json" #charge le json

    #Teste le fichier
    if (-not (Test-Path $filePath)) {
        Write-Host "❌ apps.json not found" -ForegroundColor Red
        return
    }

    #récupère le contenu
    $apps = Get-Content $filePath -Raw | ConvertFrom-Json

    $InstallPath = Read-Host "Enter the location for installation "
    foreach ($app in $apps) {
        if ($app.category -eq "System" -and $app.supportsLocation -eq $true) {
            Write-Host ""
            Write-Host "📁 $($app.name) will be installed to : $InstallPath\$($app.name)" -ForegroundColor Yellow
            Write-Host ""
            winget install --id $app.id --location "$InstallPath\$($app.name)"
        }
        elseif ($app.category -eq "System" -and $app.supportsLocation -eq $false) {
            Write-Host ""
            Write-Host "⚠️ $($app.name) does NOT support custom installation path and will be installed to : $($app.Location)" -ForegroundColor Yellow
            Write-Host ""
            $choice = Read-Host "Do you want to proceed installation anyway ? (Y/N) "
            if ($choice -eq "Y" -or $choice -eq "y") {
                winget install --id $app.id
            }
        }
    }
    return
}

Export-ModuleMember -Function Install-Menu
