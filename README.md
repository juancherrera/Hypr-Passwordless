<#
# HYPR Passwordless PowerShell Module v2.0

## Quick Start

1. **Import the module:**
```powershell
Import-Module .\Hypr-Passwordless.psd1 -Force
```

2. **Configure your HYPR connection:**
```powershell
# This creates a default config file you need to edit
$config = Load-HyprConfig -Path ".\config\hypr_config.json"
```

3. **Edit the config file with your HYPR details:**
```json
{
  "BaseUrl": "https://your-tenant.hypr.com",
  "RPAppId": "ProdExt",
  "RPAppToken": "hypap-your-rp-token-here",
  "CCAdminToken": "hypap-your-admin-token-here",
  "TimeoutSeconds": 60,
  "RetryAttempts": 3,
  "LogFile": "hypr-module.log"
}
```

4. **Connect and test:**
```powershell
$config = Connect-Hypr
Test-HyprConnection -Config $config
```

## Core Functions

### User Management
- `Get-HyprUserStatus` - Check if user is enrolled
- `Get-HyprUserDevices` - Get user's registered devices  
- `Remove-HyprUser` - Remove user and all devices
- `Remove-HyprUserDevice` - Remove specific device

### Authentication
- `Start-HyprAuthentication` - Initiate push authentication
- `Get-HyprAuthenticationStatus` - Check auth status
- `New-HyprQRCode` - Create device registration QR code
- `Get-HyprRecoveryPIN` - Get user recovery PIN

### Configuration & Monitoring
- `Get-HyprFIDO2Settings` - Get security settings
- `Get-HyprAuditLog` - Get compliance audit logs
- `Test-HyprConnection` - Health check

## Examples

```powershell
# Check user enrollment
$status = Get-HyprUserStatus -Username "user@domain.com" -Config $config
if ($status.registered) {
    $devices = Get-HyprUserDevices -Username "user@domain.com" -Config $config
    Write-Host "User has $($devices.Count) devices registered"
}

# Start authentication
$auth = Start-HyprAuthentication -Username "user@domain.com" -TransactionText "Login approval" -Config $config
$status = Get-HyprAuthenticationStatus -SessionId $auth.requestId -Config $config

# Get security settings
$settings = Get-HyprFIDO2Settings -Config $config
Write-Host "User verification: $($settings.userVerification)"

# Create QR code for registration
$qr = New-HyprQRCode -Username "newuser@domain.com" -Config $config
```

## Token Requirements

- **RP App Token:** Required for all user operations, authentication, and device management
- **CC Admin Token:** Required for audit logs and advanced admin functions

Get tokens from your HYPR Control Center:
1. Go to your RP Application (e.g., ProdExt)
2. Navigate to Advanced Config > Access Tokens
3. Create new token and copy the `hypap-` token value

## Error Handling

All functions include comprehensive error handling with specific error messages for:
- Authentication failures (401)
- Permission issues (403) 
- Rate limiting (429)
- Server errors (500)
- Network timeouts

## Testing

Run the included Pester tests:
```powershell
Invoke-Pester .\tests\ -Recurse
```