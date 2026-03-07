param(
    [Switch]$User,
    [switch]$Test
)

$Global:StatusCounters = @{
    SUCCESS = 0
    ERROR   = 0
    SKIP    = 0
    INFO    = 0
    TEST    = 0
    USER    = 0
}

function Write-Status {
    param(
        [ValidateSet("SUCCESS", "ERROR", "SKIP", "INFO", "TEST", "USER")]$Type,
        [string]$Message
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    $Global:StatusCounters[$Type]++
    switch ($Type) {
        "SUCCESS" { Write-Host " [$timestamp] ✓  $Message" -ForegroundColor Green }
        "ERROR" { Write-Host " [$timestamp] ✗ $Message" -ForegroundColor Red }
        "SKIP" { Write-Host " [$timestamp] - $Message" -ForegroundColor Yellow }
        "INFO" { Write-Host " [$timestamp] →  $Message" -ForegroundColor Cyan }
        "TEST" { Write-Host " [$timestamp] T  $Message" -ForegroundColor Magenta }
        "USER" { Write-Host " [$timestamp] U  $Message" -ForegroundColor White }
    }
}

function Show-SectionHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║ $Title" -ForegroundColor Blue
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Blue
    Write-Host ""
}

function Set-RegistryValueSafe {
    [CmdletBinding()]
    param(
        [string]$Path,
        [string]$Name,
        [Parameter(Mandatory = $true)]
        $Value,
        [string]$Description,
        [switch]$Experimental
    )

    if ($Path -like "HKLM:*" -and $User) {
        Write-Status USER "$Description ignorée (HKLM)"
        return
    }

    if ($Experimental -and $Test) {
        Write-Status TEST "$Description ignorée"
        return
    }

    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
            Write-Status INFO "Clé créée : $Path"
        }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -ErrorAction Stop
        Write-Status SUCCESS $Description

    }
    catch {
        if (-not (Test-Path $Path)) {
            Write-Status SKIP "Clé pour $Description absente"
        }
        else {
            $errorMsg = $_.Exception.Message
            Write-Status ERROR "$Description | $errorMsg"
        }
    }
}


#======================================================================
# Démarrage en admin :
#======================================================================

# ANTI-BOUCLE : Vérif fichier temporaire
$restartMarker = "$env:TEMP\$($MyInvocation.MyCommand.Name).restart"
if (Test-Path $restartMarker) {
    Remove-Item $restartMarker -Force
    # 2ème lancement → ON CONTINUE (admin OU user)
}
else {
    # 1er lancement
    if (-not $User) {
        # Sans -User → relance admin si besoin
        $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
            Write-Status INFO "Elevation requise. Relance en administrateur..."
            $allArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
            if ($Test) { $allArgs += " -Test" }
            New-Item $restartMarker -ItemType File | Out-Null
            Start-Process powershell.exe -ArgumentList $allArgs -Verb RunAs -WorkingDirectory $PSScriptRoot
            exit
        }
    }
    else {
        Write-Status INFO "[USER] Mode utilisateur → nouveau terminal..."
        $allArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -User"
        if ($Test) { $allArgs += " -Test" }
        New-Item $restartMarker -ItemType File | Out-Null
        Start-Process powershell.exe -ArgumentList $allArgs -WorkingDirectory $PSScriptRoot
        exit
    }
}

Clear-Host

if ($Test -and $User) {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║             POST - INSTALL           ║" -ForegroundColor Magenta
    Write-Host "║          ✎ USER TEST - MODE          ║" -ForegroundColor Magenta
    Write-Host "║          WRITTEN BY 1337phtm         ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""

}
elseif ($Test) {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║             POST - INSTALL           ║" -ForegroundColor Magenta
    Write-Host "║             ✎ TEST - MODE            ║" -ForegroundColor Magenta
    Write-Host "║          WRITTEN BY 1337phtm         ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
}
elseif ($User) {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║             POST - INSTALL           ║" -ForegroundColor Cyan
    Write-Host "║             ✎ USER - MODE            ║" -ForegroundColor Cyan
    Write-Host "║          WRITTEN BY 1337phtm         ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}
else {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║             POST - INSTALL           ║" -ForegroundColor Green
    Write-Host "║          WRITTEN BY 1337phtm         ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
}

#======================================================================
# Clé de Licence :
#======================================================================
Show-SectionHeader "🔑 GESTION DE LA LICENCE WINDOWS"

if (-not $User) {
    if (-not $Test) {
        if ((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").EditionID -eq "Professional") {
            Write-Status SUCCESS "Professional edition already installed"
        }
        else {
            $choice = Read-Host "Do you want to Upgrade your Windows to Pro ? (Y/N) "
            if ($choice -eq "Y" -or $choice -eq "y") {
                #slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX #Clé de mise à niveau vers Pro
                $lic = Get-WmiObject -Query "SELECT * FROM SoftwareLicensingProduct WHERE PartialProductKey IS NOT NULL"

                if ($lic.Description -match "OEM_DM") {
                    Write-Host "Migration automatique impossible, ouverture de l'interface..."
                    Write-Host "Clé de licence copié dans le presse-papier, cliquez sur modifier la clé de produit et copiez la clé"
                    Start-Process ms-settings:activation -WindowStyle Hidden
                    Set-Clipboard -Value "VK7JG-NPHTM-C97JM-9MPGT-3V66T"
                }
                else {
                    slmgr /ipk VK7JG-NPHTM-C97JM-9MPGT-3V66T #Clé de mise à niveau vers Pro
                    #dism /online /Set-Edition:Professional /ProductKey:VK7JG-NPHTM-C97JM-9MPGT-3V66T /AcceptEula


                    $EditionId = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").EditionID
                    if ($EditionId -ne "Professional") {
                        Set-RegistryValueSafe `
                            -Path "\HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" `
                            -Name EditionID `
                            -Value "Professional" `
                            -Description "Modif de l'Edition ID"
                    }

                    $ProductName = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName
                    if ($ProductName -ne "Windows 11 Pro") {
                        Set-RegistryValueSafe `
                            -Path "\HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" `
                            -Name ProductName `
                            -Value "Windows 11 Pro" `
                            -Description "Modif du ProductName"
                    }
                }
            }
            else {
                Write-Status INFO "Upgrade skipped`n"
            }
        }
    }
    else {
        if ((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").EditionID -eq "Professional") {
            Write-Status SUCCESS "Professional edition already installed"
        }
        else {
            Write-Status INFO "No Professional licence Installed"
            Write-Status TEST "Modification de licence ignorée"
        }
    }
}
else {
    Write-Status USER "Mode utilisateur, gestion de licence ignorée"
}

#======================================================================
# Alimentation :
#======================================================================
Show-SectionHeader "⚡ PARAMÈTRES D'ALIMENTATION"

if (-not $user) {
    if (-not $Test) {
        try {
            #Mise en veille prolongé :
            powercfg /hibernate on

            #Action qui suit la fermeture du capot :
            powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1 #Sur secteur AC | 0 = Rien | 1 = Veille | 2 = Hibernate | 3 = Arrêt
            powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 2 #Sur batterie DC | 0 = Rien | 1 = Veille | 2 = Hibernate | 3 = Arrêt
            Write-Status SUCCESS "Paramètres de fermeture du capot configurés"

            #Bouton Marche/Arrêt :
            powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS PBUTTONACTION 1 # 0 = Rien | 1 = Veille | 2 = Hibernate | 3 = Arrêt
            powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS PBUTTONACTION 2 # 0 = Rien | 1 = Veille | 2 = Hibernate | 3 = Arrêt
            Write-Status SUCCESS "Paramètres du bouton Marche/Arrêt configurés"

            #Bouton veille :
            powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1 # 0 = Rien | 1 = Veille | 2 = Hibernate | 3 = Arrêt
            powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 2 # 0 = Rien | 1 = Veille | 2 = Hibernate | 3 = Arrêt
            Write-Status SUCCESS "Paramètres du bouton veille configurés"

            # Activé le verrouillage auto après veille
            powercfg /setacvalueindex SCHEME_CURRENT SUB_NONE CONSOLELOCK 1 # 0 = Désactivé | 1 = Activé
            powercfg /setdcvalueindex SCHEME_CURRENT SUB_NONE CONSOLELOCK 1 # 0 = Désactivé | 1 = Activé
            Write-Status SUCCESS "Verrouillage automatique après veille activé"

            # Délai de mise en veille
            powercfg /change standby-timeout-ac 0 # 0 : never
            powercfg /change standby-timeout-dc 0 # 0 : never
            Write-Status SUCCESS "Paramètres de mise en veille configurés"

            # Délai d'extinction de l'écran
            powercfg /change monitor-timeout-ac 0 # 0 : never
            powercfg /change monitor-timeout-dc 0 # 0 : never
            Write-Status SUCCESS "Paramètres d'extinction de l'écran configurés"

            #Validation des paramètres :
            powercfg /setactive SCHEME_CURRENT
            Write-Status SUCCESS "Paramètres d'alimentation appliqués"
        }
        catch {
            Write-Status ERROR "Erreur lors de la modification des paramètres d'alimentation : $($_.Exception.Message)"
        }

    }
    else {
        Write-Status TEST "Modification des paramètres d'alimentation ignorée"
    }
}
else {
    Write-Status USER "Modification des paramètres d'alimentation ignorée"
}

#======================================================================
# Thèmes :
#======================================================================
Show-SectionHeader "🎨 THÈMES & APPARENCE"

# Mode sombre pour les apps | # 0 : Sombre (non) | 1 : Clair (oui)
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
    -Name AppsUseLightTheme `
    -Value 0 `
    -Description "Thème Apps"

# Mode Clair pour Windows | # 0 : Sombre (non) | 1 : Clair (oui)
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
    -Name SystemUsesLightTheme `
    -Value 0 `
    -Description "Thème Windows"

# Transparence | # 0 : Désactivé | 1 : Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
    -Name EnableTransparency `
    -Value 1 `
    -Description "Transparence"

# Son de démarrage | # 0 : Activé | 1 : Désactivé
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name DisableStartupSound `
    -Value 0 `
    -Description "Son de démarrage"

#Désactivé animations Windows (profil agressif)
#Set-RegistryValueSafe `
#    -Path "HKCU:\Control Panel\Desktop" `
#    -Name UserPreferencesMask `
#    -Value ([byte[]](0x90, 0x12, 0x03, 0x80, 0x10, 0x00, 0x00, 0x00)) `
#    -Experimental

#======================================================================
# BARRE DES TÂCHES :
#======================================================================
Show-SectionHeader "📋 BARRE DES TÂCHES"

# Alignement : | # 0 : Gauche | 1 : centre
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name TaskbarAl `
    -Value 1 `
    -Description "Alignement barre des tâches"

# Widgets (Win11) # 0 : Masqué | 1 : Affiché | 2 : Affiché + fct étendue
#Set-RegistryValueSafe `
#    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
#    -Name TaskbarDa `
#    -Value 0 `
#    -Description "Widgets de la barre des tâches"

# Recherche | # 0 : Masqué | 1 : Icône seule | 2 : Boîte de saisie
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" `
    -Name SearchboxTaskbarMode `
    -Value 0 `
    -Description "Icône de recherche"

# Task View | # 0 : Masqué | 1 : Affiché
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name ShowTaskViewButton `
    -Value 0 `
    -Description "Icône Task View"

# Afficher secondes dans l'horloge (Win11 23H2+) | # 0 = Non | 1 = Oui
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name ShowSecondsInSystemClock `
    -Value 1 `
    -Description "Secondes horloge système"

# Badges d'applis | # 0 : Désactivé | 1 : Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name TaskbarBadges `
    -Value 0 `
    -Description "Badges d'applications"

# Activer "Terminer la tâche" dans le menu contextuel de la barre des tâches (Win11 23H2+) | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" `
    -Name "TaskbarEndTask" `
    -Value 1 `
    -Description "Activer 'Terminer la tâche' dans la barre des tâches"


#======================================================================
# Explorateur de fichier :
#======================================================================
Show-SectionHeader "📁 EXPLORATEUR DE FICHIERS"

# Affichage des extensions de fichiers : | # 0 = Afficher | 1 = Masquer
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name HideFileExt `
    -Value 0 `
    -Description "Extensions de fichiers"

# Afficher fichiers cachés : | # 1 = Afficher | 2 = Masquer
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name Hidden `
    -Value 1 `
    -Description "Fichiers cachés"

# Afficher les fichiers système protégés (optionnel) <=> attrib -s -h | # 0 = Masquer | 1 = Afficher
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name ShowSuperHidden `
    -Value 0 `
    -Description "Fichiers système protégés"

# Ouvrir l'explorateur sur « Ce PC » au lieu de Accès rapide | # 1 = Ce PC | 2 = Accès rapide
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name LaunchTo `
    -Value 1 `
    -Description "Explorateur sur Ce PC"

# Accès rapide (fichiers récents) | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" `
    -Name ShowRecent `
    -Value 0 `
    -Description "Accès rapide - Fichiers récents"

#  Accès rapide (dossiers fréquents) | 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" `
    -Name ShowFrequent `
    -Value 0 `
    -Description "Accès rapide - Dossiers fréquents"

# Mode compact (Win11) | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name UseCompactMode `
    -Value 1 `
    -Description "Mode compact Explorateur"

# Case à cocher des éléments (Win11) | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name AutoCheckSelect `
    -Value 1 `
    -Description "Cases à cocher dans Explorateur"

# Activé l'historique du presse-papiers | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Clipboard" `
    -Name EnableClipboardHistory `
    -Value 1 `
    -Description "Historique presse-papiers"

# Activé les info-bulles (icones quand souris longtemps sur fichier) | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name ShowInfoTip `
    -Value 1 `
    -Description "Info-bulles sur fichiers"

# Ouvrir les dossiers dans le même processus | # 0 = Même processus | 1 = Processus séparé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name SeparateProcess `
    -Value 1 `
    -Description "Processus séparé"

# Miniatures (préaffichage sur l'icone genre pour les images) | # 0 = Miniatures | 1 = Icônes seulement
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name IconsOnly `
    -Value 0 `
    -Description "Miniatures au lieu d'icônes"

# Cache des miniatures | # 0 = Activé | 1 = Désactivé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name DisableThumbnailCache `
    -Value 1 `
    -Description "Cache miniatures"

# Afficher "Ce PC" sur le bureau | # 0 : Affiché | 1 : Masqué
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" `
    -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" `
    -Value 1 `
    -Description "Icône Ce PC sur bureau"

# Afficher l'option "Ouvrir l'invite de commande ici" dans le menu contextuel
#Set-RegistryValueSafe `
#    -Path "HKCU:\Software\Classes\Directory\Background\shell\cmd" `
#    -Name "Extended" `
#    -Value "" `
#    -Description "Ajout cmd ici dans le menu contextuel"

#======================================================================
# Menu Démarrer :
#======================================================================
Show-SectionHeader "🏠 MENU DÉMARRER"

Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name Start_ShowDocuments `
    -Value 1 `
    -Description "Documents dans le menu Démarrer" `
    -Experimental

Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name Start_ShowDownloads `
    -Value 1 `
    -Description "Downloads dans le menu Démarrer" `
    -Experimental

Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name Start_ShowSettings `
    -Value 1 `
    -Description "Paramètres dans Start" `
    -Experimental

Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name Start_ShowFileExplorer `
    -Value 1 `
    -Description "Bouton Explorateur dans Start" `
    -Experimental

Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name Start_ShowPictures `
    -Value 1 `
    -Description "Pictures dans le menu Démarrer" `
    -Experimental

Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name Start_ShowMusic `
    -Value 1 `
    -Description "Music dans le menu Démarrer" `
    -Experimental

Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name Start_ShowVideos `
    -Value 1 `
    -Description "Videos dans le menu Démarrer" `
    -Experimental

Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name Start_ShowHomegroup `
    -Value 1 `
    -Description "Téléchargements dans le menu Démarrer" `
    -Experimental

Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name Start_ShowControlPanel `
    -Value 1 `
    -Description "Téléchargements dans le menu Démarrer" `
    -Experimental


Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name Start_ShowNetwork `
    -Value 1 `
    -Description "Network dans le menu Démarrer" `
    -Experimental

Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name Start_ShowUser `
    -Value 1 `
    -Description "Téléchargements dans le menu Démarrer" `
    -Experimental

# Désactivé Bing dans la recherche : | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" `
    -Name BingSearchEnabled `
    -Value 0 `
    -Description "Bing dans la recherche Windows"

# Désactivé les recommandations dans Start : | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name Start_Recommendations `
    -Value 0 `
    -Description "Recommandations d'applications dans le menu Démarrer"

#======================================================================
# Confidentialité :
#======================================================================
Show-SectionHeader "🔒 CONFIDENTIALITÉ & TÉLÉMÉTRIE"

# Désactivé Cortana
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" `
    -Name AllowCortana `
    -Value 0 `
    -Description "Désactiver Cortana"

# Désactivé cortana : | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" `
    -Name CortanaConsent `
    -Value 0 `
    -Description "Consentement Cortana"

# Désactivé les suggestions dans le menu démarrer : | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name SystemPaneSuggestionsEnabled `
    -Value 0 `
    -Description "Suggestions menu Démarrer"

# Pubs dans l'explorateur Windows | # 0 = Pas de pubs | 1 = Pubs activées
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ShowSyncProviderNotifications" `
    -Value 0 `
    -Description "Notifications pubs Explorateur"

# Désactivé le suivi publicitaire | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" `
    -Name Enabled `
    -Value 0 `
    -Description "ID publicitaire"

# Désactivé les expériences partagées | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP" `
    -Name RomeSdkChannelUserAuthzPolicy `
    -Value 0 `
    -Description "Expériences partagées"

# Désactivé l’historique d’activité | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" `
    -Name TailoredExperiencesWithDiagnosticDataEnabled `
    -Value 0 `
    -Description "Historique d'activité personnalisé"

# Désactivé l’historique d’activité Windows | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" `
    -Name "EnableActivityFeed" `
    -Value 0 `
    -Description "Historique d'activité Windows"

# Désactivé la télémétrie (partiel) | # 0 = Désactivé | 1-4 = Niveaux diag
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
    -Name AllowTelemetry `
    -Value 0 `
    -Description "Télémétrie (niveau partiel)"

# Désactivé OneDrive (user) | # 0 = Activé | 1 = Désactivé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\OneDrive" `
    -Name DisablePersonalSync `
    -Value 1 `
    -Description "OneDrive pour le compte utilisateur"

# Désactivation OneDrive via Policies
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" `
    -Name DisableFileSyncNGSC `
    -Value 1 `
    -Description "Synchronisation OneDrive par stratégies"

# Masquer les suggestions Windows | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name SubscribedContent-338388Enabled `
    -Value 0 `
    -Description "Suggestions Windows"

# Suggestions de contenu (lockscreen, start, etc.) | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-338389Enabled" `
    -Value 0 `
    -Description "Suggestions de contenu"

# Désactivé les suggestions de contenu (lockscreen, etc.) | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name SubscribedContent-353694Enabled `
    -Value 0 `
    -Description "Suggestions de contenu"

# Désactivé les suggestions de contenu (lockscreen, etc.) | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name SubscribedContent-353696Enabled `
    -Value 0 `
    -Description "Suggestions de contenu"

# Désactivé l'historique de recherche locale : | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" `
    -Name IsDeviceSearchHistoryEnabled `
    -Value 0 `
    -Description "Historique de recherche locale"

# Désactiver l’historique d’activité (cloud) | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name PublishUserActivities `
    -Value 0 `
    -Description "Historique d'activité envoyé au cloud"

# Désactivé l’historique d’activité (cloud) | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System (Publish)" `
    -Name UploadUserActivities `
    -Value 0 `
    -Description "Upload de l'historique d'activité vers le cloud"

# Désactivé "Let Windows track apps launched" | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name Start_TrackProgs `
    -Value 0 `
    -Description "Suivi des applications lancées"

# Désactivé les suggestions d’apps dans Start | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name SilentInstalledAppsEnabled `
    -Value 0 `
    -Description "Suggestions d'applications silencieuses dans le menu Démarrer"

# 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" `
    -Name Value `
    -Value 0 `
    -Description "Partage des données Wi-Fi (Wi-Fi Sense - reporting)"

# Collecte des données d'utilisation des apps | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" `
    -Name "UserActivityTracking" `
    -Value 0 `
    -Description "Collecte des données d'utilisation des applications"

# Accès aux données de diagnostic user | # 0 = Bloqué | 1 = Autorisé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" `
    -Name "LetAppsAccessDiagnosticInfo" `
    -Value 0 `
    -Description "Bloquer l'accès des applications aux données de diagnostic utilisateur"

# Wifi sense | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" `
    -Name Value `
    -Value 0 `
    -Description "Connexion automatique aux points d'accès Wi-Fi Sense"

# Désactivé NCSI (sonde réseau vers Microsoft) | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet" `
    -Name EnableActiveProbing `
    -Value 0 `
    -Description "Sonde active NCSI (réseau)"

# Géolocalisation système | 0 : Activé | 1 : Désactivé
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" `
    -Name DisableLocation `
    -Value 1 `
    -Description "Géolocalisation système"

# Activé synchronisation presse-papiers (optionnel) | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\Clipboard" `
    -Name CloudClipboardEnabled `
    -Value 0 `
    -Description "Synchronisation cloud presse-papiers"

#======================================================================
# Sécurité :
#======================================================================
Show-SectionHeader "🛡️ SÉCURITÉ WINDOWS"

# Masquer le nom d’utilisateur à l’écran de login | # 0 = Afficher | 1 = Masquer
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name DontDisplayLastUserName `
    -Value 1 `
    -Description "Nom du dernier utilisateur à l'écran de connexion"

# Désactivé exécution automatique (USB/CD) | # 0x91 = Par défaut | 255 = Désactivé pour tous
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -Name NoDriveTypeAutoRun `
    -Value 255 `
    -Description "Exécution automatique (USB, CD, périphériques amovibles)" `
    -Experimental

# 0 = Désactivé | 1 = Activé | 2 = Audit
Set-RegistryValueSafe `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy" `
    -Name "VerifiedAndReputablePolicyState" `
    -Value 0 `
    -Description "Smart App Control"

# UAC au max (sécuritaire) | # 0 = Désactivé | 5 = Moyen | 2 = Max
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"  `
    -Name ConsentPromptBehaviorAdmin `
    -Value 2 `
    -Description "UAC au maximum (mot de passe obligatoire pour les admins)" `
    -Experimental

# UAC sur bureau sécurisé | # 0 = Désactivé | 1 = Sur bureau sécurisé (défaut)
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "PromptOnSecureDesktop" `
    -Value 1 `
    -Description "UAC sur bureau sécurisé" `
    -Experimental

# Ctrl+Alt+Suppr obligatoire | # 0 = Obligatoire | 1 = Non demandé
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name DisableCAD `
    -Value 0 `
    -Description "Ctrl+Alt+Suppr pour la connexion" `
    -Experimental

#======================================================================
# MàJ :
#======================================================================
Show-SectionHeader "⚙️ Paramètres"

<# MARCHE PAS POUR LE MOMENT
# Recevoir des mises à jour pour d'autres produits Microsoft | # 0 = Délai max | 0 = Immédiat
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" `
    -Name "DeferFeatureUpdatesPeriodInDays" `
    -Value 0 `
    -Description "MàJ immédiate autres produits Microsoft"

# Recevoir des mises à jour pour d'autres produits Microsoft | # 0 = Délai max | 0 = Immédiat
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" `
    -Name EnableFeaturedSoftware `
    -Value 1 `
    -Description "Activer Microsoft Update (autres produits Microsoft)"


# Canal rapide pour Office/365 | # 16=Décalé | 48=Immédiat
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" `
    -Name "BranchReadinessLevel" `
    -Value 48 `
    -Description "Canal Current Branch (Office via WU)"
#>

# Avertir lors d'un redémarrage nécessaire | # 0 = Ne pas avertir | 1 = Avertir
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" `
    -Name RestartNotificationsAllowed2 `
    -Value 1 `
    -Description "Avertir lors d'un redémarrage nécessaire"



#======================================================================
# Performances Gaming :
#======================================================================
Show-SectionHeader "🎮 PERFORMANCES GAMING"

# Désactivé GameDVR x2 | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\System\GameConfigStore" `
    -Name GameDVR_Enabled `
    -Value 0 `
    -Description "GameDVR (enregistrement de jeu)"

Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" `
    -Name AllowGameDVR `
    -Value 0 `
    -Description "GameDVR via stratégies (téléversement de clip de jeu)"

# Désactivé Xbox Game Bar x2 | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\GameBar" `
    -Name GameBarEnabled `
    -Value 0 `
    -Description "Xbox Game Bar"

Set-RegistryValueSafe `
    -Path "HKCU:\Software\Microsoft\GameBar" `
    -Name ShowStartupPanel `
    -Value 0 `
    -Description "Panneau de démarrage de Xbox Game Bar"

#======================================================================
# Usefull :
#======================================================================
Show-SectionHeader "✨ PETIT PLUS"

# 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" `
    -Name AllowDevelopmentWithoutDevLicense `
    -Value 1 `
    -Description "Mode développeur (installation d'applications sans licence)"

# Afficher les messages BSOD détaillés | # 0 = Simple | 1 = Détails
Set-RegistryValueSafe `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" `
    -Name DisplayParameters `
    -Value 1 `
    -Description "Détails complets des messages BSOD"


# Accélérer l'ouverture des menus (optionnel) | # 400 = Vitesse par défaut | 0 = Instantané
Set-RegistryValueSafe `
    -Path "HKCU:\Control Panel\Desktop" `
    -Name MenuShowDelay `
    -Value 0 `
    -Description "Vitesse d'ouverture des menus"

# Supprimer le délai de démarrage des applications | # 0 = Activé | 1 = Désactivé
Set-RegistryValueSafe `
    -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" `
    -Name WaitForIdleState `
    -Value 0 `
    -Description "Délai de démarrage des applications"

# Supprimer le délai de démarrage des applications | # 0 = Activé | 1 = Désactivé
Set-RegistryValueSafe `
    -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" `
    -Name StartupDelayInMSec `
    -Value 1 `
    -Description "Délai de démarrage des applications"

# Mode Verbose pour le système (affiche les détails au démarrage) | # 0 = Désactivé | 1 = Activé
Set-RegistryValueSafe `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name VerboseStatus `
    -Value 1 `
    -Description "Mode Verbose Système"


#======================================================================
# AppX :
#======================================================================
Show-SectionHeader "🗑️ SUPPRESSION DES BLOATWARES VIA APPX"

if (-not $User) {
    if (-not $Test) {
        # AppX classiques
        $AppxToRemove = @(
            "Microsoft.BingNews",
            "Microsoft.BingWeather",
            "Microsoft.GetHelp",
            "Microsoft.Getstarted",
            "Microsoft.MicrosoftOfficeHub",
            "Microsoft.MicrosoftSolitaireCollection",
            "Microsoft.MicrosoftStickyNotes",
            "Microsoft.OutlookForWindows",
            "Microsoft.PowerAutomateDesktop",
            "Microsoft.People",
            "Microsoft.SkypeApp",
            "Microsoft.Todos",
            "Microsoft.Xbox.TCUI",
            "Microsoft.XboxGameOverlay",
            "Microsoft.XboxGamingOverlay",
            "Microsoft.XboxIdentityProvider",
            "Microsoft.XboxSpeechToTextOverlay",
            "Microsoft.YourPhone",
            "Microsoft.ZuneMusic"
        )

        foreach ($app in $AppxToRemove) {

            $appx = Get-AppxPackage -Name $app -AllUsers | Select-Object -First 1
            if ($appx -and $appx.Status -eq "OK") {
                try {
                    Remove-AppxPackage -Package $appx.PackageFullName -AllUsers -ErrorAction Stop
                    Write-Status SUCCESS "App supprimée : $app"
                }
                catch {
                    Write-Status SKIP "Échec suppression $app : $($_.Exception.Message)"
                }

                # Provisionnés (séparé pour éviter double erreur)
                $prov = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $app }
                if ($prov) {
                    try {
                        $prov | Remove-AppxProvisionedPackage -Online -ErrorAction Stop
                        Write-Status SUCCESS "Provisionné supprimé : $app"
                    }
                    catch {
                        Write-Status SKIP "Provisionné non supprimé : $app"
                    }
                }
            }
            else {
                Write-Status SKIP "App non présente : $app"
            }
        }
    }
    else {
        Write-Status TEST "AppX ignoré"
    }
}
else {
    Write-Status USER "AppX ignoré"
}

#======================================================================
# Winget :
#======================================================================
Show-SectionHeader "🗑️ SUPPRESSSION DES BLOATWARES VIA WINGET"

# Apps modernes WinGet
$WingetApps = @(
    "Microsoft Teams",
    "Microsoft OneDrive",
    "Clipchamp",
    "Xbox"
)
if (-not $User) {
    if (-not $Test) {
        foreach ($pkg in $WingetApps) {

            winget uninstall --silent --accept-source-agreements $pkg | Out-Null
            $err = $LASTEXITCODE
            if ($err -eq 0) {
                Write-Status SUCCESS "$pkg désinstallé"
            }
            else {
                Write-Status SKIP "$pkg déjà désinstallé"
            }
        }
        # Désinstallation des widgets
        winget uninstall -e --id 9MSSGKG348SP --verbose | Out-Null
        $err = $LASTEXITCODE
        if ($err -eq 0) {
            Write-Status SUCCESS "Widget désinstallé"
        }
        elseif ($err -eq 0x80070002) {
            Write-Status ERROR "Échec de la désinstallation du Widget"
        }
        else {
            Write-Status SKIP "Widget déjà désinstallé ou non présent"
        }

        # Désinstallation des widgets2
        winget uninstall -e --id MSIX\Microsoft.WidgetsPlatformRuntime_1.6.14.0_x64__8wekyb3d8bbwe --verbose | Out-Null
        $err = $LASTEXITCODE
        if ($err -eq 0) {
            Write-Status SUCCESS "Widget2 désinstallé"
        }
        elseif ($err -eq 0x80070002) {
            Write-Status ERROR "Échec de la désinstallation du Widget2"
        }
        else {
            Write-Status SKIP "Widget2 déjà désinstallé ou non présent"
        }
    }
    else {
        Write-Status TEST "Winget ignoré"
    }
}
else {
    Write-Status USER "Winget ignoré"
}

#======================================================================
# Services :
#======================================================================

Show-SectionHeader "🔴 SERVICES"

# Télémétrie
if (-not $User) {
    Stop-Service -Name "DiagTrack" -Force
    Set-Service -Name "DiagTrack" -StartupType Disabled
    sc.exe failure "DiagTrack" reset= 0 actions= none/0/none/0/none/0 | Out-Null

    Stop-Service -Name "diagsvc" -Force
    Set-Service -Name "diagsvc" -StartupType Disabled
    sc.exe failure "diagsvc" reset= 0 actions= none/0/none/0/none/0 | Out-Null


    Stop-Service -Name "dmwappushservice" -Force
    Set-Service -Name "dmwappushservice" -StartupType Disabled
    sc.exe failure "dmwappushservice" reset= 0 actions= none/0/none/0/none/0 | Out-Null

    Stop-Service -Name "WerSvc" -Force
    Set-Service -Name "WerSvc" -StartupType Disabled
    sc.exe failure "WerSvc" reset= 0 actions= none/0/none/0/none/0 | Out-Null

    Write-Status SUCCESS "Services de télémétrie désactivée"
}
else {
    Write-Status USER "Services de télémétrie ignorés"
}

#======================================================================
# Tâches planifiées inutiles :
#======================================================================
Show-SectionHeader "⏱️ TÂCHES PLANIFIÉES"

$ScheduledTasksToDisable = @(
    "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "Microsoft\Windows\Autochk\Proxy",
    "Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
    "Microsoft\Windows\Feedback\Siuf\DmClient",
    "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload",
    "Microsoft\Windows\Windows Error Reporting\QueueReporting"
)

if (-not $User) {
    foreach ($task in $ScheduledTasksToDisable) {
        try {
            Disable-ScheduledTask -TaskName $task -ErrorAction Stop | Out-Null
            Write-Status SUCCESS "Tâche désactivée : $task"
        }
        catch {
            Write-Status SKIP "Impossible de désactiver : $task"
        }
    }
}
else {
    Write-Status USER "Tâches planifiées ignorées"
}


#======================================================================
# Nettoyage et redémarrage :
#======================================================================

Show-SectionHeader "🧹 NETTOYAGE"

if (Test-Path "C:\Windows.old") {
    Remove-Item "C:\Windows.old" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Status INFO "Windows.old supprimé"
}
else {
    Write-Status INFO "Windows.old non présent"
}

Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue #Win update cache #admin
Write-Status SUCCESS "Fichiers temporaires supprimés"

if (-not $Test) {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    gpupdate /force | Out-Null
    Write-Status SUCCESS "Services Redémarrés"
}
else {
    gpupdate /force | Out-Null
    Write-Host ""
    Write-Status TEST "Nettoyage Ignoré"
}

#======================================================================
# FINEX :
#======================================================================
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║               ✅ CONFIGURATION TERMINÉE              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════╝`n" -ForegroundColor Green

if ($StatusCounters.TEST -gt 0) {
    Write-Host "  [TEST] : $($StatusCounters.TEST) settings skipped" -ForegroundColor Magenta
}
if ($StatusCounters.USER -gt 0) {
    Write-Host "  [USER] : $($StatusCounters.USER) settings skipped" -ForegroundColor White
}
Write-Host ""
Write-Host "  ✓ SUCCESS : $($StatusCounters.SUCCESS)" -ForegroundColor Green
Write-Host "  - SKIP    : $($StatusCounters.SKIP)" -ForegroundColor Yellow
Write-Host "  → INFO    : $($StatusCounters.INFO)" -ForegroundColor Cyan
Write-Host "  ✗ ERROR   : $($StatusCounters.ERROR)" -ForegroundColor Red


if (-not $Test) {
    Write-Host ""
    Write-Host "🚨 REDÉMARRAGE REQUIS POUR APPLIQUER TOUTES LES MODIFICATIONS 🚨`n" -ForegroundColor Red
    $choice = Read-Host "Redémarrer maintenant ? (O/N)"
    if ($choice -match "^[oOyY]") {
        Write-Status INFO "Redémarrage dans 5 secondes..."
        Start-Sleep 5
        Restart-Computer -Force
    }
    else {
        Write-Host "`n⚠️  Redémarrez manuellement ultérieurement`n" -ForegroundColor Yellow
    }
}
else {
    Write-Host ""
    Write-Status TEST "Test terminé - Aucun redémarrage requis`n"
}

Write-Host "Appuyez sur Entrée pour quitter..." -ForegroundColor Gray
Read-Host



