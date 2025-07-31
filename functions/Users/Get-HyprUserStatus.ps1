function Get-HyprUserStatus {
  <#
  .SYNOPSIS
      Gets HYPR user enrollment status.
  .DESCRIPTION
      Retrieves the enrollment status and device count for a specific user.
  .PARAMETER Username
      Username to check.
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      $status = Get-HyprUserStatus -Username "user@domain.com" -Config $config
  .OUTPUTS
      [PSCustomObject] User status object with registration and device count
  #>
  param(
    [Parameter(Mandatory)]
    [string]$Username,
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  $encodedUsername = ConvertTo-UrlEncoded -InputString $Username
  $endpoint = "/rp/api/versioned/fido2/user/status?username=$encodedUsername"
      
  try {
    $response = Invoke-HyprApi -Method GET -Endpoint $endpoint -Config $Config -TokenType RP
          
    if ($response.response) {
      return $response.response
    }
    else {
      return $response
    }
  }
  catch {
    throw "Failed to get user status for $Username`: $($_.Exception.Message)"
  }
}