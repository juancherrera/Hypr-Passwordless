function Get-HyprToken {
  <#
  .SYNOPSIS
      Validates and returns HYPR API tokens from configuration.
  .DESCRIPTION
      Validates HYPR API tokens and returns the appropriate token based on the token type requested.
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
    throw "No $TokenType token configured. Please update your configuration file."
  }
      
  if ($token -like "*your-*" -or $token -like "*token*") {
    throw "$TokenType token appears to be a placeholder. Please provide a real token."
  }
      
  return $token
}