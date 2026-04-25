Clear-Host

# Tableau avec Serial + Label + Nom personnalisé
$TargetSerial = @(
    @{ Serial = "057D09C52080"; Name = "Clé 1 - Sam le pirate" }
    @{ Serial = "4C530399900717110192"; Name = "Clé 2 - SANDISK" }
    @{ Serial = "03018826012622135933"; Name = "Clé 3 - SANDISK" }
    @{ Label = "CLE4"; Name = "Clé 4 - Verte" }
    @{ Label = "CLE5"; Name = "Clé 5 - Jaune" }
    @{ Label = "CLE6"; Name = "Clé 6 - Orange" }
    @{ Label = "CLE8"; Name = "Clé 8 - Rose" }
    @{ Label = "CLEX"; Name = "" }
    @{ Label = "CLE9"; Name = "Clé 9 - Violet" }
    @{ Label = "CLE10"; Name = "Clé 10 - Noir" }
    @{ Label = "CLE11"; Name = "Clé 11 - Grise" }
    @{ Label = "CLE12" ; Name = "Clé 12 - Blanche" }
    @{ Serial = "AA00000000000489"; Name = "Clé 13 - Tesla" }
    @{ Serial = "372710504A479E6304869"; Name = "Clé 14 - Dark Vador" }
    @{ Serial = "372701377C24885516272"; Name = "Clé 15 - Grogu" }
    @{ Serial = "00015016041925164552"; Name = "Clé 16 - Save" }
    @{ Serial = "00014715041925162437"; Name = "Clé 17 - VENTOY" }
    @{ Serial = "A4ORA52700225B"; Name = "PADLOCK - CORSAIR" }
)

function Get-EjectUsbShell {
    param([string]$DriveLetter)

    $drive = "$($DriveLetter):\"
    $shell = New-Object -ComObject Shell.Application
    $folder = $shell.Namespace(17)  # Poste de travail

    foreach ($item in $folder.Items()) {
        if ($item.Path -eq $drive) {
            $item.InvokeVerb("Eject")
            Write-Host ""
            Write-Host "USB drive $drive ejected via Shell." -ForegroundColor Green
            Write-Host ""
            return
        }
    }

    Write-Host "Drive $drive not found in Shell namespace." -ForegroundColor Red
}

function Read-HostColor {
    param(
        [string]$Prompt,
        [string]$Color
    )
    Write-Host -NoNewline $Prompt -ForegroundColor $Color
    return Read-Host
}



# Récupère tous les disques USB
$usbSN = Get-Disk | Where-Object { $_.BusType -eq 'USB' } #via SerialNumber
$usblabel = Get-Volume | Where-Object { $_.DriveType -eq 'Removable' } #via Label

foreach ($entry in $TargetSerial) {
    function Get-EjectInforeach {
        foreach ($v in $vols) {
            $drive = $v.DriveLetter
            if ($drive) {
                Get-EjectUsbShell -DriveLetter $drive
            }
            else {
                Write-Host "Cannot eject $name : no DriveLetter found." -ForegroundColor Yellow
            }
        }
    }
    $SN = $entry.Serial
    $label = $entry.Label
    $name = $entry.Name
    $DeviceSNorLabel = $null

    # 1) Détection par SerialNumber
    if ($SN) {
        $DeviceSNorLabel = $usbSN | Where-Object { $_.SerialNumber -eq $SN }
    }

    # 2) Détection par Label
    if (-not $DeviceSNorLabel -and $label) {
        $label = $usblabel | Where-Object { $_.FileSystemLabel -eq $label }
        if ($label) {
            # Trouver la partition associée
            $partition = Get-Partition | Where-Object { $_.DriveLetter -eq $label.DriveLetter }

            # Trouver le disque associé
            $DeviceSNorLabel = Get-Disk | Where-Object { $_.Number -eq $partition.DiskNumber }
        }
    }

    if ($DeviceSNorLabel) {
        # Trouver les partitions du disque
        $partitions = Get-Partition | Where-Object { $_.DiskNumber -eq $DeviceSNorLabel.Number }

        # Trouver les volumes associés
        $vols = foreach ($p in $partitions) {
            Get-Volume -Partition $p
        }

        Write-Host "╔═════════════════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║   USB detected : $name                   " -ForegroundColor Green
        Write-Host "╚═════════════════════════════════════════════════════════════╝" -ForegroundColor Green
        Write-Host ""
        Write-Host "Disk Number : $($DeviceSNorLabel.Number)"
        Write-Host "Letter : $($vols.DriveLetter):\"
        Write-Host "Custom Name   : $name"
        Write-Host ""

        $choice = Read-HostColor -Prompt "Do you want to eject USB drive ? (Y/N) " -Color Yellow
        if ($choice.ToUpper() -eq "Y") {
            Get-EjectInforeach
        }
        else {
            Write-Host ""
            continue

        }



    }
    if (-not $DeviceSNorLabel) {
        #-or ) {
        Write-Host "╔═════════════════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "║   No USB key has been detected for : $name !   "  -ForegroundColor Red
        Write-Host "╚═════════════════════════════════════════════════════════════╝" -ForegroundColor Red
        Write-Host ""
    }
}

Pause
Clear-Host
