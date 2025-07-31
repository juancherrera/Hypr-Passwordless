function Get-HyprRecoveryPIN {
    param(
        [string]$Username,
        [switch]$Reveal,
        [PSCustomObject]$Config
    )
    
    $endpoint = if ($Reveal) { "/rp/api/versioned/recoverypin/reveal" } else { "/rp/api/versioned/recoverypin/retrieve" }
    $body = @{ username = $Username; rpAppId = $Config.RPAppId }
    
    try {
        $response = Invoke-HyprApi -Method POST -Endpoint $endpoint -Config $Config -Body $body -TokenType RP
        return [PSCustomObject]@{
            Username = $Username
            HasRecoveryPIN = $true
            RecoveryPIN = if ($Reveal) { $response.pin } else { "[HIDDEN]" }
        }
    }
    catch {
        throw "Failed to get recovery PIN for $Username"
    }
}
