function Update-Progress {
    param (
        [Parameter(Mandatory, position = 0)]
        [string]$StatusMessage,

        [Parameter(Mandatory, position = 1)]
        [ValidateRange(0, 100)]
        [int]$Percent,

        [Parameter(position = 2)]
        [string]$Activity = "Compiling"
    )

    Write-Progress -Activity $Activity -Status $StatusMessage -PercentComplete $Percent
}


Update-Progress "Pre-req: Running Preprocessor..." 50


Write-Host "salut"

