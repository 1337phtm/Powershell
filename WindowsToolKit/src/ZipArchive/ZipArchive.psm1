# ZipArchive.psm1
# Gestion des sauvegardes / archives

#======================================================================
# Main - Menu principal Ziparchive
#======================================================================

function Start-ZipMenu {
    while ($true) {
        Show-ZipMenu
        $choice = Read-Host "Choose an option"
        switch ($choice) {
            "1" { 
                Get-Archivebackup 
                Write-log "Choice 1 selected: Archive Backup"  
            }
            "2" { 
                Get-CurseforgeBackup 
                Write-log "Choice 2 selected: CurseForge Backup"  
            }
            "0" { return }
            default {
                Write-Host "Invalid choice." -ForegroundColor Red
                Stop-Screen
            }
        }
    } 
}

#======================================================================
# Menus d'affichage
#======================================================================

function Show-ZipMenu {
    Write-Log "Displaying Zip Archive menu"
    Clear-Host
    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor DarkYellow
    Write-Host "║            Archive Backup            ║" -ForegroundColor DarkYellow
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "[1]  Archive Zip"
    Write-Host "[2]  Archive CurseForge"
    Write-Host ""
    Write-Host "[0]  Back to main menu" -ForegroundColor DarkGray
    Write-Host ""
}

#======================================================================
# Archive Backup
#======================================================================

function Get-Archivebackup {
    Clear-Host
    Write-Host "════════════════════════════════════════════ Starting Archive backup ════════════════════════════════════════════"
    Write-Host ""

    # Sélecteur de dossier
    function Select-Folder($message) {
        $FolderBrowser = New-Object -ComObject Shell.Application
        $Folder = $FolderBrowser.BrowseForFolder(0, $message, 0, 0)
        if ($Folder) { return $Folder.Items().Item().Path } else { return $null }
    }

    # Choix du nombre de dossiers
    [int]$nbFolders = Read-Host "How many repertory do you want to archive ? "
    if ($nbFolders -lt 1) {
        Write-Host ""
        Write-Host "You need at least 1 case to archive." -ForegroundColor Red
        Write-Host ""
        Pause
        return
    }

    # Sélection et vérification des dossiers
    $folders = @()
    for ($i=1; $i -le $nbFolders; $i++) {
        $folder = Select-Folder "Choose the folder number $i : "
        if (-not $folder) { Write-Host "Selection cancelled." -ForegroundColor Red; return }
        if (!(Test-Path $folder)) { Write-Error "The folder $folder does not exist."; Pause; return }
        $folder = $folder.TrimEnd('\','/')
        $folders += $folder
    }

    # Préparer sortie et staging
    $Date   = Get-Date -Format "yyyy-MM-dd_HH-mm"
    $Output = "$env:USERPROFILE\Desktop\Save_$Date.zip"
    $Stage  = Join-Path $env:TEMP ("$USERPROFILE" + [Guid]::NewGuid().ToString())

    # Incrémentation s'il existe déjà
    $counter = 1
    while (Test-Path $Output) {
        $Output = "$env:USERPROFILE\Desktop\Save_${Date}_$counter.zip"
        $counter++
    }

    # Créer staging
    New-Item -ItemType Directory -Path $Stage | Out-Null

    try {
        foreach ($folder in $folders) {
            $baseName = Split-Path $folder -Leaf
            $target   = Join-Path $Stage $baseName

            Write-Host ">> Copy '$folder' -> '$target'"
            Copy-Item -Path $folder -Destination $target -Recurse -Force
        }

        # Un seul dossier → zip direct du dossier, sinon zip du staging
        if ($folders.Count -eq 1) {
            Compress-Archive -Path (Join-Path $Stage (Split-Path $folders[0] -Leaf)) -DestinationPath $Output -Force
            Write-Host "Archive créée avec le dossier : $($folders[0])"
        } else {
            Compress-Archive -Path $Stage -DestinationPath $Output -Force
            Write-Host "Archive créée avec tous les dossiers choisis."
        }
    }
    catch {
        Write-Host "[ERREUR] Archive backup: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
    finally {
        # Nettoyer staging
        if (Test-Path $Stage) { Remove-Item $Stage -Force -Recurse }
    }

    Write-Host ""
    Write-Host "Archive finale : $Output"
    Write-Host ""
}


#======================================================================
# Curseforge Backup
#======================================================================

function Get-Curseforgebackup {
Clear-Host
Write-Host "════════════════════════════════════════════ Starting curseforge backup ════════════════════════════════════════════"
Write-Host ""


# --- AUTO-DETECTION DU CHEMIN CURSEFORGE ---
$BasePaths = @(
    "$env:USERPROFILE\CurseForge\Minecraft\Instances\",
    "$env:USERPROFILE\Documents\CurseForge\Minecraft\Instances\",
    "$env:APPDATA\CurseForge\Minecraft\Instances\"
)

# --- RECHERCHE DES INSTANCES ---
$Instances = @()
foreach ($path in $BasePaths) {
    if (Test-Path $path) {
      $Instances += Get-ChildItem -Path $path -Directory | Select-Object -ExpandProperty FullName
    }
}

if (-not $Instances) {
  Write-Host "ERROR : No CurseForge instances found in any known location."
  Write-Host ""
  return
}

# --- AFFICHAGE ET CHOIX ---
Write-Host "Instances found:"
for ($i = 0; $i -lt $Instances.Count; $i++) {
  Write-Host "[$i] $($Instances[$i])"
}

$choice = Read-Host "Enter the number of the instance you want to back up"
if ($choice -notmatch '^\d+$' -or [int]$choice -ge $Instances.Count) {
  Write-Host "Invalid choice. Exiting."
  return
}

$CurseForgePath = $Instances[$choice]
$Profil = Split-Path $CurseForgePath -Leaf


Write-Host ""
Write-Host "Profile selected: $Profil"
Write-Host "Path: $CurseForgePath"
Write-Host ""


# --- CHEMIN DU ZIP ---
$Date = Get-Date -Format "yyyy-MM-dd_HH-mm"
$Output = "$env:USERPROFILE\Desktop\Save_${Profil}_$Date.zip"


Write-Host "Create the zip file in : $Output"
Write-Host ""

Add-Type -AssemblyName System.IO.Compression.FileSystem

try {
  [System.IO.Compression.ZipFile]::CreateFromDirectory($CurseForgePath, $Output)
  Write-Host "Export complete."
  Write-Host "Archive created at: $Output"
}
catch {
  Write-Host "ERROR during archive creation: $_"
}
}

#======================================================================
# Export
#======================================================================

Export-ModuleMember -Function *-*
