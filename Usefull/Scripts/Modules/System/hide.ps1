Write-Host "Hidden File :"
$file = Read-Host "Enter the path of file"
attrib +s +h $file
# attrib -s -h to unhidden file
