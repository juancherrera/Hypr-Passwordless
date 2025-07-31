function Remove-HyprDevice {
  param(
    [Parameter(Mandatory)][string]$DeviceId,
    [Parameter(Mandatory)][PSCustomObject]$Config,
    [switch]$Force
  )
  
  if (-not $Force) {
    $confirm = Read-Host "Remove device '$DeviceId'? (y/N)"
    if ($confirm -ne 'y') { return }
  }
  
  try {
    $response = Invoke-HyprApi -Method DELETE -Endpoint "/rp/api/versioned/fido2/device/$DeviceId" -Config $Config -TokenType RP
    
    Write-Host "Device '$DeviceId' removed successfully" -ForegroundColor Green
    return $response
  }
  catch {
    throw "Failed to remove device: $($_.Exception.Message)"
  }
}
