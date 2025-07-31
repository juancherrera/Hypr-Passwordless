function Get-HyprUserStatus {
  <#
  .SYNOPSIS
      Gets HYPR user enrollment status using proven working endpoint.
  .DESCRIPTION
      Retrieves enrollment status and device count for a specific user using
      the verified working FIDO2 user status endpoint.
  .PARAMETER Username
      Username to check (will be URL encoded automatically).
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      $status = Get-HyprUserStatus -Username "user@domain.com" -Config $config
  .OUTPUTS
      [PSCustomObject] User status with registered (bool) and deviceCount (int) properties
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
      
  # URL encode username for safe API call
  $encodedUsername = ConvertTo-UrlEncoded -InputString $Username
  $endpoint = "/rp/api/versioned/fido2/user/status?username=$encodedUsername"
      
  Write-Verbose "Checking user status for: $Username"
      
  try {
    $response = Invoke-HyprApi -Method GET -Endpoint $endpoint -Config $Config -TokenType RP
          
    # Handle different response formats
    $userStatus = if ($response.response) { $response.response } else { $response }
          
    # Validate response has expected properties
    if ($null -eq $userStatus) {
      throw "Empty response from HYPR API"
    }
          
    # Ensure boolean conversion for registered field
    $registered = if ($userStatus.registered -is [bool]) { 
      $userStatus.registered 
    }
    else { 
      [bool]::Parse($userStatus.registered.ToString())
    }
          
    # Ensure integer conversion for deviceCount
    $deviceCount = if ($userStatus.deviceCount -is [int]) { 
      $userStatus.deviceCount 
    }
    else { 
      [int]::Parse($userStatus.deviceCount.ToString())
    }
          
    $result = [PSCustomObject]@{
      Username    = $Username
      Registered  = $registered
      DeviceCount = $deviceCount
      LastChecked = Get-Date
    }
          
    Write-Verbose "User $Username - Registered: $registered, Devices: $deviceCount"
    return $result
          
  }
  catch {
    $errorMsg = $_.Exception.Message
    Write-Verbose "Failed to get user status for $Username`: $errorMsg"
          
    # Provide context-specific error messages
    if ($errorMsg -like "*404*" -or $errorMsg -like "*Not Found*") {
      throw "User '$Username' not found in HYPR or endpoint doesn't exist: $errorMsg"
    }
    elseif ($errorMsg -like "*403*" -or $errorMsg -like "*Forbidden*") {
      throw "Insufficient permissions to check user status for '$Username': $errorMsg"
    }
    else {
      throw "Failed to get user status for '$Username': $errorMsg"
    }
  }
}