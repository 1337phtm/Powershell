Clear-Host

. $PSScriptRoot\src\Setup.ps1 -LogName $PSCommandPath

Show-SectionHeader "Search for files with specific extension"

$ext = Read-Host "Enter the file extension to search (.kdbx, .txt, .jpg, etc.) "
$ext = $ext.TrimStart(".")   # Normalisation de l'extension
$drives = Get-PSDrive -PSProvider FileSystem

Show-SectionHeader "Select a drive to scan for *.$ext files"

#======================================================================
# Affichage des lecteurs disponibles
#======================================================================
for ($i = 0; $i -lt $drives.Count; $i++) {
    Write-Host "[$($i+1)] $($drives[$i].Root)" -ForegroundColor Cyan
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
        Show-SectionHeader "Searching for *.$ext in all drives"

        foreach ($drive in $drives) {
            Write-Status INFO "Scanning $($drive.Root) ..." -ForegroundColor Cyan
            Write-Host ""
            $files = Get-ChildItem -Path $drive.Root -Filter "*.$ext" -Recurse -ErrorAction SilentlyContinue -Force
            if ($files.count -eq 0) {
                Write-Status SKIP "No *.$ext files found in $($drive.Root)"
                Write-Host ""
            }
            else {
                foreach ($file in $files) {
                    Write-Status SUCCESS "$($file.FullName)"
                }
                Write-Host ""
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
                Write-Status SKIP "No *.$ext files found in $($selectedDrive.Root)`n"
            }
            else {
                foreach ($file in $files) {
                    Write-Status SUCCESS "$($file.FullName)"
                }
                Write-Host ""
            }
        }
        else {
            Write-Host "Invalid choice." -ForegroundColor Red
            return
        }
    }
}
