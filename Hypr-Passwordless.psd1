# 1. First, navigate to your local module directory (NOT Program Files)
cd "C:\src\Hypr-Passwordless"

# 2. Fix the corrupted .psd1 file
@'
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
    'Get-HyprRecoveryPIN'
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
'@ | Set-Content ".\Hypr-Passwordless.psd1" -Encoding UTF8

# 3. Import from local directory
Import-Module ".\Hypr-Passwordless.psd1" -Force

# 4. Test
Get-Command -Module Hypr-Passwordless

# 5. Test Load-HyprConfig
$config = Load-HyprConfig -Path "C:\src\HYPR\automation\config\hypr_connect_config.json"
$config