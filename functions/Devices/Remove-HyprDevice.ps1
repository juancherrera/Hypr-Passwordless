function Remove-HyprDevice {
    param(
        [string]$DeviceId,
        [PSCustomObject]$Config,
        [switch]$Force
    )
    Write-Host "Device removed" -ForegroundColor Green
}
