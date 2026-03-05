[Enum]::GetValues([ConsoleColor]) | ForEach-Object {
    Write-Host $_ -ForegroundColor $_
}
