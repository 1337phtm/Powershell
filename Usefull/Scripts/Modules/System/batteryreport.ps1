powercfg /batteryreport /output $env:USERPROFILE\Documents\BatteryReport.html | Out-Null

$aze = "$env:USERPROFILE\Documents\BatteryReport.html"

Invoke-Item $aze
