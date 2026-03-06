param([string]$Network = "192.168.1")

. "$PSScriptRoot\setup.ps1"
Write-Status INFO "Scan réseau $Network.0/24 lancé"

$functionBlock = {
    function Test-NetworkHost {
        param([string]$IP)
        try {
            $ping = Test-Connection $IP -Count 1 -Quiet -ErrorAction Stop
            if ($ping) {
                $dns = Resolve-DnsName $IP -ErrorAction SilentlyContinue
                $name = if ($dns) { $dns.NameHost } else { $IP }
                $pingResult = Test-Connection $IP -Count 1 -ErrorAction Stop
                return [PSCustomObject]@{IP = $IP; Hostname = $name; Status = "ONLINE"; PingMs = $pingResult.ResponseTime }
            }
        }
        catch {
            return [PSCustomObject]@{IP = $IP; Hostname = "N/A"; Status = "OFFLINE"; PingMs = 9999 }
        }
    }
}

$onlineHosts = @()
$pool = [runspacefactory]::CreateRunspacePool(5, 20)
$pool.Open()
$jobs = @()

for ($i = 1; $i -le 254; $i++) {
    $ip = "$Network.$i"

    $ps = [powershell]::Create()
    $ps.AddScript($functionBlock).AddScript({
            param($ip, $TimeoutMs)
            Test-NetworkHost -IP $ip
        }).AddArgument($ip).AddArgument($TimeoutMs)

    $null = $ps.RunspacePool = $pool
    $jobs += [PSCustomObject]@{Pipe = $ps; AsyncResult = $ps.BeginInvoke() }
}

foreach ($job in $jobs) {
    if ($job.AsyncResult.IsCompleted) {
        $result = $job.Pipe.EndInvoke($job.AsyncResult)
        $job.Pipe.Dispose()
        if ($result.Status -eq "ONLINE") {
            $onlineHosts += $result
            Write-Status SUCCESS "$($result.IP) ($($result.Hostname)) [$($result.PingMs)ms]"
        }
    }
    if ($job.Pipe) { $job.Pipe.Dispose() }
}
$pool.Close(); $pool.Dispose()

#$rapportPath = "$env:TEMP\Logs\Network-Scan-$(Get-Date -f 'yyyyMMdd-HHmmss').csv"
#$onlineHosts | Sort-Object PingMs | Export-Csv $rapportPath -NoTypeInformation -Encoding UTF8

Write-Status INFO "Scan terminé : $($onlineHosts.Count)/254 hôtes"
Show-Counters
