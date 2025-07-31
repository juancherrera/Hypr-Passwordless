function Remove-HyprUserDevice {
  <#
  .SYNOPSIS
      Removes a specific device from a HYPR user.
  .DESCRIPTION
      Deletes a single device identified by KeyId from a user's registered devices.
      More targeted than Remove-HyprUser which removes all devices.
  .PARAMETER Username
      Username who owns the device.
  .PARAMETER KeyId
      Device key ID to remove (from Get-HyprUserDevices).
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      Remove-HyprUserDevice -Username "user@domain.com" -KeyId "device123" -Config $config
  .OUTPUTS
      [PSCustomObject] Device removal result
  #>
  param(
    [Parameter(Mandatory)]
    [string]$Username,
          
    [Parameter(Mandatory)]
    [string]$KeyId,
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  if ([string]::IsNullOrWhiteSpace($Username)) {
    throw "Username cannot be empty"
  }
      
  if ([string]::IsNullOrWhiteSpace($KeyId)) {
    throw "KeyId cannot be empty"
  }
      
  $encodedUsername = ConvertTo-UrlEncoded -InputString $Username
  $endpoint = "/rp/api/versioned/fido2/user?username=$encodedUsername&keyId=$KeyId"
      
  Write-Verbose "Removing device $KeyId from user $Username"
      
  try {
    $response = Invoke-HyprApi -Method DELETE -Endpoint $endpoint -Config $Config -TokenType RP
          
    $result = [PSCustomObject]@{
      Username  = $Username
      KeyId     = $KeyId
      Action    = "DEVICE_REMOVED"
      Success   = $true
      Timestamp = Get-Date
      Response  = $response
    }
          
    Write-Host "✓ Device '$KeyId' removed from user '$Username'" -ForegroundColor Green
    return $result
          
  }
  catch {
    $errorMsg = $_.Exception.Message
          
    if ($errorMsg -like "*404*") {
      throw "User '$Username' or device '$KeyId' not found: $errorMsg"
    }
    elseif ($errorMsg -like "*403*") {
      throw "Insufficient permissions to remove device for '$Username': $errorMsg"
    }
    else {
      throw "Failed to remove device '$KeyId' from user '$Username': $errorMsg"
    }
  }
}