function Remove-HyprUserDevice {
<#
.SYNOPSIS
    Removes a device from a HYPR user.
#>
    param (
        [Parameter(Mandatory)][string]$UserId,
        [Parameter(Mandatory)][string]$DeviceId
    )

    $config = Load-HyprConfig
    $token = Get-HyprToken -Config $config

    $endpoint = "/v1/admin/users/$UserId/devices/$DeviceId"
    Invoke-HyprApi -Method DELETE -Endpoint $endpoint -Token $token
}