function Get-HyprCertificates {
  param([Parameter(Mandatory)][PSCustomObject]$Config)
  
  if ([string]::IsNullOrWhiteSpace($Config.CCAdminToken)) {
    throw "CC Admin token is required for certificate access."
  }
  
  try {
    $response = Invoke-HyprApi -Method GET -Endpoint "/cc/api/certificates" -Config $Config -TokenType Admin
    $certificates = if ($response.response) { $response.response } else { $response }
    
    if ($null -eq $certificates) { return @() }
    if ($certificates -isnot [Array]) { $certificates = @($certificates) }
    
    return $certificates
  }
  catch {
    throw "Failed to retrieve certificates: $($_.Exception.Message)"
  }
}
