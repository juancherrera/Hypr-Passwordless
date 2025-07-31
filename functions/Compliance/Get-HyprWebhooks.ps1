function Get-HyprWebhooks {
  param([Parameter(Mandatory)][PSCustomObject]$Config)
  
  if ([string]::IsNullOrWhiteSpace($Config.CCAdminToken)) {
    throw "CC Admin token is required for webhook access."
  }
  
  try {
    $response = Invoke-HyprApi -Method GET -Endpoint "/cc/api/webhooks" -Config $Config -TokenType Admin
    $webhooks = if ($response.response) { $response.response } else { $response }
    
    if ($null -eq $webhooks) { return @() }
    if ($webhooks -isnot [Array]) { $webhooks = @($webhooks) }
    
    return $webhooks
  }
  catch {
    throw "Failed to retrieve webhook configurations: $($_.Exception.Message)"
  }
}
