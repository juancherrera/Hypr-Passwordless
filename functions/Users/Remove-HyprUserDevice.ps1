function Remove-HyprUserDevice {
  <#
  .SYNOPSIS
      Removes a specific device from a HYPR user.
  .DESCRIPTION
      Removes a single device identified by keyId from a user's registered devices.
  .PARAMETER Username
      Username who owns the device.
  .PARAMETER KeyId
      Device key ID to remove.
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      Remove-HyprUserDevice -Username "user@domain.com" -KeyId "device123" -Config $config
  .OUTPUTS
      [PSCustomObject] Removal result
  #>
  param(
    [Parameter(Mandatory)]
    [string]$Username,
          
    [Parameter(Mandatory)]
    [string]$KeyId,
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  $encodedUsername = ConvertTo-UrlEncoded -InputString $Username
  $endpoint = "/rp/api/versioned/fido2/user?username=$encodedUsername&keyId=$KeyId"
      
  try {
    $response = Invoke-HyprApi -Method DELETE -Endpoint $endpoint -Config $Config -TokenType RP
    Write-Host "✓ Device '$KeyId' removed from user '$Username'" -ForegroundColor Green
    return $response
  }
  catch {
    throw "Failed to remove device $KeyId from user $Username`: $($_.Exception.Message)"
  }
}