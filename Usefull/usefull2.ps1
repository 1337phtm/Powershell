Test-Connection -ComputerName 192.168.1.1 -Count 4


[Enum]::GetValues([System.ConsoleColor]) | ForEach-Object {
    Write-Host $_ -ForegroundColor $_
}
Write-Host ""
Pause
