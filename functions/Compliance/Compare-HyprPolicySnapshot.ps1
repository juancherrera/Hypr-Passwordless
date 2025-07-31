function Compare-HyprPolicySnapshot {
  param(
    [Parameter(Mandatory)][PSCustomObject]$BaselineSnapshot,
    [Parameter(Mandatory)][PSCustomObject]$CurrentSnapshot,
    [Parameter(Mandatory)][PSCustomObject]$Config
  )
  
  if ([string]::IsNullOrWhiteSpace($Config.CCAdminToken)) {
    throw "CC Admin token is required for policy comparison."
  }
  
  try {
    $comparison = [PSCustomObject]@{
      BaselineId = $BaselineSnapshot.Id
      CurrentId = $CurrentSnapshot.Id
      ComparedAt = Get-Date
      Changes = @()
    }
    return $comparison
  }
  catch {
    throw "Failed to compare policy snapshots: $($_.Exception.Message)"
  }
}
