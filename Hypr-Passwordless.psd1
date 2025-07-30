@{
  RootModule        = 'Hypr-Passwordless.psm1'
  ModuleVersion     = '1.0.0'
  GUID              = '12345678-abcd-1234-ef00-0123456789ab'
  Author            = 'Juan C. Herrera'
  CompanyName       = 'Holpop.io'
  Description       = 'Automates HYPR Identity & Passwordless Management using HYPR API.'
  PowerShellVersion = '5.1'

  FunctionsToExport = @('*')
  CmdletsToExport   = @()
  VariablesToExport = @()
  AliasesToExport   = @()

  PrivateData       = @{
    PSData = @{
      Tags       = @('HYPR', 'IAM', 'Passwordless', 'Security')
      ProjectUri = 'https://github.com/juancherrera/Hypr-Passwordless'
    }
  }
}
