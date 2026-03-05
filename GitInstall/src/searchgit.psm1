
function Install-Git {
    #Code pour main
    Clear-Host

    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║              Git Install             ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Gree
    Write-Host ""


    # Vérification de l'installation de Git
    try {
        $pkg = winget list --id Git.Git 2>$null

        if ($pkg -match "Git.Git") {
            Write-Host "✔  Git est déjà installé." -ForegroundColor Green
            Write-Host ""
        }
        else {
            Write-Host "➜  Git n'est pas installé. Installation..." -ForegroundColor Yellow
            winget install --id Git.Git -e --source winget
        }
    }
    catch {
        Write-Host "Erreur lors de la vérification de Git."
    }

    # Configuration de Git si nécessaire
    $userName = git config --global user.name
    $userEmail = git config --global user.email



    if (-not $userName -or -not $userEmail) {
        Write-Host "Git needs to be configured for first use." -ForegroundColor Yellow
        Write-Host ""
        $choice = Read-Host "Do you want to configure Git now ? (Y/N)"
        Write-Host ""

        if ($choice -eq 'Y' -or $choice -eq 'y') {
            $Name = Read-Host "Enter your Git user name"
            Write-Host ""
            $Email = Read-Host "Enter your Git user email"
            Write-Host ""
            git config --global user.name $Name
            git config --global user.email $Email
            Write-Host "✔  Git has been configured successfully." -ForegroundColor Green
        }
        else {
            Write-Host "⚠  Git configuration skipped. You can configure it later using 'git config --global user.name' and 'git config --global user.email'." -ForegroundColor Red
            Write-Host ""
            Pause
            Clear-Host
            return
        }
    }

    if ($userName -and $userEmail) {
        Write-Host “Your Git informations is already saved and/or up to date.” -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Your current Username : $($userName)" -ForegroundColor DarkYellow
        Write-Host "Your current Email : $($userEmail)" -ForegroundColor DarkYellow
        Write-Host ""
        $choice = Read-Host "Do you want to update them (Y/N)"
        Write-Host ""

        if ($choice -eq 'Y' -or $choice -eq 'y') {
            $Name = Read-Host "Enter your Git user name"
            Write-Host ""
            $Email = Read-Host "Enter your Git user email"
            Write-Host ""
            git config --global user.name $Name
            git config --global user.email $Email
            Write-Host "✔  Your git information has been updated." -ForegroundColor Green
        }
        else {
            return
        }
    }

    Write-Host ""
    Pause
    return
}

function Search-InstallGit {
    #fonction générique pour cherche git silencieusement

    #======================================================================
    # Git Installation Check
    #======================================================================
    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║            Git Installation          ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    try {
        $gitCmd = Get-Command git -ErrorAction SilentlyContinue

        if (-not $gitCmd) {
            Write-Host "➜  Git is not installed." -ForegroundColor Yellow
            Write-Host ""
            $choice = Read-Host "Do you want to install Git now ? (Y/N)"
            Write-Host ""

            if ($choice -in @("Y", "y")) {
                Write-Host "Installing Git..." -ForegroundColor Yellow
                winget install --id Git.Git -e --source winget

                # Reload PATH
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")

                Write-Host ""
                Write-Host "✔  Git has been installed successfully." -ForegroundColor Green
                Write-Host ""
            }
            else {
                Write-Host "⚠  Git installation skipped. The script cannot continue." -ForegroundColor DarkRed
                Pause
                return
            }
        }
    }
    catch {
        Write-Host "Error while checking Git installation." -ForegroundColor Red
        return
    }

    Clear-Host
}

Export-ModuleMember -Function Search-InstallGit, Install-Git
