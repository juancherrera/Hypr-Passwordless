function Connect-Hypr {
  <#
  .SYNOPSIS
      Establishes and validates connection to HYPR.
  .DESCRIPTION
      Loads configuration, validates tokens, and tests connectivity to HYPR APIs.
  .PARAMETER ConfigPath
      Path to HYPR configuration file.
  .EXAMPLE
      $config = Connect-Hypr -ConfigPath "C:\config\hypr.json"
  .OUTPUTS
      [PSCustomObject] Validated HYPR configuration object
  #>
  param(
    [string]$ConfigPath = "$script:ModuleRoot\config\hypr_config.json"
  )
      
  $config = Load-HyprConfig -Path $ConfigPath
      
  # Test connection with FIDO2 settings endpoint (known to work)
  try {
    $testResponse = Invoke-HyprApi -Method GET -Endpoint "/rp/api/versioned/fido2/settings" -Config $config -TokenType RP
    Write-Verbose "Successfully connected to HYPR at $($config.BaseUrl)"
    return $config
  }
  catch {
    throw "Failed to connect to HYPR: $($_.Exception.Message)"
  }
}