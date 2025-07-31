function Remove-HyprUser {
    param(
        [string]$Username,
        [PSCustomObject]$Config,
        [switch]$Force
    )
    
    if (-not $Force) {
        $confirm = Read-Host "Remove user '$Username'? (y/N)"
        if ($confirm -ne 'y') { return }
    }
    
    try {
        $response = Invoke-HyprApi -Method DELETE -Endpoint "/rp/api/versioned/fido2/user?username=$Username" -Config $Config -TokenType RP
        Write-Host "User removed successfully" -ForegroundColor Green
        return $response
    }
    catch {
        throw "Failed to remove user $Username"
    }
}
