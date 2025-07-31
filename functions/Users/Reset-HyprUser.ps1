function Reset-HyprUser {
    param(
        [string]$Username,
        [PSCustomObject]$Config,
        [switch]$Force
    )
    
    if (-not $Force) {
        $confirm = Read-Host "Reset user '$Username'? (y/N)"
        if ($confirm -ne 'y') { return }
    }
    
    try {
        $devices = Get-HyprUserDevices -Username $Username -Config $Config
        foreach ($device in $devices) {
            Remove-HyprUserDevice -Username $Username -KeyId $device.KeyId -Config $Config
        }
        Write-Host "User reset successfully" -ForegroundColor Green
    }
    catch {
        throw "Failed to reset user $Username"
    }
}
