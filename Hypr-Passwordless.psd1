# Fix the module exports
$moduleContent = Get-Content ".\Hypr-Passwordless.psm1" -Raw

# Add the missing exports
$newExports = @"

# Export all functions
Export-ModuleMember -Function @(
  'Load-HyprConfig',
  'Get-HyprToken',
  'Invoke-HyprApi',
  'Connect-Hypr',
  'Get-HyprUserStatus',
  'Get-HyprUserDevices',
  'Remove-HyprUser',
  'Remove-HyprUserDevice',
  'Get-HyprFIDO2Settings',
  'Get-HyprAuditLog',
  'Start-HyprAuthentication',
  'Get-HyprAuthenticationStatus',
  'New-HyprQRCode',
  'Get-HyprRecoveryPIN'
)
"@

$moduleContent + $newExports | Set-Content ".\Hypr-Passwordless.psm1" -Encoding UTF8

# Re-import the module
Import-Module ".\Hypr-Passwordless.psd1" -Force

# Now check exports
Get-Command -Module Hypr-Passwordless