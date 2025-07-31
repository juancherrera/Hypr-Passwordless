function Start-HyprAuthentication {
  <#
  .SYNOPSIS
      Initiates an out-of-band authentication request.
  .DESCRIPTION
      Starts an authentication flow for a user that will send a push notification to their registered device.
  .PARAMETER Username
      Username to authenticate.
  .PARAMETER TransactionText
      Text to display in the authentication request.
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      $auth = Start-HyprAuthentication -Username "user@domain.com" -TransactionText "Login approval" -Config $config
  .OUTPUTS
      [PSCustomObject] Authentication session object
  #>
  param(
    [Parameter(Mandatory)]
    [string]$Username,
          
    [string]$TransactionText = "Please authenticate this request",
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  $body = @{
    rpAppId         = $Config.RPAppId
    username        = $Username
    transactionText = $TransactionText
    requestId       = [guid]::NewGuid().ToString()
  }
      
  try {
    $response = Invoke-HyprApi -Method POST -Endpoint "/rp/api/oob/client/authentication/requests" -Config $Config -Body $body -TokenType RP
    return $response
  }
  catch {
    throw "Failed to start authentication for $Username`: $($_.Exception.Message)"
  }
}