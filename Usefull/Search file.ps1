Clear-Host

. $PSScriptRoot\Setup.ps1

Show-SectionHeader "Search for files"

$file = Read-Host "Enter a file to search "
$drives = Get-PSDrive -PSProvider FileSystem

Show-SectionHeader "Select a drive to scan"

#======================================================================
# Affichage des lecteurs disponibles
#======================================================================
for ($i = 0; $i -lt $drives.Count; $i++) {
    Write-Host "[$($i+1)] $($drives[$i].Name) :  $($drives[$i].Root)" -ForegroundColor Yellow
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
        Show-SectionHeader "Scanning all drives"

        foreach ($drive in $drives) {
            Write-Host ""
            Write-Status Info "Scanning $($drive.Root) ..."
            Write-Host ""
            $files = Get-ChildItem -Path $drive.Root -Filter "$($file)*.*" -Recurse -ErrorAction SilentlyContinue -Force
            if ($files.count -eq 0) {
                Write-Status "INFO" "No $file files found in $($selectedDrive.Root)"
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

            Write-Host "`n╔══════════════════════════════════════╗" -ForegroundColor Blue
            Write-Host "║ You selected drive : $($selectedDrive.Name)               ║" -ForegroundColor Blue
            Write-Host "║ Path : $($selectedDrive.Root)                           ║" -ForegroundColor Blue
            Write-Host "╚══════════════════════════════════════╝`n" -ForegroundColor Blue

            Write-Status Info "Searching for $file in $($selectedDrive.Root) ...`n"

            $files = Get-ChildItem -Path $selectedDrive.Root -Filter "*$($file)*.*" -Recurse -ErrorAction SilentlyContinue

            if ($files.count -eq 0) {
                Write-Status "INFO" "No $file files found in $($selectedDrive.Root)"
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
