function Remove-Repo {
    Clear-Host
    #Search-InstallGit

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

        Write-Host "This action can take few minutes"
        Write-Host ""
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

            #Suppression des dossier
            $repo = $allRepos[$i]
            $num = $i + 1  # numéro humain (1,2,3...)

            $choice = Read-Host "[$num/$($allRepos.Count)] Do you want to delete $repo ? (Y/N)"
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

Export-ModuleMember -Function Remove-Repo
