# Charger le JSON
$jsonPath = "..\src\install\apps.json"
$apps = Get-Content $jsonPath -Raw | ConvertFrom-Json

# Trier :
# 1) category (vide en dernier)
# 2) supportsLocation (true > false > null)
$sorted = $apps | Sort-Object `
@{ Expression = {
        if ($_.category -eq "System") { "000" }
        elseif ([string]::IsNullOrWhiteSpace($_.category)) { "zzz" }
        else { $_.category }
    }
},
@{ Expression = {
        switch ($_.supportsLocation) {
            $true { 0 }
            $false { 1 }
            $null { 2 }
        }
    }
}


# Réécrire le JSON formaté
$sorted | ConvertTo-Json -Depth 10 | Set-Content $jsonPath
