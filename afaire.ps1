# en admin : (genre dans src et comme win conf fichier qui l'appel en admin)
#powercfg /energy
#$aze = ".\energy-report.html"
#$aze

# en admin :
#powercfg /sleepstudy
#$aze = ".\sleepstudy-report.html"
#$aze


#perfmon /report

# a essayer une fois branché :
#winsat formal


#netstat -ano

# en admin :
#chkdsk C: /scan


#mstsc /v:@ip


#PING.EXE


# Test-connection + rdp
#$aze = Test-Connection "PCP1-PHANTOM" -Count 1
#
#if ($aze.StatusCode -eq 0) {
#    Write-Host "PCP1-PHANTOM est en ligne"
#    # Utilise directement l'IP ou convertis en string
#    $ip = $aze.IPv4Address.IPAddressToString
#    mstsc /v:$ip
#}
#else {
#    Write-Host "PCP1-PHANTOM est hors ligne"
#}



# Test-connection PC connus
#$pcs = @("PCP1-PHANTOM", "PC2-SERVEUR", "PC3-WORKSTATION")
#$online = foreach ($pc in $pcs) {
#    $ping = Test-Connection $pc -Count 1
#    if ($ping.StatusCode -eq 0) { $pc }
#}

#Write-Host "PC en ligne : $($online -join ', ')"





# Ping broadcast + ARP (capture tout d'un coup)
#ping 192.168.1.255 -n 1 | Out-Null
#arp -a | Select-String "192.168.1" | ForEach-Object {
#    if ($_ -match "([0-9a-f-]{17})") {
#        $_.ToString()
#    }
#}



#$network = "192.168.1"  # Ton réseau
#
## Jobs PowerShell
#$jobs = @()
#$pool = [runspacefactory]::CreateRunspacePool(1, 20)
#$pool.Open()
#
## Création des jobs
#1..254 | ForEach-Object {
#    $ip = "$network.$_"
#    $ps = [powershell]::Create()
#    $ps.AddScript({
#            param($ip)
#            if (Test-Connection $ip -Count 1 -Quiet -ErrorAction SilentlyContinue) {
#                $ip
#            }
#        }).AddArgument($ip) | Out-Null
#    $ps.RunspacePool = $pool
#
#    $handle = $ps.BeginInvoke()
#    $jobs += [PSCustomObject]@{PowerShell = $ps; Handle = $handle }
#}
#
## Attente + résultats
#do {
#    Start-Sleep -Milliseconds 100
#} while ($jobs.Handle.IsCompleted -notcontains $true)
#
## Collecte résultats
#$online = $jobs | ForEach-Object {
#    if ($_.Handle.IsCompleted) {
#        $result = $_.PowerShell.EndInvoke($_.Handle)
#        $_.PowerShell.Dispose()
#        $result
#    }
#}
#
#Write-Host "En ligne : $($online -join ', ')" -ForegroundColor Green
#$pool.Close()




# Juste tes machines critiques
#$pcs = @("PCP1-PHANTOM", "PC2-SERVEUR", "192.168.1.10")
#$online = $pcs | ForEach-Object {
#    if (Test-Connection $_ -Count 1 -Quiet) { $_ }
#}
#
#Write-Host "En ligne : $($online -join ', ')"
