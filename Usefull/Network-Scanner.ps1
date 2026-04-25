param([string]$Network = "192.168.1")

. "$PSScriptRoot\setup.ps1"
Show-SectionHeader "Scan réseau $Network.0/24 lancé"

$functionBlock = {
    function Test-NetworkHost {
        param([string]$IP)
        try {
            if (Test-Connection $IP -Count 1 -Quiet -EA Stop) {
                $dns = Resolve-DnsName $IP -EA SilentlyContinue
                $name = if ($dns) { $dns.NameHost } else { $IP }
                $pingResult = Test-Connection $IP -Count 1 -EA Stop
                return [PSCustomObject]@{IP = $IP; Hostname = $name; Status = "ONLINE"; PingMs = $pingResult.ResponseTime }
            }
        }
        catch {
            return [PSCustomObject]@{IP = $IP; Hostname = "N/A"; Status = "OFFLINE"; PingMs = 9999 }
        }
    }
}

$onlineHosts = @()
$pool = [runspacefactory]::CreateRunspacePool(5, 20); $null = $pool.Open()
$jobs = @()

# CRÉATION JOBS (ultra rapide)
for ($i = 1; $i -le 254; $i++) {
    $ip = "$Network.$i"
    $ps = [powershell]::Create()
    $null = $ps.AddScript($functionBlock).AddScript({ param($ip) Test-NetworkHost $ip }).AddArgument($ip)
    $null = $ps.RunspacePool = $pool
    $null = $jobs += [PSCustomObject]@{Pipe = $ps; AsyncResult = $ps.BeginInvoke(); IP = $ip }
}

# ✅ ATTENTE OPTIMALE (comme l'ancien, mais propre)
do { Start-Sleep -Milliseconds 20 } while ($jobs | Where-Object { $_.AsyncResult.IsCompleted -eq $false })

# RÉSULTATS (RAPIDE)
foreach ($job in $jobs) {
    if ($job.AsyncResult.IsCompleted) {
        $result = $job.Pipe.EndInvoke($job.AsyncResult)
        $job.Pipe.Dispose()
        if ($result.Status -eq "ONLINE") {
            $onlineHosts += $result
            Write-Status SUCCESS "$($result.IP) ($($result.Hostname))"
        }
    }
}

$pool.Close(); $pool.Dispose()
Write-Host ""
Write-Status INFO "Scan terminé : $($onlineHosts.Count)/254"
Show-Counters
