function Test-HyprConnection {
  <#
  .SYNOPSIS
      Tests HYPR connection and displays health status.
  .DESCRIPTION
      Performs comprehensive health check of HYPR connection and API access.
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      Test-HyprConnection -Config $config
  .OUTPUTS
      [Boolean] True if connection is healthy
  #>
  param(
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  Write-Host "=== HYPR Connection Test ===" -ForegroundColor Cyan
      
  $healthStatus = @{
    BaseUrl       = $Config.BaseUrl
    RPAppId       = $Config.RPAppId
    Endpoints     = @{}
    OverallStatus = $true
  }
      
  # Test key endpoints
  $endpoints = @{
    "FIDO2Settings" = "/rp/api/versioned/fido2/settings"
    "UserStatus"    = "/rp/api/versioned/fido2/user/status?username=test@example.com"
  }
      
  foreach ($endpoint in $endpoints.GetEnumerator()) {
    try {
      $response = Invoke-HyprApi -Method GET -Endpoint $endpoint.Value -Config $Config -TokenType RP
      $healthStatus.Endpoints[$endpoint.Key] = "OK"
      Write-Host "✓ $($endpoint.Key): OK" -ForegroundColor Green
    }
    catch {
      $healthStatus.Endpoints[$endpoint.Key] = "FAILED: $($_.Exception.Message)"
      Write-Host "✗ $($endpoint.Key): FAILED" -ForegroundColor Red
      $healthStatus.OverallStatus = $false
    }
  }
      
  Write-Host "`nOverall Status: $(if($healthStatus.OverallStatus) {"HEALTHY"} else {"UNHEALTHY"})" -ForegroundColor $(if ($healthStatus.OverallStatus) { "Green" } else { "Red" })
      
  return $healthStatus.OverallStatus
}