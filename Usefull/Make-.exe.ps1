if (-not (Get-Command "ps2exe" -ErrorAction SilentlyContinue)) {
    Write-Host "🔄 ps2exe introuvable → Installation..." -ForegroundColor Yellow

    Install-Module ps2exe -Scope CurrentUser -Force

    Import-Module ps2exe
    if (Get-Command "ps2exe" -ErrorAction SilentlyContinue) {
        Write-Host "✅ ps2exe installé et prêt !" -ForegroundColor Green
    }
    else {
        Write-Error "❌ Échec installation ps2exe"
        exit 1
    }
}

$app = Read-Host "Enter file to make .exe"

$extension = [IO.Path]::GetExtension($app)

if ($extension -in @(".exe", ".tmp", ".log", ".txt")) {
    Write-Host "❌ Type de fichier interdit : $extension" -ForegroundColor Red
}

Invoke-PS2EXE $app "$($app).exe"
