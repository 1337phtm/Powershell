param(
    [Parameter(Mandatory)]
    [string]$ReadmeFile = "README.md",
    [string[]]$TreeSectionMarkers = @("# 2. 🧰 Architecture du projet", "~~~~text")
)

$Path = $PSScriptRoot

function Get-Tree {
    param(
        [string]$BasePath,
        [string]$Prefix = ""
    )

    $items = Get-ChildItem -LiteralPath $BasePath | Sort-Object PSIsContainer, Name

    for ($i = 0; $i -lt $items.Count; $i++) {
        $item = $items[$i]
        $isLast = ($i -eq $items.Count - 1)

        $connector = if ($isLast) { "└── " } else { "├── " }
        $nextPrefix = if ($isLast) { "    " } else { "│   " }

        "$Prefix$connector$item"

        if ($item.PSIsContainer) {
            Get-Tree -BasePath $item.FullName -Prefix ($Prefix + $nextPrefix)
        }
    }
}

# --- Génération de l'arborescence ---
$tree = (Get-Tree -BasePath $Path) -join "`n"

# --- Lire le README existant ---
if (-not (Test-Path $ReadmeFile)) {
    Write-Error "README.md n'existe pas !"
    exit 1
}

$content = Get-Content $ReadmeFile -Raw -Encoding UTF8

# --- Trouver les marqueurs de la section arborescence ---
$startMarker = $TreeSectionMarkers[0]
$endMarker = $TreeSectionMarkers[1]

if ($content -notmatch [regex]::Escape($startMarker) -or $content -notmatch [regex]::Escape($endMarker)) {
    Write-Warning "Marqueurs de section non trouvés. Création d'une nouvelle section."
    $newSection = @"

## 📋 Architecture du projet
~~~~text
$tree
~~~~
"@
    $content += $newSection
}
else {
    # --- Remplacer la section existante ---
    $sectionPattern = [regex]::Escape($startMarker) + ".*?" + [regex]::Escape($endMarker)
    $newSection = @"
$startMarker

~~~~text
$tree
~~~~
"@

    $content = [regex]::Replace($content, $sectionPattern, $newSection, [System.Text.RegularExpressions.RegexOptions]::Singleline)
}

# --- Sauvegarder le README mis à jour ---
Set-Content -Path $ReadmeFile -Value $content -Encoding UTF8

Write-Host "✅ $ReadmeFile mis à jour avec la nouvelle arborescence !" -ForegroundColor Green
Write-Host "📁 Arborescence générée : $tree" -ForegroundColor Cyan
