function Connect-Hypr {
  <#
  .SYNOPSIS
      Establishes and validates connection to HYPR using proven endpoints.
  .DESCRIPTION
      Loads configuration, validates tokens, and tests connectivity using the
      FIDO2 settings endpoint which is guaranteed to work with RP App tokens.
  .PARAMETER ConfigPath
      Path to HYPR configuration file.
  .EXAMPLE
      $config = Connect-Hypr -ConfigPath ".\config\hypr_config.json"
  .OUTPUTS
      [PSCustomObject] Validated HYPR configuration object
  #>
  param(
    [string]$ConfigPath = "$script:ModuleRoot\config\hypr_config.json"
  )
      
  Write-Verbose "Loading HYPR configuration from $ConfigPath"
  $config = Load-HyprConfig -Path $ConfigPath
      
  # Validate we have required tokens
  if ([string]::IsNullOrWhiteSpace($config.RPAppToken)) {
    throw "No RP App token configured. Please add your HYPR API token to the configuration file."
  }
      
  Write-Host "Testing connection to HYPR at $($config.BaseUrl)..." -ForegroundColor Yellow
      
  # Test connection with FIDO2 settings endpoint (proven to work)
  try {
    $testResponse = Invoke-HyprApi -Method GET -Endpoint "/rp/api/versioned/fido2/settings" -Config $config -TokenType RP
          
    if ($testResponse) {
      Write-Host "✓ Successfully connected to HYPR!" -ForegroundColor Green
      Write-Host "  Connected to: $($config.BaseUrl)" -ForegroundColor Gray
      Write-Host "  RP App ID: $($config.RPAppId)" -ForegroundColor Gray
              
      # Show some basic info from the response if available
      if ($testResponse.response -and $testResponse.response.rpAppId) {
        Write-Host "  Verified RP App: $($testResponse.response.rpAppId)" -ForegroundColor Gray
      }
              
      return $config
    }
    else {
      throw "Empty response from HYPR API"
    }
          
  }
  catch {
    Write-Host "✗ Failed to connect to HYPR" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
          
    # Provide helpful troubleshooting guidance
    Write-Host "`nTroubleshooting steps:" -ForegroundColor Yellow
    Write-Host "1. Verify BaseUrl is correct: $($config.BaseUrl)" -ForegroundColor Gray
    Write-Host "2. Ensure RPAppToken is valid and starts with 'hypap-'" -ForegroundColor Gray
    Write-Host "3. Check network connectivity to HYPR server" -ForegroundColor Gray
    Write-Host "4. Verify token permissions in HYPR Control Center" -ForegroundColor Gray
          
    throw "Failed to connect to HYPR: $($_.Exception.Message)"
  }
}