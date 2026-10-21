function DISM {
    Write-Host ""
    Write-Host "Launching DISM /Online /Cleanup-Image /RestoreHealth..." -ForegroundColor Yellow
    Write-Host ""
    try {
        Start-Process -FilePath "dism.exe" -ArgumentList "/Online", "/Cleanup-Image", "/RestoreHealth" -Verb RunAs -Wait
        if ($LASTEXITCODE -ne 0) {
            throw "DISM failed with exit code $LASTEXITCODE"
        }
    }
    catch {
        Pause
        return
    }
    Write-Host ""
    Write-Host "DISM completed." -ForegroundColor Green
    Pause
}

function SFC {
    Write-Host ""
    Write-Host "Launching SFC /scannow..." -ForegroundColor Yellow
    Write-Host ""
    try {
        Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -Verb RunAs -Wait
        if ($LASTEXITCODE -ne 0) {
            throw "SFC failed with exit code $LASTEXITCODE"
        }
    }
    catch {
        Pause
        return
    }
    Write-Host ""
    Write-Host "SFC completed." -ForegroundColor Green
    Pause
}

Clear-Host
. "$PSScriptRoot\batteryreport.ps1"
DISM
SFC
