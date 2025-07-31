function Remove-HyprUser {
  <#
  .SYNOPSIS
      Removes a user and all their devices from HYPR.
  .DESCRIPTION
      Completely removes a user from HYPR, including all registered devices.
      Includes safety confirmation unless -Force is used.
  .PARAMETER Username
      Username to remove from HYPR.
  .PARAMETER Config
      HYPR configuration object.
  .PARAMETER Force
      Skip confirmation prompt for automated scenarios.
  .EXAMPLE
      Remove-HyprUser -Username "user@domain.com" -Config $config
  .OUTPUTS
      [PSCustomObject] Removal operation result
  #>
  param(
    [Parameter(Mandatory)]
    [string]$Username,
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config,
          
    [switch]$Force
  )
      
  if ([string]::IsNullOrWhiteSpace($Username)) {
    throw "Username cannot be empty"
  }
      
  # Safety confirmation
  if (-not $Force) {
    Write-Host "WARNING: This will permanently remove user '$Username' and ALL their devices from HYPR." -ForegroundColor Yellow
    $confirm = Read-Host "Are you sure you want to proceed? Type 'yes' to continue"
    if ($confirm -ne 'yes') {
      Write-Host "User removal cancelled." -ForegroundColor Yellow
      return [PSCustomObject]@{
        Username  = $Username
        Action    = "CANCELLED"
        Reason    = "User cancelled operation"
        Timestamp = Get-Date
      }
    }
  }
      
  $encodedUsername = ConvertTo-UrlEncoded -InputString $Username
  $endpoint = "/rp/api/versioned/fido2/user?username=$encodedUsername"
      
  Write-Verbose "Removing user: $Username"
      
  try {
    $response = Invoke-HyprApi -Method DELETE -Endpoint $endpoint -Config $Config -TokenType RP
          
    $result = [PSCustomObject]@{
      Username  = $Username
      Action    = "REMOVED"
      Success   = $true
      Timestamp = Get-Date
      Response  = $response
    }
          
    Write-Host "✓ User '$Username' and all devices removed successfully" -ForegroundColor Green
    return $result
          
  }
  catch {
    $errorMsg = $_.Exception.Message
          
    $result = [PSCustomObject]@{
      Username  = $Username
      Action    = "FAILED"
      Success   = $false
      Error     = $errorMsg
      Timestamp = Get-Date
    }
          
    if ($errorMsg -like "*404*") {
      throw "User '$Username' not found in HYPR: $errorMsg"
    }
    elseif ($errorMsg -like "*403*") {
      throw "Insufficient permissions to remove user '$Username': $errorMsg"
    }
    else {
      throw "Failed to remove user '$Username': $errorMsg"
    }
  }
}