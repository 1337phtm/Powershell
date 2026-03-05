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
        if ($choice -eq 'N' -or $choice -eq 'n') {
            Pause
            return $true
        }
    }

    Write-Host ""
    Pause
    return $false
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

function Clone-Repo {
    Clear-Host
    Search-InstallGit

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

        $choice = Read-Host "Do you want to clone $($repo.name) ? (Y/N) or all repositories ? (A) "
        Write-Host ""

        if ($choice -in @("A", "a")) {
            Clone-All
            break   # ⬅️ IMPORTANT : on sort de la boucle principale
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
function Remove-Repo {
    Clear-Host
    Search-InstallGit

    #======================================================================
    # Remove
    #======================================================================

    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║               Git Remove             ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    function Find-repo {

        # Dossiers à exclure
        $exclude = @(
            "$env:WINDIR",
            "C:\Windows",
            "C:\Program Files",
            "C:\Program Files (x86)",
            "C:\inetpub",
            "C:\PerfLogs"
            "C:\ProgramData"
        )

        $drives = Get-PSDrive -PSProvider FileSystem
        $allRepos = @()

        Write-Host "Searching for folder git ..." -ForegroundColor Yellow
        foreach ($drive in $drives) {
            # Vérifie si le disque doit être exclu
            if ($exclude -contains $drive.Root.TrimEnd("\")) {
                Write-Host "Skipping excluded drive $($drive.Root)" -ForegroundColor DarkGray
                continue
            }
            try {
                $repos = Get-ChildItem `
                    -Path $drive.Root `
                    -Directory `
                    -Filter ".git" `
                    -Recurse `
                    -Force `
                    -ErrorAction SilentlyContinue

                foreach ($folder in $repos) {
                    if ($folder.Parent) {
                        # Vérifie qu’il y a bien un parent
                        $allRepos += $folder.Parent.FullName  # Ajoute le chemin du repo
                    }
                }
            }
            catch {
                # accès refusé : ignoré
            }
        }

        Write-Host ""
        Write-Host "Found $($allRepos.Count) Git repositories :" -ForegroundColor Cyan
        Write-Host ""
        for ($i = 0; $i -lt $allRepos.Count; $i++) {
            Write-Host "[$($i+1)] $($allRepos[$i])" -ForegroundColor Yellow
            Write-Host ""
        }

        #Suppression des dossier

        foreach ($repo in $allRepos) {
            $choice = Read-Host "Do you want to delete $repo ? (Y/N) "
            Write-Host ""
            if ($choice -in @("Y", "y")) {
                Remove-Item -Path $repo -Recurse -Force
                Write-Host "✔  Deletion of $repo successful." -ForegroundColor Green
                Write-Host ""
            }
        }
    }

    Find-repo
    Pause
    Clear-Host
}

Export-ModuleMember -Function Install-Git, Clone-Repo, Remove-Repo
