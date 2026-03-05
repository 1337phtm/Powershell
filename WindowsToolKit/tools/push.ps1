Set-Location ..
git add .
$timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$message = "[$timestamp] push by $($env:USERNAME)"
git commit -m $message
git push origin main
exit

#ou script d installation local
#
#Tools c est pour des scripts pour lesz devs limite faire un .gitignore
