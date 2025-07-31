# ============================================================================
# HYPR PowerShell Module v3.0 - Production Ready with Corrected API Implementation
# Compatible with HYPR API v8.0+ and PowerShell 5.1+
# ============================================================================

# Module Manifest (Hypr-Passwordless.psd1)
@{
  RootModule        = 'Hypr-Passwordless.psm1'
  ModuleVersion     = '3.0.0'
  GUID              = '12345678-abcd-1234-ef00-0123456789ab'
  Author            = 'Juan C. Herrera'
  CompanyName       = 'Holpop.io'
  Description       = 'Production-ready HYPR Identity & Passwordless Management with corrected API v8.0+ endpoints'
  PowerShellVersion = '5.1'
  RequiredModules   = @()
  
  FunctionsToExport = @(
    'Connect-Hypr',
    'Test-HyprConnection',
    'Get-HyprUserStatus',
    'Get-HyprUserDevices',
    'Start-HyprAuthentication',
    'Wait-HyprAuthentication',
    'Get-HyprAuthenticationStatus',
    'New-HyprQRCode',
    'Get-HyprRecoveryPIN',
    'Remove-HyprUser',
    'Remove-HyprUserDevice',
    'Get-HyprFIDO2Settings',
    'Get-HyprAuditLog',
    'Set-HyprConfiguration'
  )
  
  PrivateData       = @{
    PSData = @{
      Tags       = @('HYPR', 'FIDO2', 'Passwordless', 'Security', 'Authentication')
      ProjectUri = 'https://github.com/juancherrera/Hypr-Passwordless'
    }
  }
}
