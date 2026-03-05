#======================================================================
# Install Git
#======================================================================
function Get-GitInstallation {
    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║            Git Installation          ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

# Vérification de l'installation de Git
try {
    $gitCmd = Get-Command git -ErrorAction SilentlyContinue
    
    if ($gitCmd) {
        Write-Host "✔  Git est déjà installé." -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "➜  Git n'est pas installé." -ForegroundColor Yellow
        Write-Host ""
        $choice = Read-Host "Do you want to install Git now ? (Y/N)"
        Write-Host ""
        if ($choice -eq "Y" -or $choice -eq "y") {
            Write-Host "Installing Git..." -ForegroundColor Yellow
            winget install --id Git.Git -e --source winget

            # Recharge PATH pour que Git soit reconnu immédiatement
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                        [System.Environment]::GetEnvironmentVariable("Path","User")

            Write-Host "✔  Git has been installed successfully." -ForegroundColor Green
            Write-Host ""
    } else {
            Write-Host "⚠  Git installation skipped." -ForegroundColor DarkRed
            Write-Host ""
        }
    }
}
catch {
    Write-Host "Erreur lors de la vérification de Git."
}

# Configuration de Git si nécessaire
$userName = git config --global user.name
$userEmail = git config --global user.email

    if (-not $userName -or -not $userEmail) 
    {
        Write-Host "Git needs to be configured for first use." -ForegroundColor Yellow
        Write-Host ""
        $choice = Read-Host "Do you want to configure Git now ? (Y/N)"
        Write-Host ""

        if ($choice -eq 'Y' -or $choice -eq 'y') 
        {
            $Name = Read-Host "Enter your Git user name"
            Write-Host ""
            $Email = Read-Host "Enter your Git user email"
            Write-Host ""
            git config --global user.name $Name
            git config --global user.email $Email
            Write-Host "✔  Git has been configured successfully." -ForegroundColor Green
        } 
        else 
        {
            Write-Host "⚠  Git configuration skipped. You can configure it later using 'git config --global user.name' and 'git config --global user.email'." -ForegroundColor Red
            Write-Host ""
            Pause
            Clear-Host
            return
        }
    } 
    else 
    {
        Write-Host "✔  Git est déjà configuré :" -ForegroundColor Green
        Write-Host ""
        Write-Host "  Username : $userName" -ForegroundColor Blue
        Write-Host ""
        Write-Host "  Email    : $userEmail" -ForegroundColor Blue
    }   

Write-Host ""
Pause
Clear-Host
}

#======================================================================
# Installation WKT
#======================================================================

function Get-WKTInstallation {
    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║               WKT clone              ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

$clonePath = "C:\Repos"
$user = Read-Host "Enter the GitHub username to clone repos from"

# Récupère tous les repos publics de l'utilisateur
$repos = Invoke-RestMethod "https://api.github.com/users/$user/repositoryGithub"

foreach ($repo in $repos) {
    Write-Host ""
    $Choice = Read-Host "Do you want to clone the repository : $($repo.name) ? (Y/N)"
    Write-Host ""
    if ($Choice -eq 'Y' -or $Choice -eq 'y') {
        Write-Host "✔  Proceeding to clone $($repo.name)." -ForegroundColor Green
        Write-Host ""
        $url = $repo.clone_url
        git clone $url $clonePath\$($repo.name)
    } else {
        Write-Host "Skipping $($repo.name)..."
        Write-Host ""
        continue
    } 
    Write-Host ""
    Pause
    Write-Host ""
}

}

Clear-Host
Get-GitInstallation
Get-WKTInstallation
Clear-Host