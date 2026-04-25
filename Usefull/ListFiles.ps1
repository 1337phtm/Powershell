param(
    [string]$FolderPath = $PSScriptRoot
)

# Charger ton setup si besoin
. (Join-Path $PSScriptRoot "src/Setup.ps1") -LogName $PSCommandPath

# Récupérer tous les scripts (ps1 + psm1)
$files = Get-ChildItem -Path $FolderPath -Recurse -Include *.ps1 -ErrorAction SilentlyContinue |
Where-Object {
    $_.FullName -notlike "*\examples\*" -and
    $_.FullName -notlike "*\lib\*" -and
    $_.Name -notlike "Setup.ps1"
}

Show-SectionHeader "Select a script to run"

# Affichage du menu
for ($i = 0; $i -lt $files.Count; $i++) {
    Write-Host "[$($i+1)] $($files[$i].Name)"
}

Write-Host ""
Write-Host "[0] Exit" -ForegroundColor DarkGray
Write-Host ""
Write-Status INFO "Found $($files.Count) script(s) in $PSScriptRoot`n"

# Sélection utilisateur
$choice = Read-Host "Choose a script number"

switch ($choice) {
    "0" {
        Clear-Host
        return
    }
    default {
        if ($choice -match '^\d+$' -and $choice -ge 1 -and $choice -le $files.Count) {

    $selected = $files[$choice - 1]

    Write-Host "`n[+] Running: $($selected.FullName)"

    # Exécution du script
    . $selected.FullName
    }
}
else {
    Write-Host "Invalid choice."
}
}