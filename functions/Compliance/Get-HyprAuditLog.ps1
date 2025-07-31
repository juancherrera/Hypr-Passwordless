function Get-HyprAuditLog {
  <#
  .SYNOPSIS
      Gets HYPR audit log entries.
  .DESCRIPTION
      Retrieves audit log entries for compliance and security monitoring.
  .PARAMETER Days
      Number of days to retrieve (default: 30).
  .PARAMETER EventType
      Filter by specific event type.
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      $audit = Get-HyprAuditLog -Days 7 -Config $config
  .OUTPUTS
      [PSCustomObject[]] Array of audit log entries
  #>
  param(
    [int]$Days = 30,
          
    [string]$EventType,
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  $startDate = (Get-Date).AddDays(-$Days).ToString("yyyy-MM-dd")
  $endDate = (Get-Date).ToString("yyyy-MM-dd")
  $endpoint = "/cc/api/audit?startDate=$startDate&endDate=$endDate"
      
  if ($EventType) {
    $endpoint += "&eventType=$EventType"
  }
      
  try {
    $response = Invoke-HyprApi -Method GET -Endpoint $endpoint -Config $Config -TokenType Admin
          
    if ($response.response) {
      return $response.response
    }
    else {
      return $response
    }
  }
  catch {
    throw "Failed to get audit log: $($_.Exception.Message)"
  }
}