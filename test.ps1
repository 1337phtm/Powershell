function Show-Menu {
    Clear-Host
    Write-Host "==============================="
    Write-Host "   MENU POWERHELL - UTILITAIRES"
    Write-Host "==============================="
    Write-Host "1. Infos système"
    Write-Host "2. Espace disque"
    Write-Host "3. Processus gourmands"
    Write-Host "4. Services arrêtés"
    Write-Host "5. Logiciels installés"
    Write-Host "6. Nettoyer les fichiers temporaires"
    Write-Host "7. Ouvrir un dossier utile"
    Write-Host "Q. Quitter"
    Write-Host ""
}

function Pause-Menu {
    Read-Host "Appuie sur Entrée pour continuer"
}

do {
    Show-Menu
    $choice = Read-Host "Ton choix"

    switch ($choice.ToUpper()) {
        "1" {
            Clear-Host
            Write-Host ""
            Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
            Write-Host "║           SYSTEM INFORMATION         ║" -ForegroundColor Cyan
            Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
            Write-Host ""

            $info = Get-ComputerInfo

            Write-Host " Windows Product Name : $($info.WindowsProductName)"
            Write-Host " Registered Owner     : $($info.WindowsRegisteredOwner)"
            Write-Host " HostName             : $($info.CsDNSHostName)"
            Write-Host " Memory               : $($info.CsPhyicallyInstalledMemory)"
            Write-Host " OS Name              : $($info.OsName)"
            Write-Host ""

            Write-Host " CPU Informations :" -ForegroundColor Yellow
            $info.CsProcessors |
                Select-Object Name,
                @{ Name = 'Cores'; Expression = { $_.NumberOfCores } },
                @{ Name = 'Threads'; Expression = { $_.NumberOfLogicalProcessors } },
                MaxClockSpeed,
                Manufacturer |
                    Format-Table -AutoSize


            Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
                Select-Object DeviceID,
                @{Name = "FreeGB"; Expression = { [math]::Round($_.FreeSpace / 1GB, 2) } },
                @{Name = "TotalGB"; Expression = { [math]::Round($_.Size / 1GB, 2) } } |
                    Format-Table -AutoSize
            Pause-Menu
        }
        "2" {
            Clear-Host
            Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
                Select-Object DeviceID,
                @{Name = "FreeGB"; Expression = { [math]::Round($_.FreeSpace / 1GB, 2) } },
                @{Name = "TotalGB"; Expression = { [math]::Round($_.Size / 1GB, 2) } } |
                    Format-Table -AutoSize
            Pause-Menu
        }
        "3" {
            Clear-Host
            Get-Process |
                Sort-Object CPU -Descending |
                    Select-Object -First 10 Name, Id, CPU, WorkingSet64 |
                        Format-Table -AutoSize
            Pause-Menu
        }
        "4" {
            Clear-Host
            Get-Service | Where-Object { $_.Status -eq "Stopped" } |
                Select-Object Name, DisplayName, Status |
                    Format-Table -AutoSize
            Pause-Menu
        }
        "5" {
            Clear-Host
            $paths = @(
                "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
                "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
            )
            Get-ItemProperty $paths |
                Where-Object { $_.DisplayName } |
                    Select-Object DisplayName, DisplayVersion, Publisher |
                        Sort-Object DisplayName |
                            Format-Table -AutoSize
            Pause-Menu
        }
        "6" {
            Clear-Host
            $temp = $env:TEMP
            Get-ChildItem $temp -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Nettoyage du dossier temp terminé."
            Pause-Menu
        }
        "7" {
            Start-Process explorer.exe "$env:USERPROFILE\Downloads"
        }
        "Q" {
            Write-Host "Fin du script."
        }
        default {
            Write-Host "Choix invalide."
            Start-Sleep 1
        }
    }
} while ($choice.ToUpper() -ne "Q")
