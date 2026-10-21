![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%7C%207+-blue)
![License](https://img.shields.io/badge/License-MIT--Custom-green)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)
![Status](https://img.shields.io/badge/Status-Active-success)

# 1.  Explanation :
    Ce repo est une collection de petits scripts PowerShell pratiques permettant d’automatiser des actions courantes sous Windows : Ouverture de page de connexion google, clonage de repo github etc.

    Ce dépôt sert de boîte à outils simple, rapide et modulaire pour gagner du temps dans les tâches quotidiennes.

## 📋 Prérequis
- Windows 10 / 11
- PowerShell **5.1** ou **7+**
- Les Autorisation pour exécuter des scripts :

~~~~powershell
   Get-ExecutionPolicy
   Set-ExecutionPolicy RemoteSigned CurrentUser
~~~~
# 2. 🧰 Architecture du projet

~~~~text
├── Convert-ImageFormat.ps1
├── gmail with fichier.ps1
├── gmail with pré-email.ps1
├── gui.ps1
├── guiusb.ps1
├── hide.ps1
├── Install-ssh.ps1
├── Main.ps1
├── Make-.exe.ps1
├── make-arbo.ps1
├── Make-arbo-USEFULL.ps1
├── New-QrCode.ps1
├── New-WifiQrCode.ps1
├── noguidtctusb.ps1
├── OldMain.ps1
├── Organize-Folder.ps1
├── Organize-Project.ps1
├── README.md
├── recupWindowsKey.ps1
├── scripts_status.json
├── Search file with ext.ps1
├── Search file.ps1
├── Setup.ps1
├── Show-BsodBestView.ps1
├── Show-Color.ps1
├── Show-FakeBsod.ps1
├── showlect.ps1
├── Show-Licence.ps1
├── snorlabel.ps1
├── Spot-Screen.ps1
├── Test.md
├── usefull1.ps1
├── usefull2.ps1
├── examples
│   └── QRCode
│       └── Uses.txt
├── lib
│   ├── git
│   │   ├── install git + everygit.psm1
│   │   ├── install git + WKT.psm1
│   │   └── install git.psm1
│   └── winconf
│       ├── Confidentiality.reg
│       ├── Explorer.reg
│       ├── Gaming.reg
│       ├── Security.reg
│       ├── Taskbar.reg
│       ├── themes.reg
│       └── Usefull.reg
├── maintenance
│   ├── afaire.ps1
│   ├── batteryreport.ps1
│   ├── PostInstall.ps1
│   ├── PostInstall.txt
│   └── repair.ps1
└── src
    ├── Crea-project
    │   ├── html.json
    │   └── Powershell.json
    ├── git
    │   ├── clonerepo.psm1
    │   ├── removerepo.psm1
    │   └── searchgit.psm1
    ├── gmail
    │   └── email.psm1
    └── usb
        └── usbsetup.psm1
~~~~

# 3. 🧰 Utilité
### Convert-ImageFormat.ps1
~~~~
OK | Convertit une image jpg, png, bmp, gif ou tiff uniquement en un des autre formats
~~~~
### gmail with fichier.ps1
~~~~
OK | Ouvre un nombre de page (nombre demandé) avec l'email pré-rempli (car demandé dans le terminal avant)
~~~~
### gmail with pré email.ps1
~~~~
OK | Ouvre un nombre de page avec l'email pré-rempli
    - Dépend de : src/gmail/email.psm1
~~~~
### guiusb.ps1
~~~~
ON WORK | détecte la présence de tous les périphériques externes enregistrer dans le script dans un GUI et permet l'éjection
    - Dépend de : src/usb/usbsetup.psm1
~~~~
###  hide.ps1
~~~~
OK | Hide file (fais devenir un fichier caché et système donc invisible à moins de modifier le registre)
~~~~
###  New-QrCode.ps1
~~~~
OK | Génère un QR Code avec l'output précisé (texte, lien, etc)
~~~~
###  New-WifiQrCode.ps1
~~~~
OK | Génère un Qr Code de connexion à un wifi dont l'appareil s'est déja connecté
~~~~
###  noguidtctusb.ps1
~~~~
OK | détecte la présence de tous les périphériques externes enregistrer dans le script et permet l'éjection
~~~~
###  Organize-Folder.ps1
~~~~
OK | Trie les fichiers présents dans le dossier précisé (Images, Documents...)
~~~~
###  Organize-Project.ps1
~~~~
OK | Crée un folder avec tous les dossiers précisé dans les json pour faire une archi de projet rapide
    - Dépend de  : src/Crea-Project/*
~~~~
###  recupWindowsKey.ps1
~~~~
ON WORK | Récupère la clé Windows et potentiellement la modifie (pour mettre à jour vers pro)
~~~~
###  Search file with ext.ps1
~~~~
ON WORK/OK | Recherche tous les fichier avec l'extension demandé
~~~~
###  Search file.ps1
~~~~
ON WORK/OK | Recherche un fichier demandé (juste avec le nom)
~~~~
###  Show-BSODBestView.ps1
~~~~
ON WORK | fake BSOD
~~~~
###  Show-FakeBSOD.ps1
~~~~
ON WORK | fake BSOD
~~~~
###  showlect.ps1
~~~~
OK | Affiche tous les lecteurs présents
~~~~
###  snorlabel.ps1
~~~~
ON WORK/OK | Récupère soit le sn soit le label du périphérique externe
~~~~
### Spot-Screen
~~~~
ON WORK | spot applis dans screen
~~~~
###  Usefull1.ps1
~~~~
DATA BASE | Synthèse vocal et beep
~~~~
###  Usefull2.ps1
~~~~
DATA BASE | ping mais sans ping, and every color of powershell
~~~~
###  winconf.ps1
~~~~
ON WORK/OK | Configure Windows/Post-
    - Dépend de  : src/winconfmod.ps1
~~~~
### README.md
~~~~
OK | README.md you know
~~~~


# 4. 🧰 Info
## Colors :
~~~~text
Blue : HEADER
Green : SUCCESS
Red : ERROR
Yellow : SKIP
Cyan : INFO
Magenta : TEST
DarkGray : EXIT

