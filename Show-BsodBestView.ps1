Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Fenêtre plein écran ---
$form = New-Object System.Windows.Forms.Form
$form.WindowState = 'Maximized'
$form.FormBorderStyle = 'None'
$form.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$form.TopMost = $true
$form.KeyPreview = $true
$form.Opacity = 0   # Fade-in

# --- Conteneur principal ---
$panel = New-Object System.Windows.Forms.TableLayoutPanel
$panel.Dock = 'Fill'
$panel.BackColor = 'Transparent'
$panel.RowCount = 4
$panel.ColumnCount = 1
$panel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 25)))
$panel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 25)))
$panel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 25)))
$panel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 25)))
$form.Controls.Add($panel)

# --- Emoji triste ---
$emoji = New-Object System.Windows.Forms.Label
$emoji.Text = ":("
$emoji.Font = New-Object System.Drawing.Font("Segoe UI", 90, [System.Drawing.FontStyle]::Bold)
$emoji.ForeColor = [System.Drawing.Color]::White
$emoji.TextAlign = 'MiddleCenter'
$emoji.Dock = 'Fill'
$panel.Controls.Add($emoji, 0, 0)

# --- Texte principal ---
$text = New-Object System.Windows.Forms.Label
$text.Font = New-Object System.Drawing.Font("Segoe UI", 22)
$text.ForeColor = [System.Drawing.Color]::White
$text.TextAlign = 'MiddleCenter'
$text.Dock = 'Fill'
$text.Text = "Votre PC a rencontré un problème et doit redémarrer.`n`nNous collectons simplement des informations relatives à l’erreur."
$panel.Controls.Add($text, 0, 1)

# --- Pourcentage ---
$percentLabel = New-Object System.Windows.Forms.Label
$percentLabel.Font = New-Object System.Drawing.Font("Segoe UI", 26, [System.Drawing.FontStyle]::Bold)
$percentLabel.ForeColor = [System.Drawing.Color]::White
$percentLabel.TextAlign = 'MiddleCenter'
$percentLabel.Dock = 'Fill'
$percentLabel.Text = "0% effectué"
$panel.Controls.Add($percentLabel, 0, 2)

# --- Spinner animé ---
$spinner = New-Object System.Windows.Forms.Label
$spinner.Font = New-Object System.Drawing.Font("Consolas", 30)
$spinner.ForeColor = [System.Drawing.Color]::White
$spinner.TextAlign = 'MiddleCenter'
$spinner.Dock = 'Fill'
$spinner.Text = "|"
$panel.Controls.Add($spinner, 0, 3)

# --- Animation spinner ---
$spinChars = @("|", "/", "-", "\")
$spinIndex = 0

# --- Timer principal ---
$percent = 0
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 120

$timer.Add_Tick({
        # Spinner
        $spinner.Text = $spinChars[$spinIndex]
        $spinIndex = ($spinIndex + 1) % $spinChars.Count

        # Pourcentage
        if ($percent -lt 100) {
            $percent++
            $percentLabel.Text = "$percent% effectué"
        }
    })

# --- Fade-in ---
$fade = New-Object System.Windows.Forms.Timer
$fade.Interval = 20
$fade.Add_Tick({
        if ($form.Opacity -lt 1) {
            $form.Opacity += 0.03
        }
        else {
            $fade.Stop()
        }
    })

# --- Sortie par Échap ---
$form.Add_KeyDown({
        if ($_.KeyCode -eq 'Escape') {
            $form.Close()
        }
    })

$form.Add_Load({
        $fade.Start()
        $timer.Start()
    })

[System.Windows.Forms.Application]::Run($form)
