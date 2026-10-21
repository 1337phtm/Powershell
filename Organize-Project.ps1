Clear-Host
$name = Read-Host "Enter the name folder "
$folderPath = "$env:USERPROFILE\Desktop\Programming\Powershell\1.Git\$name"

#JSON - PWSH
$filePath = "$PSScriptroot\src\Crea-Project\powershell.json" #charge le json
$pwsh = Get-Content $filePath -Raw | ConvertFrom-Json

#JSON - HTML
#$filePath = "$PSScriptroot\src\projet\html.json" #charge
#$html = Get-Content $filePath -Raw | ConvertFrom-Json

if (Test-Path $folderPath) {
    Write-Host "❌ The folder $name already exists" -ForegroundColor Red
    Pause
    Clear-Host
    return
}

New-Item -Path $folderPath -Name "$name" -ItemType "Directory" *> $null

foreach ($item in $pwsh) {
    if ($item.category -eq "Folder") {
        New-Item -Path "$folderPath\$name" -Name "$($item.name)" -ItemType "Directory" *> $null
    }
    elseif ($item.category -eq "File") {
        New-Item -Path "$folderPath\$name" -Name "$($item.name)" -ItemType "File" *> $null
    }
}

Write-Host ""
Write-Host "Folder $name with dependences created successfully at $folderPath" -ForegroundColor Green
Write-Host ""
Pause
Clear-Host
