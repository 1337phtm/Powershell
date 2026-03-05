function Clone-Repo {
    Clear-Host
    #Search-InstallGit

    #======================================================================
    # Clone GitHub Repositories
    #======================================================================

    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║               Git Clone              ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    $clonePath = "C:\Repos"
    if (-not (Test-Path $clonePath)) {
        New-Item -ItemType Directory -Path $clonePath | Out-Null
    }

    $user = Read-Host "Enter the GitHub username to clone repos from"
    Write-Host ""

    # Correct GitHub API URL
    $repos = Invoke-RestMethod "https://api.github.com/users/$user/repos"

    # Affichage des repos avec numéros
    Write-Host "Available repositories : " -ForegroundColor Cyan
    Write-Host ""

    for ($i = 0; $i -lt $repos.Count; $i++) {
        Write-Host "[$($i+1)] $($repos[$i].name)" -ForegroundColor Yellow
        Write-Host ""
    }

    #======================================================================
    # Clone All GitHub Repositories
    #======================================================================
    function Clone-All {
        foreach ($repo in $repos) {

            $target = "$clonePath\$($repo.name)"

            if (Test-Path $target) {
                Write-Host "⚠  $($repo.name) already exists. Updating..." -ForegroundColor Yellow
                Write-Host ""
                Set-Location $target
                git pull origin main
                Write-Host ""
                Write-Host "✔  The updating was successful." -ForegroundColor Green
            }
            else {
                Write-Host "✔  Cloning $($repo.name)..." -ForegroundColor Green
                git clone $repo.clone_url $target
                Write-Host ""
                Write-Host "✔  The cloning was successful at $($target)" -ForegroundColor Green
            }

            Write-Host ""
        }

        Pause
    }

    #======================================================================
    # Ask user for each repo OR clone all
    #======================================================================
    foreach ($repo in $repos) {

        $choice = Read-Host "Do you want to clone $($repo.name) ? (Y/N), all repositories ? (A), or exit [E] "
        Write-Host ""

        if ($choice -in @("A", "a")) {
            Clone-All
            break   # ⬅️ IMPORTANT : on sort de la boucle principale
        }

        if ($choice -in @("E", "e")) {
            return
        }

        if ($choice -in @("Y", "y")) {

            $target = "$clonePath\$($repo.name)"

            if (Test-Path $target) {
                Write-Host "⚠  Folder already exists. Updating..." -ForegroundColor Yellow
                Write-Host ""
                Set-Location $target
                git pull origin main
                Write-Host ""
                Write-Host "✔  The updating was successful." -ForegroundColor Green
            }
            else {
                Write-Host "✔  Cloning $($repo.name)..." -ForegroundColor Green
                Write-Host ""
                git clone $repo.clone_url $target
                Write-Host ""
                Write-Host "✔  The cloning was successful at $($target)" -ForegroundColor Green
            }
        }
        else {
            Write-Host "Skipping $($repo.name)..."
        }
        Write-Host ""
        Pause
        Write-Host ""
    }

}

Export-ModuleMember -Function Clone-Repo
