function Test-HyprConnection {
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$Config,
        [switch]$IncludeAdminTest
    )
    
    Write-Verbose "Testing HYPR connection..."
    
    $connectionResults = @{
        RPAPIConnectivity = $false
        AdminAPIConnectivity = $false
        SSLConnectivity = $false
        OverallHealthy = $false
    }
    
    # Test RP API connectivity
    try {
        $fido2Settings = Get-HyprFIDO2Settings -Config $Config
        if ($fido2Settings -and $fido2Settings.RPAppId) {
            $connectionResults.RPAPIConnectivity = $true
            Write-Verbose "RP API connectivity: HEALTHY"
        }
    }
    catch {
        Write-Verbose "RP API connectivity: FAILED - $($_.Exception.Message)"
    }
    
    # Test Admin API connectivity
    if ($IncludeAdminTest -and ![string]::IsNullOrWhiteSpace($Config.CCAdminToken)) {
        try {
            $auditTest = Get-HyprAuditLog -Days 1 -Config $Config
            $connectionResults.AdminAPIConnectivity = $true
            Write-Verbose "Admin API connectivity: HEALTHY"
        }
        catch {
            Write-Verbose "Admin API connectivity: FAILED - $($_.Exception.Message)"
        }
    }
    elseif ($IncludeAdminTest) {
        Write-Verbose "Admin API connectivity: SKIPPED (no CC Admin token)"
    }
    else {
        $connectionResults.AdminAPIConnectivity = $true
    }
    
    # Test SSL connectivity
    try {
        $uri = [System.Uri]$Config.BaseUrl
        $tcpClient = New-Object System.Net.Sockets.TcpClient($uri.Host, 443)
        $tcpClient.Close()
        $connectionResults.SSLConnectivity = $true
        Write-Verbose "SSL connectivity: HEALTHY"
    }
    catch {
        Write-Verbose "SSL connectivity: FAILED - $($_.Exception.Message)"
    }
    
    $connectionResults.OverallHealthy = $connectionResults.RPAPIConnectivity -and 
                                       $connectionResults.AdminAPIConnectivity -and 
                                       $connectionResults.SSLConnectivity
    
    Write-Verbose "Connection test complete - Overall: $($connectionResults.OverallHealthy)"
    return $connectionResults.OverallHealthy
}
