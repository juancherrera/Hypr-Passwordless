# HYPR PowerShell Module v2.1 - Production Ready with Working Endpoints
# Compatible with PowerShell 5.1, 7.x, and all editions

# Set module-level variables
$script:ModuleRoot = $PSScriptRoot

# Ensure TLS 1.2+
try {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  if ([System.Enum]::GetNames([Net.SecurityProtocolType]) -contains 'Tls13') {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
  }
}
catch {
  Write-Warning "Could not configure TLS settings"
}

# URL encoding function
function ConvertTo-UrlEncoded {
  param([string]$InputString)
  if ([string]::IsNullOrEmpty($InputString)) { return "" }
  return [Uri]::EscapeDataString($InputString)
}

# Load all function files with proper error handling
$functionPaths = @(
  "$PSScriptRoot\functions\Core\*.ps1",
  "$PSScriptRoot\functions\Users\*.ps1",
  "$PSScriptRoot\functions\Devices\*.ps1",
  "$PSScriptRoot\functions\Compliance\*.ps1"
)

foreach ($path in $functionPaths) {
  if (Test-Path (Split-Path $path -Parent)) {
    Get-ChildItem -Path $path -File -ErrorAction SilentlyContinue | ForEach-Object {
      try {
        . $_.FullName
        Write-Verbose "Loaded function from $($_.Name)"
      }
      catch {
        Write-Warning "Failed to load function from $($_.FullName): $($_.Exception.Message)"
      }
    }
  }
}

# Export all working functions
Export-ModuleMember -Function @(
  'Load-HyprConfig',
  'Get-HyprToken', 
  'Invoke-HyprApi',
  'Connect-Hypr',
  'Test-HyprConnection',
  'Get-HyprUser',
  'Get-HyprUserStatus',
  'Get-HyprUserDevices',
  'Remove-HyprUser',
  'Remove-HyprUserDevice',
  'Get-HyprFIDO2Settings',
  'Get-HyprAuditLog',
  'Start-HyprAuthentication',
  'Get-HyprAuthenticationStatus',
  'New-HyprQRCode',
  'Get-HyprRecoveryPIN',
  'Get-HyprAdminSettings',
  'Get-HyprSystemHealth'
)
