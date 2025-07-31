function Get-HyprAuthenticationStatus {
  <#
  .SYNOPSIS
      Checks the status of an authentication request.
  .DESCRIPTION
      Polls the status of an ongoing authentication request using the session ID.
  .PARAMETER SessionId
      Authentication session ID from Start-HyprAuthentication.
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      $status = Get-HyprAuthenticationStatus -SessionId $auth.requestId -Config $config
  .OUTPUTS
      [PSCustomObject] Authentication status object
  #>
  param(
    [Parameter(Mandatory)]
    [string]$SessionId,
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  try {
    $response = Invoke-HyprApi -Method GET -Endpoint "/rp/api/oob/client/authentication/requests/$SessionId" -Config $Config -TokenType RP
    return $response
  }
  catch {
    throw "Failed to get authentication status for session $SessionId`: $($_.Exception.Message)"
  }
}