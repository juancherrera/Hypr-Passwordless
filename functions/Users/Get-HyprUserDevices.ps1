function Get-HyprUserDevices {
  <#
  .SYNOPSIS
      Gets all devices registered to a HYPR user.
  .DESCRIPTION
      Retrieves detailed information about all FIDO2 devices registered to a user.
      Uses the proven working FIDO2 user devices endpoint.
  .PARAMETER Username
      Username to query for devices.
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      $devices = Get-HyprUserDevices -Username "user@domain.com" -Config $config
  .OUTPUTS
      [PSCustomObject[]] Array of device objects with keyId, createDate, etc.
  #>
  param(
    [Parameter(Mandatory)]
    [string]$Username,
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  if ([string]::IsNullOrWhiteSpace($Username)) {
    throw "Username cannot be empty"
  }
      
  # URL encode username
  $encodedUsername = ConvertTo-UrlEncoded -InputString $Username
  $endpoint = "/rp/api/versioned/fido2/user?username=$encodedUsername"
      
  Write-Verbose "Getting devices for user: $Username"
      
  try {
    $response = Invoke-HyprApi -Method GET -Endpoint $endpoint -Config $Config -TokenType RP
          
    # Handle different response formats
    $devices = if ($response.response) { $response.response } else { $response }
          
    # Ensure we return an array
    if ($null -eq $devices) {
      Write-Verbose "No devices found for user $Username"
      return @()
    }
          
    # Convert single device to array
    if ($devices -isnot [Array]) {
      $devices = @($devices)
    }
          
    Write-Verbose "Found $($devices.Count) device(s) for user $Username"
          
    # Enhance device objects with additional metadata
    $enhancedDevices = @()
    foreach ($device in $devices) {
      $enhancedDevice = [PSCustomObject]@{
        Username      = $Username
        KeyId         = $device.keyId
        CreateDate    = $device.createDate
        DeviceType    = $device.authenticatorAttachment
        PublicKeyType = $device.publicKeyType
        PublicKeyAlg  = $device.publicKeyAlg
        SignCounter   = $device.signCounter
        IsLocked      = $device.locked
        UserHandle    = $device.userHandle
        DisplayName   = $device.displayName
        AAID          = $device.aaid
        RetrievedAt   = Get-Date
      }
      $enhancedDevices += $enhancedDevice
    }
          
    return $enhancedDevices
          
  }
  catch {
    $errorMsg = $_.Exception.Message
    Write-Verbose "Failed to get devices for $Username`: $errorMsg"
          
    # Context-specific error handling
    if ($errorMsg -like "*404*" -or $errorMsg -like "*Not Found*") {
      throw "User '$Username' not found or has no devices: $errorMsg"
    }
    elseif ($errorMsg -like "*403*" -or $errorMsg -like "*Forbidden*") {
      throw "Insufficient permissions to view devices for '$Username': $errorMsg"
    }
    else {
      throw "Failed to get devices for '$Username': $errorMsg"
    }
  }
}