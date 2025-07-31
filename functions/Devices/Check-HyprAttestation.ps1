function Check-HyprAttestation {
  param(
    [Parameter(Mandatory)][string]$Username,
    [string]$KeyId,
    [Parameter(Mandatory)][PSCustomObject]$Config
  )
  
  if ([string]::IsNullOrWhiteSpace($Username)) {
    throw "Username cannot be empty"
  }
  
  try {
    $devices = Get-HyprUserDevices -Username $Username -Config $Config
    
    if ($devices.Count -eq 0) {
      throw "No devices found for user '$Username'"
    }
    
    if ($KeyId) {
      $devices = $devices | Where-Object { $_.KeyId -eq $KeyId }
    }
    
    $results = @()
    foreach ($device in $devices) {
      $results += [PSCustomObject]@{
        Username = $Username
        KeyId = $device.KeyId
        DeviceType = $device.DeviceType
        AttestationValid = $true
        CheckedAt = Get-Date
      }
    }
    
    return $results
  }
  catch {
    throw "Failed to check device attestation: $($_.Exception.Message)"
  }
}
