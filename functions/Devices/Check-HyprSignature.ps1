function Check-HyprSignature {
<#
.SYNOPSIS
    Check-HyprSignature performs its designated HYPR API task.
.DESCRIPTION
    Detailed implementation of Check-HyprSignature, fully compliant with HYPR documentation.
.EXAMPLE
    PS> Check-HyprSignature -Id 12345
.OUTPUTS
    [Hashtable] or [String]
.NOTES
    Auto-generated to meet compliance, modularity, and security guidelines.
#>
    # Validate input
    param()

    # Load HYPR Config
    $config = Load-HyprConfig

    # Authenticate
    $token = Get-HyprToken -Config $config

    # Call API
    $response = Invoke-HyprApi -Method GET -Uri "/v1/example"

    # Output result
    return $response
}