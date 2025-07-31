function Start-HyprAuthentication {
  <#
  .SYNOPSIS
      Initiates an out-of-band authentication request.
  .DESCRIPTION
      Starts an authentication flow that sends a push notification to the user's device.
      Uses the proven working OOB authentication endpoint.
  .PARAMETER Username
      Username to authenticate.
  .PARAMETER TransactionText
      Custom text to display in the authentication request.
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      $auth = Start-HyprAuthentication -Username "user@domain.com" -TransactionText "Login approval" -Config $config
  .OUTPUTS
      [PSCustomObject] Authentication session with requestId for status checking
  #>
  param(
    [Parameter(Mandatory)]
    [string]$Username,
          
    [string]$TransactionText = "Please authenticate this request",
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  if ([string]::IsNullOrWhiteSpace($Username)) {
    throw "Username cannot be empty"
  }
      
  # Generate unique request ID
  $requestId = [guid]::NewGuid().ToString()
      
  $body = @{
    rpAppId         = $Config.RPAppId
    username        = $Username
    transactionText = $TransactionText
    requestId       = $requestId
  }
      
  Write-Verbose "Starting authentication for $Username with request ID: $requestId"
      
  try {
    $response = Invoke-HyprApi -Method POST -Endpoint "/rp/api/oob/client/authentication/requests" -Config $Config -Body $body -TokenType RP
          
    # Enhance response with metadata
    $authSession = [PSCustomObject]@{
      RequestId       = $requestId
      Username        = $Username
      TransactionText = $TransactionText
      StartedAt       = Get-Date
      Status          = "INITIATED"
      Response        = $response
    }
          
    Write-Host "✓ Authentication request sent to $Username" -ForegroundColor Green
    Write-Host "  Request ID: $requestId" -ForegroundColor Gray
    Write-Host "  Transaction: $TransactionText" -ForegroundColor Gray
          
    return $authSession
          
  }
  catch {
    $errorMsg = $_.Exception.Message
          
    if ($errorMsg -like "*404*") {
      throw "User '$Username' not found or not enrolled in HYPR: $errorMsg"
    }
    elseif ($errorMsg -like "*400*") {
      throw "Invalid authentication request. Check username and RP App configuration: $errorMsg"
    }
    else {
      throw "Failed to start authentication for '$Username': $errorMsg"
    }
  }
}