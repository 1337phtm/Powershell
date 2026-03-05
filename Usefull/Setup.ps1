$Global:StatusCounters = @{
    SUCCESS = 0
    ERROR   = 0
    SKIP    = 0
    INFO    = 0
}

#$Global:LogFile = $null

function Show-SectionHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║ $Title" -ForegroundColor Blue
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Blue
    Write-Host ""
}



function Write-Status {
    param(
        [ValidateSet("SUCCESS", "ERROR", "SKIP", "INFO"<#, "TEST"#>)]$Type,
        [string]$Message
    )

    $timestamp = Get-Date -Format "HH:mm:ss"
    $Global:StatusCounters[$Type]++

    # AFFICHAGE CONSOLE (inchangé)
    switch ($Type) {
        "SUCCESS" { Write-Host " [$timestamp] ✓  $Message" -ForegroundColor Green }
        "ERROR" { Write-Host " [$timestamp] ✗ $Message" -ForegroundColor Red }
        "SKIP" { Write-Host " [$timestamp] - $Message" -ForegroundColor Yellow }
        "INFO" { Write-Host " [$timestamp] → $Message" -ForegroundColor Cyan }
        #"TEST" { Write-Host " [$timestamp] ✎ [TEST] $Message" -ForegroundColor Magenta }
    }

    # LOG AUTOMATIQUE (NOUVEAU)
    #if ($Global:LogFile) {
    #    $logEntry = "[$timestamp] [$Type] $Message"
    #    Add-Content -Path $Global:LogFile -Value $logEntry -Force
    #}
}

function Show-Counters {
    Write-Host ""
    Show-SectionHeader "Execution Summary"
    Write-Host "  ✓ SUCCESS : $($Global:StatusCounters.SUCCESS)" -ForegroundColor Green
    Write-Host "  ✗ ERROR   : $($Global:StatusCounters.ERROR)" -ForegroundColor Red
    Write-Host "  - SKIP    : $($Global:StatusCounters.SKIP)" -ForegroundColor Yellow
    Write-Host "  → INFO    : $($Global:StatusCounters.INFO)" -ForegroundColor Cyan
    #if ($Global:LogFile) {
    #    Write-Host "  📝 Log    : $Global:LogFile" -ForegroundColor Gray
    #}
}

#LOG :

#function Get-CurrentScriptName {
#if ($MyInvocation.ScriptName -and $MyInvocation.ScriptName -ne '.') {
#    return [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.ScriptName)
#}
#if ($PSCommandPath) {
#    return [System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath)
#}
#}

#function New-LogSetup {
# Crée dossier Logs + définit fichier avec nom script

#$ScriptBaseName = Get-CurrentScriptName
#$LogDir = "$env:TEMP\Powershell\Logs"
#New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
#$Global:LogFile = "$LogDir\$ScriptBaseName-$(Get-Date -Format 'yyyyMMdd').log"
#
#Write-Host "📝 Logs → $Global:LogFile" -ForegroundColor Cyan
#}


# INITIALISATION AUTO (optionnel)
#New-LogSetup
#
#Get-CurrentScriptName
