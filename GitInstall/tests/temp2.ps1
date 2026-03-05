
Clear-Host

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

#======================================================================
# Remove
#======================================================================

Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║               Git Remove             ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

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
$script:allRepos = @()


function Find-repo {
    Write-Host "Searching for folder git ..." -ForegroundColor Yellow
    foreach ($drive in $drives) {
        #Write-Host ""
        #Write-Host "Scanning $($drive.Root) ..." -ForegroundColor Yellow
        #Write-Host "Searching for folder git ..." -ForegroundColor Yellow

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
                    $script:allRepos += $folder.Parent.FullName  # Ajoute le chemin du repo
                }
            }
        }

        catch {
            # accès refusé ignoré
        }
    }

    Write-Host ""
    Write-Host "Found $($allRepos.Count) Git repositories :" -ForegroundColor Cyan
    Write-Host ""

    for ($i = 0; $i -lt $allRepos.Count; $i++) {
        Write-Host "[$($i+1)] $($allRepos[$i])" -ForegroundColor Yellow
        Write-Host ""
    }
}

Find-repo

Pause

Clear-Host
