# 🚀 Git Install

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%7C%207+-blue)
![License](https://img.shields.io/badge/License-MIT--Custom-green)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)
![Status](https://img.shields.io/badge/Status-Active-success)

---
Un module PowerShell complet pour rechercher, cloner et supprimer des dépôts Git sur Windows.

GitInstall est un module PowerShell conçu pour simplifier la gestion des dépôts Git sur Windows.
Il propose une interface claire, des outils de recherche avancés, un système de suppression sécurisé et une expérience utilisateur propre et guidée.

---

## ✨ Fonctionnalités

### 🔍 Recherche automatique de Git
- Vérifie si Git est installé
- Propose l’installation si nécessaire
- Détecte automatiquement l’emplacement de Git

### 📥 Clonage de dépôts
- Clone un dépôt Git à partir d’un utilisateur
- Vérifie la validité de l’utilisateur
- Crée automatiquement le dossier cible
- Affiche un retour clair et lisible

### 🗂️ Scan complet des disques pour trouver des dépôts Git
- Recherche **tous les dossiers `.git`** sur tous les disques
- Ignore automatiquement les dossiers système (Windows, Program Files, etc.)
- Affiche la liste complète des dépôts trouvés
- Numérotation automatique pour une meilleure lisibilité

### 🗑️ Suppression sécurisée de dépôts
- Demande confirmation pour chaque dépôt
- Affiche le numéro du dépôt dans la question
- Suppression récursive et silencieuse
- Messages de confirmation clairs

---

## 📦 Installation

Clone le repo :

```powershell
git clone https://github.com/1337phtm/GitInstall
```


## 📁 Structure du projet

```text
GitInstall/
│
├── src/
│   ├── GitInstall/
│   │   ├── searchgit.psm1
│   │   ├── clonerepo.psm1
│   │   └── removerepo.psm1
│
├── git.ps1
└── README.md
```text
