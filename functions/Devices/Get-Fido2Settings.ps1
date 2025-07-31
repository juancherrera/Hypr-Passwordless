function Get-HyprFIDO2Settings {
  <#
  .SYNOPSIS
      Gets FIDO2 settings for the current RP application.
  .DESCRIPTION
      Retrieves FIDO2 configuration settings including security policies and authentication requirements.
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      $settings = Get-HyprFIDO2Settings -Config $config
  .OUTPUTS
      [PSCustomObject] FIDO2 settings object
  #>
  param(
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  try {
    $response = Invoke-HyprApi -Method GET -Endpoint "/rp/api/versioned/fido2/settings" -Config $Config -TokenType RP
          
    if ($response.response) {
      return $response.response
    }
    else {
      return $response
    }
  }
  catch {
    throw "Failed to get FIDO2 settings: $($_.Exception.Message)"
  }
}