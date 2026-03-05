. $PSScriptRoot\Setup.ps1

$item = Get-ChildItem -Path $PSScriptRoot\* -Recurse -Include *.ps1, *.psm1 -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notlike "*\src\*" -and $_.FullName -notlike "*\examples\*" -and $_.FullName -notlike "*\lib\*" }

Clear-Host
Show-SectionHeader "Select a script to run"

for ($i = 0; $i -lt $item.Count; $i++) {
    Write-Host "[$($i+1)] $($item[$i].Name)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[0] Exit" -ForegroundColor DarkGray
Write-Host ""
Write-Status INFO "Found $($item.Count) script(s) in $PSScriptRoot`n"

$choice = Read-Host "Enter your choice"

switch ($choice.ToUpper()) {
    "0" {
        Clear-Host
        return
    }

    default {
        # Convertit le choix en index (1 → 0, 2 → 1, etc.)
        $index = [int]$choice - 1

        if ($index -ge 0 -and $index -lt $item.Count) {
            $selectedItem = $item[$index]
            Clear-Host
            Write-Host ""
            Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Blue
            Write-Host "║ You selected file : $($selectedItem.Name)" -ForegroundColor Blue
            Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Blue
            Write-Host ""

            # Exécute le fichier sélectionné
            . $selectedItem.FullName
        }
    }
}


<#
FAIRE script qui crée un JSON avec tous les fcihiers présents dans le dossier et .append les nouveaux fichgier a l'éxecution du
script et dans json faire name : test.ps1, Status : OK, ON-Work, A faire... et affiche une coiuleur differente en fonction du status comme ça
je sais lequel modifier/continuer mais propose quand meme l'execution juste affiche tous ceux présent avec leur status genre TEST.ps1 --- OK (vert),
 TEST2.ps1 --- ON-WORK (jaune), TEST3.ps1 --- A FAIRE (rouge) et à la fin de l'execution du script propose de changer
 le status du script executé en OK, ON-WORK, A FAIRE
#>
