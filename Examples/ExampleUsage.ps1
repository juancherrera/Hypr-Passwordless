# Import the module
Import-Module .\Hypr-Passwordless.psd1 -Force

# Connect to HYPR
try {
  $config = Connect-Hypr -ConfigPath ".\config\hypr_config.json"
  Write-Host "✓ Connected to HYPR successfully" -ForegroundColor Green
}
catch {
  Write-Error "Failed to connect: $($_.Exception.Message)"
  exit 1
}

# Test connection
$healthy = Test-HyprConnection -Config $config
if (-not $healthy) {
  Write-Warning "Connection issues detected"
}

# Get FIDO2 settings
$fido2Settings = Get-HyprFIDO2Settings -Config $config
Write-Host "Current RP App: $($fido2Settings.rpAppId)" -ForegroundColor Cyan

# Check user status
$username = "user@domain.com"
try {
  $userStatus = Get-HyprUserStatus -Username $username -Config $config
  Write-Host "User $username enrolled: $($userStatus.registered)" -ForegroundColor $(if ($userStatus.registered) { "Green" } else { "Yellow" })
    
  if ($userStatus.registered) {
    $devices = Get-HyprUserDevices -Username $username -Config $config
    Write-Host "Device count: $($devices.Count)" -ForegroundColor Cyan
  }
}
catch {
  Write-Warning "Could not check user $username`: $($_.Exception.Message)"
}

# Start authentication (if user is enrolled)
if ($userStatus.registered) {
  try {
    $auth = Start-HyprAuthentication -Username $username -TransactionText "PowerShell Module Test" -Config $config
    Write-Host "Authentication started. Session ID: $($auth.requestId)" -ForegroundColor Green
        
    # Check status
    Start-Sleep -Seconds 2
    $status = Get-HyprAuthenticationStatus -SessionId $auth.requestId -Config $config
    Write-Host "Authentication status: $($status.response.state[-1].value)" -ForegroundColor Cyan
  }
  catch {
    Write-Warning "Authentication test failed: $($_.Exception.Message)"
  }
}

# Get audit logs (requires admin token)
try {
  $audit = Get-HyprAuditLog -Days 7 -Config $config
  Write-Host "Audit entries (last 7 days): $($audit.Count)" -ForegroundColor Cyan
}
catch {
  Write-Warning "Could not get audit logs (may require admin token): $($_.Exception.Message)"
}