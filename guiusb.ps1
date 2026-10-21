Import-Module ".\src\usb\usbsetup.psm1" -Force
Clear-Host

# TABLE DES CLÉS
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




# CONSTRUCTION LISTE
function Global:BuildUsbList {
    $Global:usbDisks = Get-Disk   | Where-Object { $_.BusType -eq 'USB' }
    $Global:usbVols = Get-Volume | Where-Object { $_.DriveType -eq 'Removable' }

    #Affichage
    foreach ($entry in $TargetSerial) {
        $sn = $entry.Serial
        $label = $entry.Label
        $name = $entry.Name

        $device = $null
        $vol = $null

        if ($sn) {
            $device = $Global:usbDisks | Where-Object { $_.SerialNumber -eq $sn }
        }
        if (-not $device -and $label) {
            $vol = $Global:usbVols | Where-Object { $_.FileSystemLabel -eq $label }
            if ($vol) {
                $part = Get-Partition | Where-Object { $_.DriveLetter -eq $vol.DriveLetter }
                $device = $Global:usbDisks | Where-Object { $_.Number -eq $part.DiskNumber }
            }
        }

        if ($device) {
            $part = Get-Partition | Where-Object { $_.DiskNumber -eq $device.Number }
            $vol = $Global:usbVols | Where-Object { $_.DriveLetter -eq $part.DriveLetter }

            [PSCustomObject]@{
                Name         = $name
                IdDisplay    = if ($sn) { "Serial : $sn" } else { "Label : $label" }
                DriveLetter  = $vol.DriveLetter
                DriveDisplay = "Drive : $($vol.DriveLetter):"
                Status       = "Connected"
                StatusColor  = "LightGreen"
                CanEject     = $true
            }
        }
        else {
            [PSCustomObject]@{
                Name         = $name
                IdDisplay    = if ($sn) { "Serial : $sn" } else { "Label : $label" }
                DriveLetter  = $null
                DriveDisplay = "Not mounted"
                Status       = "Not detected"
                StatusColor  = "OrangeRed"
                CanEject     = $false
            }
        }
    }
}

# ÉJECTION
function Global:Invoke-UsbEject {
    param([string]$DriveLetter)

    if (-not $DriveLetter) { return }

    $drive = "$($DriveLetter):\"
    $shell = New-Object -ComObject Shell.Application
    $folder = $shell.Namespace(17)

    foreach ($item in $folder.Items()) {
        if ($item.Path -eq $drive) {
            $item.InvokeVerb("Eject")
            return
        }
    }
}


# CALLBACKS
$RefreshCallback = {
    BuildUsbList
}

$EjectCallback = {
    param($letter)

    if ($letter) {
        Invoke-UsbEject -DriveLetter $letter
    }
    else {
        $list = BuildUsbList
        foreach ($usb in $list) {
            if ($usb.CanEject) {
                Invoke-UsbEject -DriveLetter $usb.DriveLetter
            }
        }
    }
}

# LANCEMENT UI

Show-UsbWindow -Items (BuildUsbList) -RefreshCallback $RefreshCallback -EjectCallback $EjectCallback
