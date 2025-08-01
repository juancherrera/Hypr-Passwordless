function Get-HyprCertificates {
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$Config,
        [switch]$IncludeExpired
    )
    
    if ([string]::IsNullOrWhiteSpace($Config.CCAdminToken)) {
        Write-Warning "CC Admin token required for certificate monitoring. Returning basic SSL check."
        
        try {
            $uri = [System.Uri]$Config.BaseUrl
            $tcpClient = New-Object System.Net.Sockets.TcpClient($uri.Host, 443)
            $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream())
            $sslStream.AuthenticateAsClient($uri.Host)
            
            $cert = $sslStream.RemoteCertificate
            $cert2 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($cert)
            
            $sslStream.Close()
            $tcpClient.Close()
            
            return @([PSCustomObject]@{
                Subject = $cert2.Subject
                Issuer = $cert2.Issuer
                NotBefore = $cert2.NotBefore
                NotAfter = $cert2.NotAfter
                Thumbprint = $cert2.Thumbprint
                DaysUntilExpiry = [Math]::Floor(($cert2.NotAfter - (Get-Date)).TotalDays)
                IsExpired = $cert2.NotAfter -lt (Get-Date)
                Source = "SSL_ENDPOINT_CHECK"
                CheckedAt = Get-Date
            })
        }
        catch {
            Write-Warning "Could not check SSL certificate: $($_.Exception.Message)"
            return @()
        }
    }
    
    Write-Verbose "Getting certificates from HYPR Control Center..."
    
    try {
        $endpoints = @(
            "/cc/api/certificates",
            "/cc/api/system/certificates", 
            "/cc/api/admin/certificates"
        )
        
        $allCertificates = @()
        
        foreach ($endpoint in $endpoints) {
            try {
                $response = Invoke-HyprApi -Method GET -Endpoint $endpoint -Config $Config -TokenType Admin
                
                if ($response -and $response.certificates) {
                    $certificates = $response.certificates
                }
                elseif ($response -and $response -is [Array]) {
                    $certificates = $response
                }
                else {
                    $certificates = @($response)
                }
                
                foreach ($cert in $certificates) {
                    if ($cert) {
                        $expiryDate = if ($cert.expiryDate) { 
                            try { [DateTime]$cert.expiryDate } catch { Get-Date }
                        } else { Get-Date }
                        
                        $daysUntilExpiry = [Math]::Floor(($expiryDate - (Get-Date)).TotalDays)
                        $isExpired = $expiryDate -lt (Get-Date)
                        
                        if ($IncludeExpired -or !$isExpired) {
                            $allCertificates += [PSCustomObject]@{
                                Subject = $cert.subject
                                Issuer = $cert.issuer
                                SerialNumber = $cert.serialNumber
                                NotBefore = $cert.notBefore
                                NotAfter = $expiryDate
                                Thumbprint = $cert.thumbprint
                                DaysUntilExpiry = $daysUntilExpiry
                                IsExpired = $isExpired
                                CertificateType = $cert.type
                                Source = "CONTROL_CENTER"
                                Endpoint = $endpoint
                                CheckedAt = Get-Date
                            }
                        }
                    }
                }
                
                Write-Verbose "Retrieved certificates from $endpoint"
                break
            }
            catch {
                Write-Verbose "Endpoint $endpoint not available: $($_.Exception.Message)"
                continue
            }
        }
        
        if ($allCertificates.Count -eq 0) {
            Write-Verbose "No certificates found via API, performing SSL endpoint check..."
            $fallbackConfig = @{ 
                BaseUrl = $Config.BaseUrl
                CCAdminToken = $null 
            }
            return Get-HyprCertificates -Config $fallbackConfig
        }
        
        Write-Verbose "Retrieved $($allCertificates.Count) certificates from Control Center"
        return $allCertificates
        
    }
    catch {
        Write-Warning "Failed to get certificates from Control Center: $($_.Exception.Message)"
        return @()
    }
}
