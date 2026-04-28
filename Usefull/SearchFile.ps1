Clear-Host

. $PSScriptRoot\src\Setup.ps1

Show-SectionHeader "Search files"

$file = Read-Host "Enter a file to search "
$drives = Get-PSDrive -PSProvider FileSystem

Show-SectionHeader "Select a drive to scan"

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
        Show-SectionHeader "Searching $($file) in all drives"

        foreach ($drive in $drives) {
            Write-Status INFO "Scanning $($drive.Root) ..."
            Write-Host ""
            $files = Get-ChildItem -Path $drive.Root -Filter "$($file)*.*" -Recurse -ErrorAction SilentlyContinue -Force
            if ($files.count -eq 0) {
                Write-Status SKIP "No $file files found in $($drive.Root)"
                Write-Host ""
            }
            else {
                foreach ($fich in $files) {
                    Write-Status SUCCESS "$($fich.FullName)"
                }
            }
        }
    }

    default {
        # Convertit le choix en index (1 → 0, 2 → 1, etc.)
        $index = [int]$drivechoice - 1

        if ($index -ge 0 -and $index -lt $drives.Count) {
            $selectedDrive = $drives[$index]

            Write-Host ""
            Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Blue
            Write-Host "║ You selected drive : $($selectedDrive.Name)               ║" -ForegroundColor Blue
            Write-Host "║ Path : $($selectedDrive.Root)                           ║" -ForegroundColor Blue
            Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Blue
            Write-Host ""

            Write-Status INFO "Searching for $file in $($selectedDrive.Root) ...`n"

            $files = Get-ChildItem -Path $selectedDrive.Root -Filter "*$($file)*.*" -Recurse -ErrorAction SilentlyContinue

            if ($files.count -eq 0) {
                Write-Status SKIP "No $file files found in $($selectedDrive.Root)"
            }
            else {
                foreach ($fich in $files) {
                    Write-Status SUCCESS "$($fich.FullName)"
                }
                Write-Host ""
            }
        }
        else {
            Write-Status ERROR "Invalid choice."
            return
        }
    }
}
Pause