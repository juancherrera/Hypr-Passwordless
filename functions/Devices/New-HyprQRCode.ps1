function New-HyprQRCode {
  <#
  .SYNOPSIS
      Creates a QR code for device registration.
  .DESCRIPTION
      Generates a QR code that users can scan to register their HYPR-enabled mobile device.
  .PARAMETER Username
      Username for device registration.
  .PARAMETER IncludeFallback
      Include fallback activation code.
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      $qr = New-HyprQRCode -Username "user@domain.com" -Config $config
  .OUTPUTS
      [PSCustomObject] QR code data object
  #>
  param(
    [Parameter(Mandatory)]
    [string]$Username,
          
    [bool]$IncludeFallback = $true,
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  $body = @{
    rpAppId               = $Config.RPAppId
    username              = $Username
    includeQRFallbackCode = $IncludeFallback
  }
      
  try {
    $response = Invoke-HyprApi -Method POST -Endpoint "/rp/versioned/client/qr/create" -Config $Config -Body $body -TokenType RP
    return $response
  }
  catch {
    throw "Failed to create QR code for $Username`: $($_.Exception.Message)"
  }
}