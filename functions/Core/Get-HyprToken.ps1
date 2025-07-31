function Get-HyprToken {
  <#
  .SYNOPSIS
      Validates and returns HYPR API tokens from configuration.
  .DESCRIPTION
      Validates HYPR API tokens and returns the appropriate token based on type.
      Performs token format validation and provides clear error messages.
  .PARAMETER Config
      HYPR configuration object from Load-HyprConfig.
  .PARAMETER TokenType
      Type of token to retrieve: 'RP' for RP App token, 'Admin' for CC Admin token.
  .EXAMPLE
      $token = Get-HyprToken -Config $config -TokenType "RP"
  .OUTPUTS
      [String] Valid HYPR API token
  #>
  param(
    [Parameter(Mandatory)]
    [PSCustomObject]$Config,
          
    [ValidateSet('RP', 'Admin')]
    [string]$TokenType = 'RP'
  )
      
  $token = if ($TokenType -eq 'Admin') { $Config.CCAdminToken } else { $Config.RPAppToken }
      
  if ([string]::IsNullOrWhiteSpace($token)) {
    throw "No $TokenType token configured. Please add a valid token to your configuration file."
  }
      
  # Validate token format
  if ($token -like "*your-*" -or $token -like "*token*" -or $token -like "*placeholder*") {
    throw "$TokenType token appears to be a placeholder. Please provide a real HYPR token starting with 'hypap-'."
  }
      
  if ($token -notlike "hypap-*") {
    Write-Warning "$TokenType token doesn't start with 'hypap-'. Ensure you're using a valid HYPR API token."
  }
      
  Write-Verbose "Retrieved valid $TokenType token (length: $($token.Length))"
  return $token
}