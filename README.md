# HYPR Passwordless PowerShell Module

## Overview

The HYPR Passwordless PowerShell Module provides secure, reusable, and fully documented tools to automate identity, device, policy, and compliance workflows using the official HYPR API.

It is designed for identity engineers, security analysts, and automation specialists managing enterprise-grade passwordless authentication.

Supported regulatory frameworks:
- NIST 800-63B
- HIPAA
- SOX
- CMMC
- ISO 27001
- Zero Trust architectures

## Features

- Secure configuration and token-based authentication
- User provisioning, enrollment, and offboarding
- Device lifecycle and attestation management
- Certificate expiration checks and rotation
- Compliance policy drift and audit log monitoring
- Role management and privilege drift cleanup
- Registration throughput reporting
- Fully modular design with reusable API logic
- Full Pester test coverage

## Folder Structure

C:\src\Hypr-Passwordless  
├───config  
├───functions  
│   ├───Certificates  
│   ├───Compliance  
│   ├───Core  
│   ├───Devices  
│   └───Users  
└───tests  
    ├───Compliance  
    ├───Core  
    └───Users

## Installation

```powershell
# Clone the repository
git clone https://github.com/juancherrera/Hypr-Passwordless.git

# Import the module
Import-Module ./functions/Core/Import-HyprModule.ps1
```

## Configuration

```powershell
# Load configuration from a JSON file
$HyprConfig = Load-HyprConfig -Path "C:\path\to\hyprconfig.json"
```

```json
{
  "TenantUrl": "https://your-hypr-domain.hypr.com",
  "ClientId": "your-client-id",
  "ClientSecret": "your-secret"
}
```

## Usage Examples

```powershell
# Get all enrolled users
Get-HyprUser -Status "ENROLLED"

# Check certificate expiration
Get-HyprCertificates | Where-Object { $_.expirationDate -lt (Get-Date).AddDays(30) }

# Reset a user's device
Reset-HyprUser -UserId "abc123"

# Export and compare policy snapshots
Export-HyprPolicySnapshot -Path "snapshot.json"
Compare-HyprPolicySnapshot -Old "baseline.json" -New "snapshot.json"
```

## Testing

```powershell
# Run all Pester tests
Invoke-Pester ./tests
```

## Contributing

- Follow the naming convention Verb-HyprNoun  
- Include full comment-based help with .SYNOPSIS, .EXAMPLE, and .OUTPUTS  
- Include a matching .Tests.ps1 file in the tests/ folder  
- Use Invoke-HyprApi for all HTTP requests

## License

MIT License. Use at your own risk.

## Maintainer

Juan C. Herrera  
Identity and Access Management Identity Professional  
jherrera@holpop.io.com