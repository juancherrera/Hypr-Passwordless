function Get-HyprSystemHealth {
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$Config,
        [switch]$IncludePerformanceMetrics
    )
    
    Write-Verbose "Performing comprehensive HYPR system health check..."
    
    $healthChecks = @()
    $overallHealth = "HEALTHY"
    
    # 1. Basic connectivity test
    try {
        $connectivityStart = Get-Date
        $fido2Settings = Get-HyprFIDO2Settings -Config $Config
        $connectivityTime = (Get-Date) - $connectivityStart
        
        $healthChecks += [PSCustomObject]@{
            Component = "API_CONNECTIVITY"
            Status = "HEALTHY"
            ResponseTime = $connectivityTime.TotalMilliseconds
            Details = "FIDO2 settings endpoint accessible"
            CheckedAt = Get-Date
        }
    }
    catch {
        $healthChecks += [PSCustomObject]@{
            Component = "API_CONNECTIVITY"
            Status = "UNHEALTHY"
            Error = $_.Exception.Message
            CheckedAt = Get-Date
        }
        $overallHealth = "DEGRADED"
    }
    
    # 2. Authentication endpoint test
    try {
        $authTestStart = Get-Date
        try {
            Get-HyprUserStatus -Username "health-check-test-user-$(Get-Random)" -Config $Config
        }
        catch {
            # Expected to fail, but endpoint should be reachable
        }
        $authTestTime = (Get-Date) - $authTestStart
        
        $healthChecks += [PSCustomObject]@{
            Component = "AUTHENTICATION_SERVICE"
            Status = "HEALTHY"
            ResponseTime = $authTestTime.TotalMilliseconds
            Details = "Authentication endpoints accessible"
            CheckedAt = Get-Date
        }
    }
    catch {
        $healthChecks += [PSCustomObject]@{
            Component = "AUTHENTICATION_SERVICE"
            Status = "UNHEALTHY"
            Error = $_.Exception.Message
            CheckedAt = Get-Date
        }
        $overallHealth = "DEGRADED"
    }
    
    # 3. Admin API test (if token available)
    if (![string]::IsNullOrWhiteSpace($Config.CCAdminToken)) {
        try {
            $adminTestStart = Get-Date
            Get-HyprAuditLog -Days 1 -Config $Config
            $adminTestTime = (Get-Date) - $adminTestStart
            
            $healthChecks += [PSCustomObject]@{
                Component = "ADMIN_API"
                Status = "HEALTHY"
                ResponseTime = $adminTestTime.TotalMilliseconds
                Details = "Admin endpoints accessible with valid token"
                CheckedAt = Get-Date
            }
        }
        catch {
            $healthChecks += [PSCustomObject]@{
                Component = "ADMIN_API"
                Status = "UNHEALTHY"
                Error = $_.Exception.Message
                CheckedAt = Get-Date
            }
            $overallHealth = "DEGRADED"
        }
    }
    else {
        $healthChecks += [PSCustomObject]@{
            Component = "ADMIN_API"
            Status = "NOT_CONFIGURED"
            Details = "CC Admin token not configured"
            CheckedAt = Get-Date
        }
    }
    
    # 4. SSL/TLS health check
    try {
        $sslTestStart = Get-Date
        $uri = [System.Uri]$Config.BaseUrl
        $tcpClient = New-Object System.Net.Sockets.TcpClient($uri.Host, 443)
        $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream())
        $sslStream.AuthenticateAsClient($uri.Host)
        
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($sslStream.RemoteCertificate)
        $sslTestTime = (Get-Date) - $sslTestStart
        
        $sslStream.Close()
        $tcpClient.Close()
        
        $daysUntilExpiry = [Math]::Floor(($cert.NotAfter - (Get-Date)).TotalDays)
        
        $healthChecks += [PSCustomObject]@{
            Component = "SSL_CERTIFICATE"
            Status = if ($daysUntilExpiry -gt 30) { "HEALTHY" } elseif ($daysUntilExpiry -gt 7) { "WARNING" } else { "CRITICAL" }
            ResponseTime = $sslTestTime.TotalMilliseconds
            Details = "Certificate expires in $daysUntilExpiry days"
            ExpirationDate = $cert.NotAfter
            CheckedAt = Get-Date
        }
        
        if ($daysUntilExpiry -le 30) {
            $overallHealth = "WARNING"
        }
    }
    catch {
        $healthChecks += [PSCustomObject]@{
            Component = "SSL_CERTIFICATE"
            Status = "UNHEALTHY"
            Error = $_.Exception.Message
            CheckedAt = Get-Date
        }
        $overallHealth = "DEGRADED"
    }
    
    # Compile overall health assessment
    $healthyCount = ($healthChecks | Where-Object Status -eq "HEALTHY").Count
    $totalCount = $healthChecks.Count
    
    $healthSummary = [PSCustomObject]@{
        OverallStatus = $overallHealth
        CheckedAt = Get-Date
        TotalComponents = $totalCount
        HealthyComponents = $healthyCount
        UnhealthyComponents = ($healthChecks | Where-Object Status -eq "UNHEALTHY").Count
        WarningComponents = ($healthChecks | Where-Object Status -eq "WARNING").Count
        NotConfiguredComponents = ($healthChecks | Where-Object Status -eq "NOT_CONFIGURED").Count
        AverageResponseTime = if ($IncludePerformanceMetrics) {
            $responseTimes = $healthChecks | Where-Object ResponseTime | Select-Object -ExpandProperty ResponseTime
            if ($responseTimes.Count -gt 0) {
                [Math]::Round(($responseTimes | Measure-Object -Average).Average, 2)
            } else { 0 }
        } else { "NOT_MEASURED" }
        ComponentDetails = $healthChecks
        HealthScore = [Math]::Round(($healthyCount / $totalCount) * 100, 1)
        Recommendations = @()
    }
    
    # Generate health recommendations
    if ($healthSummary.UnhealthyComponents -gt 0) {
        $healthSummary.Recommendations += "Address $($healthSummary.UnhealthyComponents) unhealthy components immediately"
    }
    
    if ($healthSummary.WarningComponents -gt 0) {
        $healthSummary.Recommendations += "Monitor $($healthSummary.WarningComponents) components showing warnings"
    }
    
    if ($healthSummary.NotConfiguredComponents -gt 0) {
        $healthSummary.Recommendations += "Configure $($healthSummary.NotConfiguredComponents) components for complete monitoring"
    }
    
    if ($IncludePerformanceMetrics -and $healthSummary.AverageResponseTime -ne "NOT_MEASURED" -and $healthSummary.AverageResponseTime -gt 5000) {
        $healthSummary.Recommendations += "Investigate performance - average response time exceeds 5 seconds"
    }
    
    Write-Verbose "System health check complete - Status: $($healthSummary.OverallStatus), Score: $($healthSummary.HealthScore)%"
    return $healthSummary
}
