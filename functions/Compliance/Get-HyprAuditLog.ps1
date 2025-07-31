function Get-HyprAuditLog {
  <#
  .SYNOPSIS
      Retrieves HYPR audit log entries for compliance monitoring.
  .DESCRIPTION
      Gets audit log entries for a specified time period. Requires CC Admin token.
      Useful for compliance reporting and security monitoring.
  .PARAMETER Days
      Number of days to retrieve (default: 30, max: 90).
  .PARAMETER EventType
      Filter by specific event type (optional).
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      $audit = Get-HyprAuditLog -Days 7 -Config $config
      $loginEvents = Get-HyprAuditLog -Days 1 -EventType "LOGIN_SUCCESS" -Config $config
  .OUTPUTS
      [PSCustomObject[]] Array of audit log entries
  #>
  param(
    [ValidateRange(1, 90)]
    [int]$Days = 30,
          
    [string]$EventType,
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  # Validate CC Admin token exists
  if ([string]::IsNullOrWhiteSpace($Config.CCAdminToken)) {
    throw "CC Admin token is required for audit log access. Please configure CCAdminToken in your config file."
  }
      
  $startDate = (Get-Date).AddDays(-$Days).ToString("yyyy-MM-dd")
  $endDate = (Get-Date).ToString("yyyy-MM-dd")
  $endpoint = "/cc/api/audit?startDate=$startDate&endDate=$endDate"
      
  if (![string]::IsNullOrWhiteSpace($EventType)) {
    $endpoint += "&eventType=$EventType"
  }
      
  Write-Verbose "Getting audit logs from $startDate to $endDate$(if($EventType){" for event type: $EventType"})"
      
  try {
    $response = Invoke-HyprApi -Method GET -Endpoint $endpoint -Config $Config -TokenType Admin
          
    # Handle different response formats
    $auditEntries = if ($response.response) { $response.response } else { $response }
          
    if ($null -eq $auditEntries) {
      Write-Verbose "No audit entries found for the specified period"
      return @()
    }
          
    # Ensure array format
    if ($auditEntries -isnot [Array]) {
      $auditEntries = @($auditEntries)
    }
          
    # Enhance audit entries with parsed timestamps
    $enhancedEntries = @()
    foreach ($entry in $auditEntries) {
      $enhancedEntry = [PSCustomObject]@{
        EventType       = $entry.eventType
        Username        = $entry.namedUser
        Timestamp       = $entry.timestamp
        IPAddress       = $entry.ipAddress
        UserAgent       = $entry.userAgent
        Result          = $entry.result
        Details         = $entry.details
        SessionId       = $entry.sessionId
        RequestId       = $entry.requestId
        ParsedTimestamp = if ($entry.timestamp) { 
          try { [DateTimeOffset]::FromUnixTimeMilliseconds($entry.timestamp).DateTime } 
          catch { $entry.timestamp }
        }
        else { $null }
        RetrievedAt     = Get-Date
      }
      $enhancedEntries += $enhancedEntry
    }
          
    Write-Verbose "Retrieved $($enhancedEntries.Count) audit entries"
    return $enhancedEntries
          
  }
  catch {
    $errorMsg = $_.Exception.Message
          
    if ($errorMsg -like "*403*") {
      throw "CC Admin token lacks permissions for audit log access: $errorMsg"
    }
    elseif ($errorMsg -like "*401*") {
      throw "CC Admin token is invalid or expired: $errorMsg"
    }
    else {
      throw "Failed to retrieve audit log: $errorMsg"
    }
  }
}