function Load-HyprConfig {
  <#
  .SYNOPSIS
      Loads HYPR configuration from JSON file or creates default config.
  .DESCRIPTION
      Loads HYPR configuration from a JSON file. If no path specified, looks for 
      config in module directory. Creates default config if none exists.
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
      
  if (-not (Test-Path $Path)) {
    # Create default config
    $configDir = Split-Path $Path -Parent
    if (-not (Test-Path $configDir)) {
      New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }
          
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
    Write-Warning "Created default config at $Path. Please update with your HYPR details."
  }
      
  try {
    $config = Get-Content $Path -Raw | ConvertFrom-Json
          
    # Validate required fields
    $requiredFields = @('BaseUrl', 'RPAppId')
    foreach ($field in $requiredFields) {
      if ([string]::IsNullOrWhiteSpace($config.$field)) {
        throw "Required field '$field' is missing or empty in configuration"
      }
    }
          
    return $config
  }
  catch {
    throw "Failed to load HYPR configuration from $Path`: $($_.Exception.Message)"
  }
}