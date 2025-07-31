function Get-HyprRecoveryPIN {
  <#
  .SYNOPSIS
      Retrieves or reveals a user's recovery PIN.
  .DESCRIPTION
      Gets the recovery PIN for account recovery when devices are lost.
      Use -Reveal to get the actual PIN (requires additional permissions).
  .PARAMETER Username
      Username to get recovery PIN for.
  .PARAMETER Reveal
      Whether to reveal the actual PIN value.
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      $pin = Get-HyprRecoveryPIN -Username "user@domain.com" -Config $config
      $actualPin = Get-HyprRecoveryPIN -Username "user@domain.com" -Reveal -Config $config
  .OUTPUTS
      [PSCustomObject] Recovery PIN information
  #>
  param(
    [Parameter(Mandatory)]
    [string]$Username,
          
    [switch]$Reveal,
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  if ([string]::IsNullOrWhiteSpace($Username)) {
    throw "Username cannot be empty"
  }
      
  $endpoint = if ($Reveal) { "/rp/api/versioned/recoverypin/reveal" } else { "/rp/api/versioned/recoverypin/retrieve" }
      
  $body = @{
    username = $Username
    rpAppId  = $Config.RPAppId
  }
      
  Write-Verbose "$(if($Reveal){'Revealing'}else{'Retrieving'}) recovery PIN for user: $Username"
      
  try {
    $response = Invoke-HyprApi -Method POST -Endpoint $endpoint -Config $Config -Body $body -TokenType RP
          
    $pinResult = [PSCustomObject]@{
      Username       = $Username
      HasRecoveryPIN = $true
      RecoveryPIN    = if ($Reveal -and $response.pin) { $response.pin } else { "[HIDDEN]" }
      IsRevealed     = $Reveal
      RetrievedAt    = Get-Date
      Response       = $response
    }
          
    Write-Host "✓ Recovery PIN $(if($Reveal){'revealed'}else{'retrieved'}) for $Username" -ForegroundColor Green
    if ($Reveal -and $response.pin) {
      Write-Host "  Recovery PIN: $($response.pin)" -ForegroundColor Yellow
    }
          
    return $pinResult
          
  }
  catch {
    $errorMsg = $_.Exception.Message
          
    if ($errorMsg -like "*404*") {
      throw "User '$Username' not found or has no recovery PIN: $errorMsg"
    }
    elseif ($errorMsg -like "*403*") {
      throw "Insufficient permissions to $(if($Reveal){'reveal'}else{'retrieve'}) recovery PIN for '$Username': $errorMsg"
    }
    else {
      throw "Failed to $(if($Reveal){'reveal'}else{'retrieve'}) recovery PIN for '$Username': $errorMsg"
    }
  }
}