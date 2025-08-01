function Get-HyprCertExpiration {
    param(
        [ValidateRange(1, 365)]
        [int]$Days = 30,
        [Parameter(Mandatory)]
        [PSCustomObject]$Config
    )
    
    Write-Verbose "Checking for certificates expiring within $Days days..."
    
    try {
        $allCertificates = Get-HyprCertificates -Config $Config -IncludeExpired
        
        if ($allCertificates.Count -eq 0) {
            Write-Verbose "No certificates found to check for expiration"
            return @()
        }
        
        $expiringCertificates = @()
        $cutoffDate = (Get-Date).AddDays($Days)
        
        foreach ($cert in $allCertificates) {
            if ($cert.NotAfter -and $cert.NotAfter -le $cutoffDate) {
                $daysUntilExpiry = [Math]::Floor(($cert.NotAfter - (Get-Date)).TotalDays)
                
                $expiringCert = [PSCustomObject]@{
                    Subject = $cert.Subject
                    Issuer = $cert.Issuer
                    ExpirationDate = $cert.NotAfter
                    DaysUntilExpiry = $daysUntilExpiry
                    IsExpired = $cert.IsExpired
                    Thumbprint = $cert.Thumbprint
                    CertificateType = $cert.CertificateType
                    Source = $cert.Source
                    UrgencyLevel = if ($daysUntilExpiry -lt 0) { "EXPIRED" }
                                  elseif ($daysUntilExpiry -lt 7) { "CRITICAL" }
                                  elseif ($daysUntilExpiry -lt 30) { "HIGH" }
                                  elseif ($daysUntilExpiry -lt 60) { "MEDIUM" }
                                  else { "LOW" }
                    RenewalRequired = $true
                    CheckedAt = Get-Date
                }
                
                $expiringCertificates += $expiringCert
            }
        }
        
        $sortedCertificates = $expiringCertificates | Sort-Object DaysUntilExpiry
        
        Write-Verbose "Found $($sortedCertificates.Count) certificates expiring within $Days days"
        return $sortedCertificates
        
    }
    catch {
        throw "Failed to check certificate expiration: $($_.Exception.Message)"
    }
}
