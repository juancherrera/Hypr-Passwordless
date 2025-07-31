function New-HyprUser {
    param(
        [string]$Username,
        [string]$DisplayName,
        [PSCustomObject]$Config
    )
    Write-Host "User created" -ForegroundColor Green
}
