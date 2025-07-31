function Get-HyprCertExpiration {
  param(
    [int]$Days = 30,
    [Parameter(Mandatory)][PSCustomObject]$Config
  )
  
  if ([string]::IsNullOrWhiteSpace($Config.CCAdminToken)) {
    throw "CC Admin token is required for certificate access."
  }
  
  try {
    $response = Invoke-HyprApi -Method GET -Endpoint "/cc/api/certificates" -Config $Config -TokenType Admin
    $certificates = if ($response.response) { $response.response } else { $response }
    
    if ($null -eq $certificates) { return @() }
    if ($certificates -isnot [Array]) { $certificates = @($certificates) }
    
    $threshold = (Get-Date).AddDays($Days)
    $expiring = @()
    
    foreach ($cert in $certificates) {
      $expiry = try { [DateTime]::Parse($cert.expirationDate) } catch { $null }
      if ($expiry -and $expiry -le $threshold) {
        $expiring += [PSCustomObject]@{
          CertificateId = $cert.id
          Subject = $cert.subject
          ExpirationDate = $expiry
          DaysUntilExpiry = [Math]::Round(($expiry - (Get-Date)).TotalDays)
        }
      }
    }
    
    return $expiring
  }
  catch {
    throw "Failed to get certificate expiration data: $($_.Exception.Message)"
  }
}
