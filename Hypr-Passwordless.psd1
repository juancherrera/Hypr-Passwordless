@{
  RootModule        = 'Hypr-Passwordless.psm1'
  ModuleVersion     = '2.0.0'
  GUID              = '12345678-abcd-1234-ef00-0123456789ab'
  Author            = 'Juan C. Herrera'
  CompanyName       = 'Holpop.io'
  Description       = 'Automates HYPR Identity & Passwordless Management using HYPR REST API with working endpoints.'
  PowerShellVersion = '5.1'

  FunctionsToExport = @(
    'Load-HyprConfig',
    'Get-HyprToken',
    'Invoke-HyprApi',
    'Connect-Hypr',
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
    'Test-HyprConnection'
  )
  CmdletsToExport   = @()
  VariablesToExport = @()
  AliasesToExport   = @()

  PrivateData       = @{
    PSData = @{
      Tags       = @('HYPR', 'IAM', 'Passwordless', 'Security', 'FIDO2')
      ProjectUri = 'https://github.com/juancherrera/Hypr-Passwordless'
    }
  }
}
