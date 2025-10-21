function touch {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path
    )

    # Resolve the full path
    $fullPath = Resolve-Path -Path $Path -ErrorAction SilentlyContinue
    if (-not $fullPath) {
        $fullPath = Join-Path (Get-Location) $Path
    } else {
        $fullPath = $fullPath.Path
    }

    # Create or update timestamp
    if (Test-Path $fullPath) {
        (Get-Item $fullPath).LastWriteTime = Get-Date
    } else {
        New-Item -ItemType File -Path $fullPath | Out-Null
    }

    Write-Host "Touched: $fullPath" -ForegroundColor Green
}


# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
