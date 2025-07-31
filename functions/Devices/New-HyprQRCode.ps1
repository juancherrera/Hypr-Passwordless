function New-HyprQRCode {
  <#
  .SYNOPSIS
      Creates a QR code for HYPR device registration.
  .DESCRIPTION
      Generates a QR code that users can scan with the HYPR mobile app to register their device.
      Optionally includes a fallback activation code for manual entry.
  .PARAMETER Username
      Username for device registration.
  .PARAMETER IncludeFallback
      Include fallback activation code for manual entry.
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      $qr = New-HyprQRCode -Username "user@domain.com" -Config $config
  .OUTPUTS
      [PSCustomObject] QR code data with image and fallback code
  #>
  param(
    [Parameter(Mandatory)]
    [string]$Username,
          
    [bool]$IncludeFallback = $true,
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  if ([string]::IsNullOrWhiteSpace($Username)) {
    throw "Username cannot be empty"
  }
      
  $body = @{
    rpAppId               = $Config.RPAppId
    username              = $Username
    includeQRFallbackCode = $IncludeFallback
  }
      
  Write-Verbose "Creating QR code for user: $Username (Include fallback: $IncludeFallback)"
      
  try {
    $response = Invoke-HyprApi -Method POST -Endpoint "/rp/versioned/client/qr/create" -Config $Config -Body $body -TokenType RP
          
    # Enhance QR response with metadata
    $qrResult = [PSCustomObject]@{
      Username         = $Username
      QRCodeData       = $response.qrCode
      FallbackCode     = $response.activationCode
      ExpiresAt        = if ($response.expirationTime) { 
        try { [DateTimeOffset]::FromUnixTimeMilliseconds($response.expirationTime).DateTime }
        catch { $response.expirationTime }
      }
      else { $null }
      CreatedAt        = Get-Date
      IncludesFallback = $IncludeFallback
      Response         = $response
    }
          
    Write-Host "✓ QR code created for $Username" -ForegroundColor Green
    if ($IncludeFallback -and $response.activationCode) {
      Write-Host "  Fallback code: $($response.activationCode)" -ForegroundColor Gray
    }
          
    return $qrResult
          
  }
  catch {
    $errorMsg = $_.Exception.Message
          
    if ($errorMsg -like "*400*") {
      throw "Invalid QR code request. Check username and RP App configuration: $errorMsg"
    }
    else {
      throw "Failed to create QR code for '$Username': $errorMsg"
    }
  }
}