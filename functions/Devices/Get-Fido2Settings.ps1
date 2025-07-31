function Get-HyprFIDO2Settings {
  <#
  .SYNOPSIS
      Gets FIDO2 configuration settings for the current RP application.
  .DESCRIPTION
      Retrieves FIDO2 security settings using the proven working endpoint.
      This is one of the most reliable endpoints for testing connectivity.
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      $settings = Get-HyprFIDO2Settings -Config $config
  .OUTPUTS
      [PSCustomObject] FIDO2 settings including security policies and RP App info
  #>
  param(
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  Write-Verbose "Getting FIDO2 settings for RP App: $($Config.RPAppId)"
      
  try {
    $response = Invoke-HyprApi -Method GET -Endpoint "/rp/api/versioned/fido2/settings" -Config $Config -TokenType RP
          
    # Handle different response formats
    $settings = if ($response.response) { $response.response } else { $response }
          
    if ($null -eq $settings) {
      throw "Empty FIDO2 settings response from HYPR"
    }
          
    # Enhance settings object with metadata
    $enhancedSettings = [PSCustomObject]@{
      RPAppId                = $settings.rpAppId
      DisplayName            = $settings.displayName
      Origin                 = $settings.origin
      UserVerification       = $settings.userVerification
      Attestation            = $settings.attestation
      Timeout                = $settings.timeout
      AuthenticatorSelection = $settings.authenticatorSelection
      RetrievedAt            = Get-Date
      AllSettings            = $settings  # Include raw response for advanced users
    }
          
    Write-Verbose "Successfully retrieved FIDO2 settings for $($settings.rpAppId)"
    return $enhancedSettings
          
  }
  catch {
    throw "Failed to get FIDO2 settings: $($_.Exception.Message)"
  }
}