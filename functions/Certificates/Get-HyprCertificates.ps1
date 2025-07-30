function Get-HyprCertificates {
<#
.SYNOPSIS
    Gets HYPR certificates.
#>
    $config = Load-HyprConfig
    $token = Get-HyprToken -Config $config
    Invoke-HyprApi -Method GET -Endpoint "/v1/admin/certificates" -Token $token
}