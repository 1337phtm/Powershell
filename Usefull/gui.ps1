Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# === CONFIGURATION ===
$scriptFolder = $PSScriptRoot   # <-- Mets ton dossier ici

# === FENETRE ===
$form = New-Object System.Windows.Forms.Form
$form.Text = "Gestionnaire de Scripts PowerShell"
$form.Size = New-Object System.Drawing.Size(1000,600)
$form.StartPosition = "CenterScreen"

# === LISTE DES FICHIERS ===
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Size = New-Object System.Drawing.Size(300,500)
$listBox.Location = New-Object System.Drawing.Point(10,10)

Get-ChildItem $scriptFolder -Filter *.ps1 | ForEach-Object {
    $listBox.Items.Add($_.Name)
}

$form.Controls.Add($listBox)

# === ZONE CONTENU SCRIPT ===
$scriptContent = New-Object System.Windows.Forms.RichTextBox
$scriptContent.Size = New-Object System.Drawing.Size(650,250)
$scriptContent.Location = New-Object System.Drawing.Point(320,10)
$scriptContent.ReadOnly = $true

$form.Controls.Add($scriptContent)

# === ZONE SORTIE ===
$outputBox = New-Object System.Windows.Forms.RichTextBox
$outputBox.Size = New-Object System.Drawing.Size(650,200)
$outputBox.Location = New-Object System.Drawing.Point(320,300)
$outputBox.ReadOnly = $true

$form.Controls.Add($outputBox)

# === AFFICHER CONTENU AU CLIC ===
$listBox.Add_SelectedIndexChanged({
    if ($listBox.SelectedItem) {
        $scriptContent.Text = Get-Content $listBox.SelectedItem -Raw
    }
})

# === BOUTON EXECUTER ===
$runButton = New-Object System.Windows.Forms.Button
$runButton.Text = "Exécuter"
$runButton.Size = New-Object System.Drawing.Size(100,30)
$runButton.Location = New-Object System.Drawing.Point(10,520)

$runButton.Add_Click({
    if ($listBox.SelectedItem) {
        $outputBox.Clear()
        $output = powershell -ExecutionPolicy Bypass -File $listBox.SelectedItem 2>&1
        $outputBox.Text = $output
    }
})

$form.Controls.Add($runButton)

$form.ShowDialog()