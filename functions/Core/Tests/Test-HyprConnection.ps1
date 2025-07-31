function Test-HyprConnection {
  <#
  .SYNOPSIS
      Performs comprehensive health check of HYPR connection.
  .DESCRIPTION
      Tests multiple HYPR endpoints to verify connectivity and token permissions.
      Uses only proven working endpoints from successful implementations.
  .PARAMETER Config
      HYPR configuration object from Connect-Hypr.
  .EXAMPLE
      $isHealthy = Test-HyprConnection -Config $config
  .OUTPUTS
      [Boolean] True if connection is healthy, False otherwise
  #>
  param(
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  Write-Host "=== HYPR Connection Health Check ===" -ForegroundColor Cyan
  Write-Host "Testing connection to: $($Config.BaseUrl)" -ForegroundColor Gray
  Write-Host "RP App ID: $($Config.RPAppId)" -ForegroundColor Gray
      
  $healthStatus = @{
    BaseUrl       = $Config.BaseUrl
    RPAppId       = $Config.RPAppId
    TokenTests    = @{}
    EndpointTests = @{}
    OverallStatus = $true
  }
      
  # Test RP App token
  Write-Host "`n1. Testing RP App Token..." -ForegroundColor Yellow
  try {
    $rpToken = Get-HyprToken -Config $Config -TokenType RP
    $healthStatus.TokenTests["RPApp"] = "Valid"
    Write-Host "   ✓ RP App token is valid" -ForegroundColor Green
  }
  catch {
    $healthStatus.TokenTests["RPApp"] = "Invalid: $($_.Exception.Message)"
    Write-Host "   ✗ RP App token error: $($_.Exception.Message)" -ForegroundColor Red
    $healthStatus.OverallStatus = $false
  }
      
  # Test CC Admin token if configured
  if (![string]::IsNullOrWhiteSpace($Config.CCAdminToken)) {
    Write-Host "`n2. Testing CC Admin Token..." -ForegroundColor Yellow
    try {
      $adminToken = Get-HyprToken -Config $Config -TokenType Admin
      $healthStatus.TokenTests["CCAdmin"] = "Valid"
      Write-Host "   ✓ CC Admin token is valid" -ForegroundColor Green
    }
    catch {
      $healthStatus.TokenTests["CCAdmin"] = "Invalid: $($_.Exception.Message)"
      Write-Host "   ✗ CC Admin token error: $($_.Exception.Message)" -ForegroundColor Red
    }
  }
  else {
    $healthStatus.TokenTests["CCAdmin"] = "Not Configured"
    Write-Host "`n2. CC Admin Token: Not configured" -ForegroundColor Gray
  }
      
  # Test proven working endpoints
  Write-Host "`n3. Testing API Endpoints..." -ForegroundColor Yellow
      
  $endpoints = @{
    "FIDO2 Settings"    = @{
      Endpoint  = "/rp/api/versioned/fido2/settings"
      TokenType = "RP"
      Critical  = $true
    }
    "User Status Check" = @{
      Endpoint  = "/rp/api/versioned/fido2/user/status?username=healthcheck@example.com"
      TokenType = "RP"
      Critical  = $false
    }
  }
      
  foreach ($test in $endpoints.GetEnumerator()) {
    $testName = $test.Key
    $testConfig = $test.Value
          
    try {
      Write-Host "   Testing: $testName..." -ForegroundColor Gray
      $response = Invoke-HyprApi -Method GET -Endpoint $testConfig.Endpoint -Config $Config -TokenType $testConfig.TokenType
              
      $healthStatus.EndpointTests[$testName] = "OK"
      Write-Host "   ✓ $testName`: OK" -ForegroundColor Green
              
    }
    catch {
      $errorMsg = $_.Exception.Message
      $healthStatus.EndpointTests[$testName] = "FAILED: $errorMsg"
              
      if ($testConfig.Critical) {
        Write-Host "   ✗ $testName`: CRITICAL FAILURE" -ForegroundColor Red
        Write-Host "     Error: $errorMsg" -ForegroundColor Red
        $healthStatus.OverallStatus = $false
      }
      else {
        Write-Host "   ⚠ $testName`: Non-critical failure" -ForegroundColor Yellow
        Write-Host "     Error: $errorMsg" -ForegroundColor Yellow
      }
    }
  }
      
  # Overall status
  Write-Host "`n=== Health Check Results ===" -ForegroundColor Cyan
  $statusColor = if ($healthStatus.OverallStatus) { "Green" } else { "Red" }
  $statusText = if ($healthStatus.OverallStatus) { "HEALTHY" } else { "UNHEALTHY" }
      
  Write-Host "Overall Status: $statusText" -ForegroundColor $statusColor
      
  # Summary
  $successfulTests = ($healthStatus.EndpointTests.Values | Where-Object { $_ -eq "OK" }).Count
  $totalTests = $healthStatus.EndpointTests.Count
  Write-Host "Endpoint Tests: $successfulTests/$totalTests passed" -ForegroundColor Gray
      
  if ($healthStatus.OverallStatus) {
    Write-Host "+++ HYPR connection is healthy and ready for use!" -ForegroundColor Green
  }
  else {
    Write-Host "xxx HYPR connection has issues that need to be resolved." -ForegroundColor Red
  }
      
  return $healthStatus.OverallStatus
}