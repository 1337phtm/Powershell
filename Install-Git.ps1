. $PSScriptRoot\src\Setup.ps1
Clear-Host
Show-SectionHeader "Git Install"
try {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        Write-Status SUCCESS "Git est déjà installé."
        Write-Host ""
    }
    else {
        Write-Status INFO "Git n'est pas installé. Installation..."
        winget install --id Git.Git -e --source winget
    }
}
catch {
    Write-Status ERROR "Erreur lors de la vérification de Git."
}
$userName = git config --global user.name
$userEmail = git config --global user.email
if (-not $userName -or -not $userEmail) {
    Write-Status INFO "Git needs to be configured for first use."
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
        Write-Status SUCCESS "Git has been configured successfully."
    }
    else {
        Write-Status SKIP "Git configuration skipped. You can configure it later using 'git config --global user.name' and 'git config --global user.email'."
        Write-Host ""
        Pause
        Clear-Host
        return
    }
}
if ($userName -and $userEmail) {
    Write-Status SUCCESS "Your Git informations is already saved and/or up to date."
    Write-Host ""
    Write-Status INFO "Your current Username : $($userName)"
    Write-Status INFO "Your current Email : $($userEmail)"
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
        Write-Status SUCCESS "Your git information has been updated."
    }
    else {
        return
    }
}
Write-Host ""
Pause
return
