$edition = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").EditionID
$biosKey = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
$regKey = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform").BackupProductKeyDefault

Write-Host "Édition installée : $edition"
Write-Host "Clé OEM BIOS : $biosKey"
Write-Host "Clé du registre : $regKey"

Write-Host "`nType de licence :"
slmgr /dli
