function Get-HyprPolicy {
    param(
        [string]$PolicyId,
        [Parameter(Mandatory)]
        [PSCustomObject]$Config,
        [switch]$IncludeInactive
    )
    
    if ([string]::IsNullOrWhiteSpace($Config.CCAdminToken)) {
        Write-Warning "CC Admin token required for policy access. Returning basic policy info from FIDO2 settings."
        
        try {
            $fido2Settings = Get-HyprFIDO2Settings -Config $Config
            
            return @([PSCustomObject]@{
                PolicyId = "FIDO2_DEFAULT"
                PolicyName = "Default FIDO2 Authentication Policy"
                Status = "ACTIVE"
                PolicyType = "AUTHENTICATION"
                UserVerification = $fido2Settings.UserVerification
                Attestation = $fido2Settings.Attestation
                Timeout = $fido2Settings.Timeout
                AuthenticatorSelection = $fido2Settings.AuthenticatorSelection
                Source = "FIDO2_SETTINGS"
                LastModified = "UNKNOWN"
                CheckedAt = Get-Date
                ComplianceLevel = if ($fido2Settings.UserVerification -eq "required") { "HIGH" } else { "MEDIUM" }
            })
        }
        catch {
            Write-Warning "Could not extract policy information: $($_.Exception.Message)"
            return @()
        }
    }
    
    Write-Verbose "Getting security policies from HYPR Control Center..."
    
    try {
        $endpoints = @(
            "/cc/api/policies",
            "/cc/api/admin/policies",
            "/cc/api/security/policies",
            "/cc/api/authentication/policies"
        )
        
        if (![string]::IsNullOrWhiteSpace($PolicyId)) {
            $endpoints = $endpoints | ForEach-Object { "$_/$PolicyId" }
        }
        
        $allPolicies = @()
        
        foreach ($endpoint in $endpoints) {
            try {
                $response = Invoke-HyprApi -Method GET -Endpoint $endpoint -Config $Config -TokenType Admin
                
                if ($response) {
                    $policies = if ($response.policies) { $response.policies }
                              elseif ($response.response) { $response.response }
                              elseif ($response -is [Array]) { $response }
                              else { @($response) }
                    
                    foreach ($policy in $policies) {
                        if ($policy -and ($IncludeInactive -or $policy.status -eq "ACTIVE")) {
                            $policyObj = [PSCustomObject]@{
                                PolicyId = $policy.id
                                PolicyName = $policy.name
                                Status = $policy.status
                                PolicyType = $policy.type
                                Description = $policy.description
                                CreatedDate = $policy.createdDate
                                LastModified = $policy.lastModified
                                CreatedBy = $policy.createdBy
                                ModifiedBy = $policy.modifiedBy
                                Version = $policy.version
                                IsDefault = $policy.isDefault
                                Priority = $policy.priority
                                Conditions = $policy.conditions
                                Actions = $policy.actions
                                Source = "CONTROL_CENTER"
                                Endpoint = $endpoint
                                CheckedAt = Get-Date
                                ComplianceLevel = switch ($policy.type) {
                                    "AUTHENTICATION" { if ($policy.status -eq "ACTIVE") { "HIGH" } else { "LOW" } }
                                    "SECURITY" { if ($policy.status -eq "ACTIVE") { "HIGH" } else { "MEDIUM" } }
                                    "ACCESS_CONTROL" { if ($policy.status -eq "ACTIVE") { "MEDIUM" } else { "LOW" } }
                                    default { "UNKNOWN" }
                                }
                            }
                            
                            $allPolicies += $policyObj
                        }
                    }
                    
                    Write-Verbose "Retrieved policies from $endpoint"
                    break
                }
            }
            catch {
                Write-Verbose "Endpoint $endpoint not available: $($_.Exception.Message)"
                continue
            }
        }
        
        if ($allPolicies.Count -eq 0) {
            Write-Verbose "No policies found via CC API, extracting from FIDO2 settings..."
            $fallbackConfig = @{ 
                BaseUrl = $Config.BaseUrl
                CCAdminToken = $null
                RPAppToken = $Config.RPAppToken
                RPAppId = $Config.RPAppId 
            }
            return Get-HyprPolicy -Config $fallbackConfig
        }
        
        Write-Verbose "Retrieved $($allPolicies.Count) policies from Control Center"
        return $allPolicies
        
    }
    catch {
        Write-Warning "Failed to get policies from Control Center: $($_.Exception.Message)"
        return @()
    }
}
