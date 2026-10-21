#Get-PnpDevice -Class DiskDrive | Where-Object { $_.FriendlyName -match "USB" } | Select-Object Status, Name, InstanceId

#For USB with SN
Get-Disk | Select-Object Number, BusType, SerialNumber


#For USB with Label
Get-Volume | Where-Object { $_.DriveType -eq 'Removable' } | Select-Object DriveLetter, FileSystemLabel, SizeRemaining, Size
