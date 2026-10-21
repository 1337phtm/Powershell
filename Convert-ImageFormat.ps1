Add-Type -AssemblyName System.Drawing

$ext = Read-Host "Enter the desired file extension (jpg, png, bmp, gif, tiff) "

$src = Read-Host "enter the Location of the source image (with extension)"
$dst = Read-Host "enter the Location of the destination image (without extension)"

# 1) Charger l'image source
$image = [System.Drawing.Image]::FromFile($src)

# 2) Construire le chemin final avec la nouvelle extension
$dstFinal = [System.IO.Path]::ChangeExtension($dst, $ext)

# 3) Sauvegarder l'image convertie
$image.Save($dstFinal)

# 4) Libérer la ressource
$image.Dispose()
