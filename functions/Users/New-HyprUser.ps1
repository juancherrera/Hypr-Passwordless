function New-HyprUser {
  param(
    [Parameter(Mandatory)][string]$Username,
    [string]$DisplayName,
    [Parameter(Mandatory)][PSCustomObject]$Config
  )
  
  if (!$DisplayName) { $DisplayName = $Username }
  
  $body = @{
    username = $Username
    displayName = $DisplayName
    rpAppId = $Config.RPAppId
  }
  
  try {
    $response = Invoke-HyprApi -Method POST -Endpoint "/rp/api/versioned/fido2/user/create" -Config $Config -Body $body -TokenType RP
    
    Write-Host "User '$Username' created successfully" -ForegroundColor Green
    return $response
  }
  catch {
    throw "Failed to create user: $($_.Exception.Message)"
  }
}
