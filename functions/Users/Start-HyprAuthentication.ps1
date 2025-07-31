function Start-HyprAuthentication {
    param(
        [string]$Username,
        [string]$TransactionText = "Please authenticate",
        [PSCustomObject]$Config
    )
    
    $requestId = [guid]::NewGuid().ToString()
    $body = @{
        rpAppId = $Config.RPAppId
        username = $Username
        transactionText = $TransactionText
        requestId = $requestId
    }
    
    try {
        $response = Invoke-HyprApi -Method POST -Endpoint "/rp/api/oob/client/authentication/requests" -Config $Config -Body $body -TokenType RP
        Write-Host "Authentication started for $Username" -ForegroundColor Green
        return [PSCustomObject]@{
            RequestId = $requestId
            Username = $Username
            Status = "INITIATED"
        }
    }
    catch {
        throw "Failed to start authentication for $Username"
    }
}
