param(
    [string]$FolderPath = $PSScriptRoot,
    [string]$JsonFile = "$PSScriptRoot\data\scripts_status.json"
)

. $PSScriptRoot\src\Setup.ps1 -LogName $PSCommandPath

# 1. Récupérer tous les fichiers .ps1/.psm1 du dossier (récursif, exclut certains dossiers)
$files = Get-ChildItem -Path $FolderPath -Recurse -Include *.ps1, *.psm1 -ErrorAction SilentlyContinue |
Where-Object { $_.FullName -notlike "*\src\*" -and $_.FullName -notlike "*\examples\*" -and $_.FullName -notlike "*\lib\*" }

# 2. Charger le JSON existant s'il existe, sinon créer une liste vide
if (Test-Path $JsonFile) {
    $jsonContent = Get-Content $JsonFile -Raw | ConvertFrom-Json
    if ($jsonContent -isnot [System.Collections.IEnumerable] -or $jsonContent -is [string]) {
        $jsonContent = @($jsonContent)
    }
}
else {
    New-Item -Path $JsonFile -ItemType File -Force | Out-Null
    $jsonContent = @()
}

# 3. Créer un hashtable des fichiers existants pour vérification rapide
$existingFilesByName = @{}
foreach ($f in $files) {
    $existingFilesByName[$f.Name] = $true
}

# 4. SUPPRIMER les entrées pour les fichiers qui n'existent PLUS
$jsonContent = $jsonContent | Where-Object { $existingFilesByName.ContainsKey($_.Name) }

# 5. Indexer les entrées restantes par nom
$byName = @{}
foreach ($entry in $jsonContent) {
    $byName[$entry.Name] = $entry
}

# 6. AJOUTER les nouveaux fichiers avec status par défaut ✅ FIX ICI
$jsonContent = @()  # Recréer un tableau vide
foreach ($f in $files) {
    if ($byName.ContainsKey($f.Name)) {
        # Fichier existe déjà, le garder
        $jsonContent += $byName[$f.Name]
    }
    else {
        # Nouveau fichier
        $newEntry = [PSCustomObject]@{
            Name   = $f.Name
            Status = "?"
        }
        $jsonContent += $newEntry
    }
}

# 7. Sauvegarder le JSON nettoyé et mis à jour
$jsonContent | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 $JsonFile


do {
    Clear-Host
    Show-SectionHeader "Select a script to run"

    for ($i = 0; $i -lt $jsonContent.Count; $i++) {
        $currentEntry = $jsonContent[$i]
        $statusSymbol = switch ($currentEntry.Status.ToUpper()) {
            "✓" { "✓"; break } #OK
            "→" { "→"; break } # EN cours
            "✗" { "✗"; break } #A Faire
            default { "?" }
        }

        $statusColor = switch ($currentEntry.Status.ToUpper()) {
            "✓" { "Green" }
            "→" { "Yellow" }
            "✗" { "Red" }
            default { "Gray" }
        }

        Write-Host "[$($i+1)] $statusSymbol $($currentEntry.Name)" -ForegroundColor $statusColor
    }

    Write-Host ""
    Write-Host "[0] Exit" -ForegroundColor DarkGray
    Write-Host ""
    Write-Status INFO "Found $($jsonContent.Count) script(s) in $PSScriptRoot`n"




    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        "0" {
            Clear-Host
            return
        }
        default {
            if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $jsonContent.Count) {
                $index = [int]$choice - 1
                $selectedItem = $jsonContent[$index]

                Clear-Host
                Show-SectionHeader -Title "Running $($selectedItem.Name)"

                & "$FolderPath\$($selectedItem.Name)"
            }
            else {
                Write-Status ERROR "Invalid choice ! Please enter a number between 0 and $($jsonContent.Count)."
                Pause
            }
        }
    }
} until ($choice -eq "0")
$jsonContent += $newEntry
