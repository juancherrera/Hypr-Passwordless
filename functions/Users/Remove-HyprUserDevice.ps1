function Remove-HyprUserDevice {
    param(
        [string]$Username,
        [string]$KeyId,
        [PSCustomObject]$Config
    )
    
    try {
        $response = Invoke-HyprApi -Method DELETE -Endpoint "/rp/api/versioned/fido2/user?username=$Username&keyId=$KeyId" -Config $Config -TokenType RP
        Write-Host "Device removed successfully" -ForegroundColor Green
        return $response
    }
    catch {
        throw "Failed to remove device from user $Username"
    }
}
