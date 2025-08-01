@{
  RootModule = "Hypr-Passwordless.psm1"
  ModuleVersion = "2.0.0"
  GUID = "12345678-abcd-1234-ef00-0123456789ab"
  Author = "Juan C. Herrera"
  Description = "HYPR Identity & Passwordless Management"
  PowerShellVersion = "5.1"
  FunctionsToExport = @(
    "Load-HyprConfig", "Get-HyprToken", "Invoke-HyprApi", "Connect-Hypr",
    "Get-HyprUserStatus", "Get-HyprUserDevices", "Remove-HyprUser",
    "Remove-HyprUserDevice", "Get-HyprFIDO2Settings", "Get-HyprAuditLog",
    "Start-HyprAuthentication", "Get-HyprAuthenticationStatus",
    "New-HyprQRCode", "Get-HyprRecoveryPIN", "Get-HyprAdminSettings", "Get-HyprSystemHealth"
  )
}


