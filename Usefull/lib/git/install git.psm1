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
else {
    Write-Host "✔  Git est déjà configuré :" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Username : $userName" -ForegroundColor Blue
    Write-Host ""
    Write-Host "  Email    : $userEmail" -ForegroundColor Blue
}

Write-Host ""
Pause
return
