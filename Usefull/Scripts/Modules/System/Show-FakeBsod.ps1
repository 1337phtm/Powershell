Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Bip au lancement ---
[console]::beep(1750, 750)
[console]::beep(1750, 500)

# --- Fenêtre plein écran ---
$form = New-Object System.Windows.Forms.Form
$form.WindowState = 'Maximized'
$form.FormBorderStyle = 'None'
$form.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$form.TopMost = $true
$form.KeyPreview = $true

# --- Label principal ---
$label = New-Object System.Windows.Forms.Label
$label.Dock = 'Fill'
$label.ForeColor = [System.Drawing.Color]::White
$label.BackColor = [System.Drawing.Color]::Transparent
$label.TextAlign = 'MiddleCenter'
$label.Font = New-Object System.Drawing.Font('Consolas', 28)
$form.Controls.Add($label)

# Texte de base
$baseText = @"
:(

Votre PC a rencontré un problème et doit redémarrer.
Nous collectons simplement des informations relatives à l’erreur, puis nous allons
redémarrer pour vous.

{0}% effectué

Appuyez sur Échap pour quitter.
"@

# --- Initialisation du texte ---
$label.Text = $baseText -f 0

# --- Timer pour le faux pourcentage ---
$percent = 0
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000 # 1 seconde

$timer.Add_Tick({
        if ($percent -lt 100) {
            $percent++
            $label.Text = $baseText -f $percent
        }
        else {
            $timer.Stop()
            [console]::beep(600, 300)
        }
    })

# --- Démarrer le timer quand la fenêtre est affichée ---
$form.Add_Shown({
        $timer.Start()
    })

# Quitter avec Échap
$form.Add_KeyDown({
        if ($_.KeyCode -eq 'Escape') {
            $form.Close()
        }
    })

[System.Windows.Forms.Application]::Run($form)
