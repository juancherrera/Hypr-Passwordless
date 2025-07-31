function New-HyprQRCode {
    param(
        [string]$Username,
        [bool]$IncludeFallback = $true,
        [PSCustomObject]$Config
    )
    
    $body = @{
        rpAppId = $Config.RPAppId
        username = $Username
        includeQRFallbackCode = $IncludeFallback
    }
    
    try {
        $response = Invoke-HyprApi -Method POST -Endpoint "/rp/versioned/client/qr/create" -Config $Config -Body $body -TokenType RP
        Write-Host "QR code created for $Username" -ForegroundColor Green
        return [PSCustomObject]@{
            Username = $Username
            QRCodeData = $response.qrCode
            FallbackCode = $response.activationCode
        }
    }
    catch {
        throw "Failed to create QR code for $Username"
    }
}
