
# ============================
#   WindowsToolkit - Setup
#   Auteur : 1337phtm
# ============================


# ============================
# Fonctions de configuration et de log
# ============================
#======================================================================
# Fonction debug | use with .\main.ps1 -DebugMode
#======================================================================
param(
    [switch]$DebugMode
)

$Global:DebugMode = $DebugMode.IsPresent

if ($Global:DebugMode) {
    $Global:VerbosePreference = "Continue"
    $Global:DebugPreference = "Continue"
}
else {
    $Global:VerbosePreference = "SilentlyContinue"
    $Global:DebugPreference = "SilentlyContinue"
}

$Global:ErrorActionPreference = "Stop"

# --- Dossiers ---
$Global:WTKRoot = Join-Path $env:LOCALAPPDATA "WindowsToolkit"
$Global:LogDir = Join-Path $Global:WTKRoot "Logs"

foreach ($dir in @($Global:WTKRoot, $Global:LogDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
}

# --- Fichiers de log ---
$Global:LogFile = Join-Path $Global:LogDir "WindowsToolkit.log"
$Global:ErrorLogFile = Join-Path $Global:LogDir "WindowsToolkit.error.log"

foreach ($file in @($Global:LogFile, $Global:ErrorLogFile)) {
    if (-not (Test-Path $file)) {
        New-Item -ItemType File -Path $file | Out-Null
    }
}

# --- Fonction de log ---
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $line = "[$timestamp] [$Level] $Message"

    Add-Content -Path $Global:LogFile -Value $line
}

# --- Rotation avancée de logs (3 fichiers max) ---
function Get-Logs {
    param(
        [string]$FilePath
    )

    for ($i = 3; $i -ge 1; $i--) {
        $old = "$FilePath.$i"
        $new = "$FilePath." + ($i + 1)

        if (Test-Path $old) {
            if ($i -eq 3) {
                Remove-Item $old -Force
            }
            else {
                Rename-Item $old $new -Force
            }
        }
    }

    if (Test-Path $FilePath) {
        Rename-Item $FilePath "$FilePath.1" -Force
        New-Item -ItemType File -Path $FilePath | Out-Null
    }
}

# --- Compteur d'exécutions ---
function Start-Log {

    $RunCountFile = Join-Path $Global:LogDir "run.count"
    if (-not (Test-Path $RunCountFile)) {
        "0" | Out-File $RunCountFile -Encoding UTF8
    }

    #Essaye de décoder le contenu du fichier sinon réinitialise à 0
    try {
        $RunCount = Get-Content $RunCountFile |
        Where-Object { $_.Trim() -ne "" } |
        Select-Object -First 1

        $RunCount = [int]$RunCount
    }
    catch {
        # Si le fichier est corrompu → on repart à zéro
        $RunCount = 0
        "0" | Out-File $RunCountFile -Encoding UTF8
        Write-ErrorLog -Source "Setup | Start-Log" -Message "run.count corrupted, reset to 0." -Silent
    }

    $RunCount++
    $RunCount | Out-File $RunCountFile -Encoding UTF8

    if ($RunCount -gt 150) {
        Get-Logs -FilePath $Global:LogFile
        Get-Logs -FilePath $Global:ErrorLogFile
        "0" | Out-File $RunCountFile -Encoding UTF8
    }
}

#======================================================================
# Gestion d'erreurs
#======================================================================

function Write-ErrorLog {
    param(
        [string]$Source,
        [string]$Message,
        [switch]$Silent
    )

    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $line = "[$timestamp] [ERROR] [$Source] $Message"

    # Log normal
    Add-Content -Path $Global:LogFile -Value $line

    # Log des erreurs
    Add-Content -Path $Global:ErrorLogFile -Value $line

    # Message propre pour l'utilisateur (si pas Silent)
    if (-not $Silent) {
        Write-Host "❌ Une erreur est survenue dans $Source. Consultez error.log pour plus de détails." -ForegroundColor Red
    }
}



#======================================================================
# Fonctions d'affichage
#======================================================================

function Stop-Screen {
    Write-Host ""
    Read-Host "Press Enter to continue..."
}


#======================================================================
# Export
#======================================================================

Export-ModuleMember -Function Write-Log, Start-Log, Stop-Screen, Write-ErrorLog
