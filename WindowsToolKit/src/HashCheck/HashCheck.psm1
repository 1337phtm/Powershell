# HashCheck.psm1
# Outils de hash (comparaison, copie, etc.)

#======================================================================
# Main - Menu principal Hashmenu
#======================================================================

function Start-HashMenu {
    while ($true) {
        Show-HashMainMenu
        $choice = Read-Host "Choose an option"
        switch ($choice) {
            "1" {
                HashCheckCopy
                Write-Log "Choice 1 selected : Hash Check Copy"
            }
            "2" {
                HashCheckVerify
                Write-Log "Choice 2 selected : Hash Check Verify"
            }
            "3" {
                HashCheckRemove
                Write-Log "Choice 3 selected : Hash Check Remove"
            }
            "0" { return }
            default {
                Write-Host "Invalid choice." -ForegroundColor Red
                Write-ErrorLog -Source "Hash Check Menu" -Message "Invalid choice : $choice" -Silent
                Stop-Screen
            }
        }
    }
}

#======================================================================
# Menus d'affichage
#======================================================================

function Show-HashMainMenu {
    Write-Log "Displaying Hash Check menu"
    Clear-Host
    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║             HASHCHECK MENU           ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "[1]  Hash Check Copy"
    Write-Host "[2]  Hash Check Verify"
    Write-Host "[3]  Hash Check Remove"
    Write-Host ""
    Write-Host "[0]  back to main menu" -ForegroundColor DarkGray
    Write-Host ""
}

function Show-HashCheck {
    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║              Hash Check              ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
}

#======================================================================
# Fonctions de base
#======================================================================

#Fonction select dossier via fenêtre
function Select-Folder($message) {

    $FolderBrowser = New-Object -ComObject Shell.Application
    $Folder = $FolderBrowser.BrowseForFolder(0, $message, 0, 0)
    if ($Folder) {
        return $Folder.Items().Item().Path
    }
    else {
        Write-ErrorLog -Source "HASH CHECK | SELECTFOLDER" -Message "User canceled folder selection" -Silent
        return "CANCELED"
    }
}


# Fonction pour copier les fichiers sans écraser
function Copy-Unique($files, $destination) {
    foreach ($file in $files) {
        $destPath = Join-Path $destination $file.Name
        $counter = 1
        while (Test-Path $destPath) {
            $base = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
            $ext = [System.IO.Path]::GetExtension($file.Name)
            $destPath = Join-Path $destination ("$base" + "_$counter" + "$ext")
            $counter++
        }
        Copy-Item $file.Path -Destination $destPath
    }
}



#======================================================================
# HashCheck Copy
#======================================================================

function HashCheckCopy {

    Clear-Host
    Show-HashCheck

    # Demander combien de dossiers comparer
    [int]$nbFolders = Read-Host "How many repertory do you want to compare ? "

    if ($nbFolders -lt 2) {
        Write-Host ""
        Write-Host "You need at least 2 cases to compare." -ForegroundColor Red
        Write-Host ""
        Write-ErrorLog -Source "HASH CHECK | SELECTFOLDER" -Message "User choose less than 2 cases to compare." -Silent
        Pause
        return
    }

    # Sélectionner les dossiers sources
    $folders = @()
    for ($i = 1; $i -le $nbFolders; $i++) {
        $folder = Select-Folder "Choose the folder number $i : "
        if ($folder -eq "CANCELED") {
            return  # ← quitte la fonction appelante immédiatement
        }
        $folders += $folder
    }

    # Sélectionner le dossier final
    $finalFolder = Select-Folder "Choose the final folder : "
    if ($finalFolder -eq "CANCELED") {
        return  # ← quitte la fonction appelante immédiatement
    }

    # Récupérer les fichiers et leurs hash pour chaque dossier
    $allHashes = @()
    foreach ($folder in $folders) {
        $hashes = Get-ChildItem $folder -File -Recurse | ForEach-Object {
            [PSCustomObject]@{
                Path = $_.FullName
                Name = $_.Name
                Hash = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
            }
        }
        $allHashes += $hashes
    }

    # Trouver les fichiers uniques (hash apparaissant une seule fois)
    $uniqueFiles = $allHashes | Group-Object Hash | Where-Object { $_.Count -eq 1 } | ForEach-Object { $_.Group }


    # Copier les fichiers uniques
    Copy-Unique $uniqueFiles $finalFolder

    Write-Host ""
    Write-Output "All unique files have been copied into $finalFolder."
    Write-Host ""

    Invoke-Item $finalFolder
}

#======================================================================
# HashCheck Verify
#======================================================================

function HashCheckVerify {

    Clear-Host
    Show-HashCheck

    # Demander combien de dossiers comparer
    [int]$nbFolders = Read-Host "How many repertory do you want to compare ? "

    if ($nbFolders -lt 2) {
        Write-Host ""
        Write-Host "You need at least 2 cases to compare." -ForegroundColor Red
        Write-Host ""
        Write-ErrorLog -Source "HASH CHECK | SELECTFOLDER" -Message "User choose less than 2 cases to compare." -Silent
        Pause
        return
    }

    # Sélectionner les dossiers sources
    $folders = @()
    for ($i = 1; $i -le $nbFolders; $i++) {
        $folder = Select-Folder "Choose the folder number $i : "
        if ($folder -eq "CANCELED") {
            return  # ← quitte la fonction appelante immédiatement
        }
        $folders += $folder
    }

    # Récupérer les fichiers et leurs hash pour chaque dossier
    $allHashes = @()
    foreach ($folder in $folders) {
        $hashes = Get-ChildItem $folder -File -Recurse | ForEach-Object {
            [PSCustomObject]@{
                Path          = $_.FullName
                Name          = $_.Name
                Hash          = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
                Size          = $_.Length
                LastWriteTime = $_.LastWriteTime
                #ShortPath     = $_.DirectoryName.Split('\')[-1] + "\" + $_.Name
            }
        }
        $allHashes += $hashes
    }

    # Trouver les fichiers uniques (hash apparaissant une seule fois)
    $uniqueFiles = $allHashes | Group-Object Hash | Where-Object { $_.Count -eq 1 } | ForEach-Object { $_.Group }

    Write-Host ""
    #Write-Output $uniqueFiles | Format-Table Name, Size, LastWriteTime, Path -AutoSize #ShortPath
    Write-Output $uniqueFiles | Format-Table ` @{Label = "LastWrite"; Expression = { $_.LastWriteTime }; Width = 22 }, @{Label = "Name"; Expression = { $_.Name }; Width = 25 }, @{Label = "Size"; Expression = { $_.Size }; Width = 10 }, @{Label = "Path"; Expression = { $_.Path }; Width = 80 }
    Write-Host ""

    Stop-Screen

}

#======================================================================
# HashCheck Remove
#======================================================================

function HashCheckRemove {
}

#======================================================================
# Export
#======================================================================

Export-ModuleMember -Function *-*
