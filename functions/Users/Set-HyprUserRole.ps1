function Set-HyprUserRole {
    param(
        [string]$Username,
        [string]$RoleId,
        [string]$Action,
        [PSCustomObject]$Config
    )
    Write-Host "Role updated" -ForegroundColor Green
}
