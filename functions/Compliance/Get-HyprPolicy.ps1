function Get-HyprPolicy {
  param(
    [string]$PolicyId,
    [Parameter(Mandatory)][PSCustomObject]$Config
  )
  
  if ([string]::IsNullOrWhiteSpace($Config.CCAdminToken)) {
    throw "CC Admin token is required for policy access."
  }
  
  $endpoint = if ($PolicyId) { "/cc/api/policies/$PolicyId" } else { "/cc/api/policies" }
  
  try {
    $response = Invoke-HyprApi -Method GET -Endpoint $endpoint -Config $Config -TokenType Admin
    $policies = if ($response.response) { $response.response } else { $response }
    
    if ($null -eq $policies) { return @() }
    if ($policies -isnot [Array]) { $policies = @($policies) }
    
    return $policies
  }
  catch {
    throw "Failed to retrieve policies: $($_.Exception.Message)"
  }
}
