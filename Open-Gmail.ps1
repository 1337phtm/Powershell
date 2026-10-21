Clear-Host

# Combien d'adresses Gmail ouvrir ?
Write-Host ""
$nmail = Read-Host "How many mails do you want to open ? "
Write-Host ""

# Vérification que c'est bien un nombre
if (-not ($nmail -as [int])) {
    Write-Host "Please enter a valid number."
    return
}

# Boucle pour demander chaque email et ouvrir la page
for ($i = 1; $i -le $nmail; $i++) {

    $email = Read-Host "Enter email address #$i "

    $url = "https://accounts.google.com/AccountChooser?Email=$email"

    # Ouvrir la page dans le navigateur
    Start-Process $url
}
