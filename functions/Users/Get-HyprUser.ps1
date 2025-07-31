function Get-HyprUser {
  <#
  .SYNOPSIS
      Gets comprehensive HYPR user information.
  .DESCRIPTION
      Retrieves user status, device information, and enrollment details.
      Combines multiple API calls for complete user profile.
  .PARAMETER Username
      Specific username to query.
  .PARAMETER IncludeDevices
      Include detailed device information.
  .PARAMETER Config
      HYPR configuration object.
  .EXAMPLE
      $user = Get-HyprUser -Username "user@domain.com" -IncludeDevices -Config $config
  .OUTPUTS
      [PSCustomObject] Complete user profile with status and devices
  #>
  param(
    [Parameter(Mandatory)]
    [string]$Username,
          
    [switch]$IncludeDevices,
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config
  )
      
  if ([string]::IsNullOrWhiteSpace($Username)) {
    throw "Username cannot be empty"
  }
      
  Write-Verbose "Getting complete user information for: $Username"
      
  try {
    # Get user status
    $userStatus = Get-HyprUserStatus -Username $Username -Config $Config
          
    # Get devices if requested and user is registered
    $devices = @()
    if ($IncludeDevices -and $userStatus.Registered) {
      try {
        $devices = Get-HyprUserDevices -Username $Username -Config $Config
      }
      catch {
        Write-Warning "Could not retrieve devices for $Username`: $($_.Exception.Message)"
      }
    }
          
    # Build comprehensive user object
    $userProfile = [PSCustomObject]@{
      Username         = $Username
      IsRegistered     = $userStatus.Registered
      DeviceCount      = $userStatus.DeviceCount
      EnrollmentStatus = if ($userStatus.Registered) { "ENROLLED" } else { "NOT_ENROLLED" }
      Devices          = $devices
      HasDeviceDetails = $IncludeDevices
      LastChecked      = Get-Date
      Summary          = @{
        TotalDevices = $devices.Count
        DeviceTypes  = ($devices | Group-Object DeviceType | ForEach-Object { "$($_.Name): $($_.Count)" }) -join ", "
        OldestDevice = ($devices | Sort-Object CreateDate | Select-Object -First 1)?.CreateDate
        NewestDevice = ($devices | Sort-Object CreateDate -Descending | Select-Object -First 1)?.CreateDate
      }
    }
          
    Write-Verbose "User profile complete - Registered: $($userProfile.IsRegistered), Devices: $($userProfile.DeviceCount)"
    return $userProfile
          
  }
  catch {
    throw "Failed to get user information for '$Username': $($_.Exception.Message)"
  }
}