function Load-HyprConfig {
  <#
  .SYNOPSIS
      Loads HYPR configuration from JSON file or creates default config.
  .DESCRIPTION
      Loads HYPR configuration from a JSON file. Creates default config if none exists.
      Validates all required fields and provides helpful error messages.
  .PARAMETER Path
      Path to the HYPR configuration JSON file.
  .EXAMPLE
      $config = Load-HyprConfig -Path "C:\config\hypr.json"
  .OUTPUTS
      [PSCustomObject] HYPR configuration object
  #>
  param(
    [string]$Path = "$script:ModuleRoot\config\hypr_config.json"
  )
      
  # Create config directory if it doesn't exist
  $configDir = Split-Path $Path -Parent
  if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    Write-Verbose "Created config directory: $configDir"
  }
      
  if (-not (Test-Path $Path)) {
    # Create default config with clear instructions
    $defaultConfig = @{
      BaseUrl        = "https://your-tenant.hypr.com"
      RPAppId        = "ProdExt"
      RPAppToken     = ""
      CCAdminToken   = ""
      TimeoutSeconds = 60
      RetryAttempts  = 3
      LogFile        = "hypr-module.log"
    }
          
    $defaultConfig | ConvertTo-Json -Depth 3 | Set-Content $Path -Encoding UTF8
    Write-Warning "Created default config at $Path"
    Write-Warning "Please update BaseUrl, RPAppId, and add your tokens before using the module."
    return $defaultConfig
  }
      
  try {
    $config = Get-Content $Path -Raw | ConvertFrom-Json
          
    # Validate required fields
    $requiredFields = @('BaseUrl', 'RPAppId')
    $missingFields = @()
          
    foreach ($field in $requiredFields) {
      if ([string]::IsNullOrWhiteSpace($config.$field)) {
        $missingFields += $field
      }
    }
          
    if ($missingFields.Count -gt 0) {
      throw "Missing required configuration fields: $($missingFields -join ', '). Please update your config file."
    }
          
    # Validate BaseUrl format
    if ($config.BaseUrl -notmatch '^https?://') {
      throw "BaseUrl must start with http:// or https://"
    }
          
    # Warn about missing tokens
    if ([string]::IsNullOrWhiteSpace($config.RPAppToken)) {
      Write-Warning "RPAppToken is empty. Most functions will not work without a valid token."
    }
          
    Write-Verbose "Successfully loaded HYPR configuration from $Path"
    return $config
          
  }
  catch {
    throw "Failed to load HYPR configuration from $Path`: $($_.Exception.Message)"
  }
}