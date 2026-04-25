$Path = $PSScriptRoot
$OutputFile = "arbo.md"
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

        # Ligne actuelle
        "$Prefix$connector$item"

        # Si dossier → récursion
        if ($item.PSIsContainer) {
            Get-Tree -BasePath $item.FullName -Prefix ($Prefix + $nextPrefix)
        }
    }
}

# Génération de l'arborescence
$tree = (Get-Tree -BasePath $Path) -join "`n"

# Construction du README
$content = @"
# Arborescence du projet

~~~~text
$tree
~~~~
"@

Set-Content -Path $OutputFile -Value $content -Encoding UTF8

Write-Host "$($OutputFile) généré avec succès."
