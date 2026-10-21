# Dossier à ranger
$Path = Read-Host "Entrez le chemin du dossier à trier "

# Catégories et extensions
$Categories = @{
    "Images"    = @(".png", ".jpg", ".jpeg", ".gif", ".bmp")
    "Scripts"   = @(".ps1", ".psm1")
    "Archives"  = @(".zip", ".rar", ".7z")
    "Documents" = @(".txt", ".pdf", ".docx", ".xlsx", ".pptx", ".docx", ".odp", ".ods", ".odt", ".odg")
    "JSON"      = @(".json")
    "Autres"    = @()   # sera géré automatiquement
}

# Récupérer uniquement les fichiers du dossier racine
$Files = Get-ChildItem -Path $Path -File | Where-Object {
    $_.DirectoryName -eq $Path
}

# Liste plate de toutes les extensions connues (sauf Autres)
$KnownExtensions = $Categories.GetEnumerator() |
Where-Object { $_.Key -ne "Autres" } |
ForEach-Object { $_.Value } |
ForEach-Object { $_.ToLower() }

foreach ($Category in $Categories.Keys) {

    $Exts = $Categories[$Category]

    if ($Category -eq "Autres") {
        # Fichiers dont l'extension n'est dans aucune catégorie
        $MatchedFiles = $Files | Where-Object {
            $_.Extension.ToLower() -notin $KnownExtensions
        }
    }
    else {
        $MatchedFiles = $Files | Where-Object {
            $_.Extension.ToLower() -in $Exts
        }
    }

    # Si aucun fichier → on ne crée pas le dossier
    if ($MatchedFiles.Count -eq 0) {
        continue
    }

    # Créer le dossier si nécessaire
    $TargetFolder = Join-Path $Path $Category
    if (-not (Test-Path $TargetFolder)) {
        New-Item -ItemType Directory -Path $TargetFolder | Out-Null
    }

    # Déplacer les fichiers
    foreach ($File in $MatchedFiles) {
        Move-Item -Path $File.FullName -Destination $TargetFolder -Force
    }
}

Write-Host "Tri terminé proprement !"
