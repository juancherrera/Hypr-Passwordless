function Get-HyprRecoveryPIN {
  <#
  .SYNOPSIS
      Retrieves or reveals a user's recovery PIN.
  .DESCRIPTION
      Gets the recovery PIN for a user, which can be used for account recovery when devices are lost.
  .PARAMETER Username
      Username to get recovery PIN for.
  .PARAMETER Reveal
      Whether to reveal the actual PIN (requires additional permissions).
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      $pin = Get-HyprRecoveryPIN -Username "user@domain.com" -Config $config
  .OUTPUTS
      [PSCustomObject] Recovery PIN object
  #>
  param(
    [Parameter(Mandatory)]
    [string]$Username,
          
    [switch]$Reveal,
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  $endpoint = if ($Reveal) { "/rp/api/versioned/recoverypin/reveal" } else { "/rp/api/versioned/recoverypin/retrieve" }
      
  $body = @{
    username = $Username
    rpAppId  = $Config.RPAppId
  }
      
  try {
    $response = Invoke-HyprApi -Method POST -Endpoint $endpoint -Config $Config -Body $body -TokenType RP
    return $response
  }
  catch {
    throw "Failed to get recovery PIN for $Username`: $($_.Exception.Message)"
  }
}