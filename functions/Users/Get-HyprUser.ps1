function Get-HyprUser {
  <#
  .SYNOPSIS
      Gets HYPR user information and enrollment status.
  .DESCRIPTION
      Retrieves user information, enrollment status, and device details from HYPR.
  .PARAMETER Username
      Username to query.
  .PARAMETER Status
      Filter by enrollment status: 'ENROLLED', 'NOT_ENROLLED', or 'ALL'.
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      Get-HyprUser -Username "user@domain.com" -Config $config
      Get-HyprUser -Status "ENROLLED" -Config $config
  .OUTPUTS
      [PSCustomObject[]] Array of user objects with enrollment details
  #>
  param(
    [string]$Username,
          
    [ValidateSet('ENROLLED', 'NOT_ENROLLED', 'ALL')]
    [string]$Status = 'ALL',
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  if ($Username) {
    # Get specific user
    try {
      $userStatus = Get-HyprUserStatus -Username $Username -Config $Config
      $devices = if ($userStatus.registered) {
        Get-HyprUserDevices -Username $Username -Config $Config
      }
      else {
        @()
      }
              
      return [PSCustomObject]@{
        Username    = $Username
        Registered  = $userStatus.registered
        DeviceCount = $userStatus.deviceCount
        Devices     = $devices
        Status      = if ($userStatus.registered) { "ENROLLED" } else { "NOT_ENROLLED" }
      }
    }
    catch {
      throw "Failed to get user $Username`: $($_.Exception.Message)"
    }
  }
  else {
    # This would require admin API access or user enumeration
    throw "User enumeration requires a specific username. Use Get-HyprUserStatus for individual users."
  }
}