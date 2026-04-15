Clear-Host

. $PSScriptRoot\Setup.ps1

Show-SectionHeader "Search for files with specific extension"

$ext = Read-Host "Enter the file extension to search (.kdbx, .txt, .jpg, etc.) "
$ext = $ext.TrimStart(".")   # Normalisation de l'extension
$drives = Get-PSDrive -PSProvider FileSystem

Show-SectionHeader "Select a drive to scan for *.$ext files"

#======================================================================
# Affichage des lecteurs disponibles
#======================================================================
for ($i = 0; $i -lt $drives.Count; $i++) {
    Write-Host "[$($i+1)] $($drives[$i].Root)" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "[A] All drives" -ForegroundColor Green
Write-Host ""
Write-Host "[0] Exit" -ForegroundColor DarkGray
Write-Host ""

#======================================================================
# Choix de l'utilisateur
#======================================================================
$drivechoice = Read-Host "Enter your choice"

switch ($drivechoice.ToUpper()) {

    "0" {
        Clear-Host
        return
    }

    "A" {
        Write-Host ""
        Show-SectionHeader "Searching for *.$ext in all drives"

        foreach ($drive in $drives) {
            Write-Host ""
            Write-Host "Scanning $($drive.Root) ..." -ForegroundColor Yellow
            Write-Host ""
            $files = Get-ChildItem -Path $drive.Root -Filter "*.$ext" -Recurse -ErrorAction SilentlyContinue -Force
            if ($files.count -eq 0) {
                Write-Status "INFO" "No *.$ext files found in $($selectedDrive.Root)"
            }
            else {
                $files | ForEach-Object { Write-Host $_.FullName }
            }
        }
        return
    }

    default {
        # Convertit le choix en index (1 → 0, 2 → 1, etc.)
        $index = [int]$drivechoice - 1

        if ($index -ge 0 -and $index -lt $drives.Count) {
            $selectedDrive = $drives[$index]

            Write-Host ""
            Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Blue
            Write-Host "║ You selected drive: $($selectedDrive.Name)                ║" -ForegroundColor Blue
            Write-Host "║ Path: $($selectedDrive.Root)                            ║" -ForegroundColor Blue
            Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Blue
            Write-Host ""

            Write-Status Info "Searching for *.$ext in $($selectedDrive.Root) ...`n"

            $files = Get-ChildItem -Path $selectedDrive.Root -Filter "*.$ext" -Recurse -ErrorAction SilentlyContinue
            if ($files.count -eq 0) {
                Write-Status "INFO" "No *.$ext files found in $($selectedDrive.Root)`n"
            }
            else {
                $files | ForEach-Object { Write-Host $_.FullName }
            }
        }
        else {
            Write-Host "Invalid choice." -ForegroundColor Red
            return
        }
    }
}
