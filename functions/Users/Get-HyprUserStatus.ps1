function Get-HyprUserStatus {
  param(
    [Parameter(Mandatory)]
    [string]$Username,
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
  
  if ([string]::IsNullOrWhiteSpace($Username)) {
    throw "Username cannot be empty"
  }
  
  $encodedUsername = [System.Web.HttpUtility]::UrlEncode($Username)
  $endpoint = "/rp/api/versioned/fido2/user/status?username=$encodedUsername"
  
  Write-Verbose "Checking user status for: $Username"
  
  try {
    $response = Invoke-HyprApi -Method GET -Endpoint $endpoint -Config $Config -TokenType RP
    
    # The API returns "authenticatorsRegistered" not "deviceCount"
    $result = [PSCustomObject]@{
      Username = $Username
      Registered = [bool]$response.registered
      DeviceCount = [int]$response.authenticatorsRegistered
      AppId = $response.appId
      LastChecked = Get-Date
    }
    
    Write-Verbose "User $Username - Registered: $($result.Registered), Devices: $($result.DeviceCount)"
    return $result
  }
  catch {
    throw "Failed to get user status for '$Username': $($_.Exception.Message)"
  }
}
