function Export-HyprPolicySnapshot {
  param(
    [string]$OutputPath,
    [Parameter(Mandatory)][PSCustomObject]$Config
  )
  
  if ([string]::IsNullOrWhiteSpace($Config.CCAdminToken)) {
    throw "CC Admin token is required for policy export."
  }
  
  try {
    $response = Invoke-HyprApi -Method GET -Endpoint "/cc/api/policies" -Config $Config -TokenType Admin
    $snapshot = [PSCustomObject]@{
      Id = [guid]::NewGuid().ToString()
      ExportedAt = Get-Date
      Policies = $response.response
    }
    
    if (![string]::IsNullOrWhiteSpace($OutputPath)) {
      $snapshot | ConvertTo-Json -Depth 10 | Set-Content -Path $OutputPath -Encoding UTF8
    }
    
    return $snapshot
  }
  catch {
    throw "Failed to export policy snapshot: $($_.Exception.Message)"
  }
}
