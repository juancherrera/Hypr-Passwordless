function Remove-HyprUser {
  <#
  .SYNOPSIS
      Removes a user from HYPR.
  .DESCRIPTION
      Completely removes a user and all their devices from HYPR.
  .PARAMETER Username
      Username to remove.
  .PARAMETER Config
      HYPR configuration object.
  .PARAMETER Force
      Skip confirmation prompt.
  .EXAMPLE
      Remove-HyprUser -Username "user@domain.com" -Config $config
  .OUTPUTS
      [PSCustomObject] Removal result
  #>
  param(
    [Parameter(Mandatory)]
    [string]$Username,
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config,
          
    [switch]$Force
  )
      
  if (-not $Force) {
    $confirm = Read-Host "Are you sure you want to remove user '$Username' and all their devices? (y/N)"
    if ($confirm -ne 'y' -and $confirm -ne 'Y') {
      Write-Host "User removal cancelled." -ForegroundColor Yellow
      return
    }
  }
      
  $encodedUsername = ConvertTo-UrlEncoded -InputString $Username
  $endpoint = "/rp/api/versioned/fido2/user?username=$encodedUsername"
      
  try {
    $response = Invoke-HyprApi -Method DELETE -Endpoint $endpoint -Config $Config -TokenType RP
    Write-Host "✓ User '$Username' removed successfully" -ForegroundColor Green
    return $response
  }
  catch {
    throw "Failed to remove user $Username`: $($_.Exception.Message)"
  }
}