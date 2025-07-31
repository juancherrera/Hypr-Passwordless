function Connect-Hypr {
    param([string]$ConfigPath = "config\hypr_config.json")
    
    $config = Load-HyprConfig -Path $ConfigPath
    
    if ([string]::IsNullOrWhiteSpace($config.RPAppToken)) {
        throw "No RP App token configured"
    }
    
    try {
        $response = Invoke-HyprApi -Method GET -Endpoint "/rp/api/versioned/fido2/settings" -Config $config -TokenType RP
        if ($response) {
            Write-Host "Connected to HYPR" -ForegroundColor Green
            return $config
        } else {
            throw "Empty response from HYPR API"
        }
    }
    catch {
        Write-Host "Failed to connect to HYPR" -ForegroundColor Red
        throw "Failed to connect to HYPR: $($_.Exception.Message)"
    }
}
