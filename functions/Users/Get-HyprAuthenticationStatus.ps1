function Get-HyprAuthenticationStatus {
  <#
  .SYNOPSIS
      Checks the status of an ongoing authentication request.
  .DESCRIPTION
      Polls an authentication session to check if the user has responded.
      Returns detailed status information including state progression.
  .PARAMETER SessionId
      Authentication session ID from Start-HyprAuthentication.
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      $status = Get-HyprAuthenticationStatus -SessionId $auth.RequestId -Config $config
  .OUTPUTS
      [PSCustomObject] Authentication status with current state and history
  #>
  param(
    [Parameter(Mandatory)]
    [string]$SessionId,
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  if ([string]::IsNullOrWhiteSpace($SessionId)) {
    throw "SessionId cannot be empty"
  }
      
  Write-Verbose "Checking authentication status for session: $SessionId"
      
  try {
    $response = Invoke-HyprApi -Method GET -Endpoint "/rp/api/oob/client/authentication/requests/$SessionId" -Config $Config -TokenType RP
          
    # Parse response and extract current state
    $currentState = "UNKNOWN"
    $stateHistory = @()
          
    if ($response.response -and $response.response.state) {
      $stateHistory = $response.response.state
      $currentState = $stateHistory[-1].value  # Get latest state
    }
          
    # Determine if authentication is complete
    $isComplete = $currentState -in @("COMPLETED", "FAILED", "TIMEOUT", "CANCELLED")
    $isSuccess = $currentState -eq "COMPLETED"
          
    $statusResult = [PSCustomObject]@{
      SessionId    = $SessionId
      CurrentState = $currentState
      IsComplete   = $isComplete
      IsSuccess    = $isSuccess
      StateHistory = $stateHistory
      CheckedAt    = Get-Date
      Response     = $response
    }
          
    Write-Verbose "Authentication status: $currentState (Complete: $isComplete, Success: $isSuccess)"
    return $statusResult
          
  }
  catch {
    $errorMsg = $_.Exception.Message
          
    if ($errorMsg -like "*404*") {
      throw "Authentication session '$SessionId' not found or expired: $errorMsg"
    }
    else {
      throw "Failed to get authentication status for session '$SessionId': $errorMsg"
    }
  }
}