function Invoke-HyprApi {
  <#
  .SYNOPSIS
      Base wrapper for HYPR API calls with error handling and retry logic.
  .DESCRIPTION
      Executes HTTP requests to HYPR API endpoints with comprehensive error handling,
      retry logic, and proper authentication headers.
  .PARAMETER Method
      HTTP method (GET, POST, PUT, DELETE).
  .PARAMETER Endpoint
      API endpoint path (e.g., "/rp/api/versioned/fido2/settings").
  .PARAMETER Config
      HYPR configuration object from Load-HyprConfig.
  .PARAMETER Body
      Request body for POST/PUT operations.
  .PARAMETER TokenType
      Token type to use: 'RP' or 'Admin'.
  .EXAMPLE
      $result = Invoke-HyprApi -Method GET -Endpoint "/rp/api/versioned/fido2/settings" -Config $config
  .OUTPUTS
      [PSCustomObject] API response object
  #>
  param(
    [Parameter(Mandatory)]
    [ValidateSet('GET', 'POST', 'PUT', 'DELETE', 'PATCH')]
    [string]$Method,
          
    [Parameter(Mandatory)]
    [string]$Endpoint,
          
    [Parameter(Mandatory)]
    [PSCustomObject]$Config,
          
    [object]$Body = $null,
          
    [ValidateSet('RP', 'Admin')]
    [string]$TokenType = 'RP'
  )
      
  $token = Get-HyprToken -Config $Config -TokenType $TokenType
  $baseUrl = $Config.BaseUrl.TrimEnd('/')
  $uri = "$baseUrl$Endpoint"
      
  $headers = @{
    'Authorization' = "Bearer $token"
    'Accept'        = 'application/json'
    'Cache-Control' = 'no-cache'
    'User-Agent'    = 'HYPR-PowerShell-Module/2.0'
  }
      
  if ($Method -in @('POST', 'PUT', 'PATCH')) {
    $headers['Content-Type'] = 'application/json'
  }
      
  $retryAttempts = if ($Config.RetryAttempts) { $Config.RetryAttempts } else { 3 }
  $timeoutSeconds = if ($Config.TimeoutSeconds) { $Config.TimeoutSeconds } else { 60 }
      
  for ($attempt = 1; $attempt -le $retryAttempts; $attempt++) {
    try {
      $requestParams = @{
        Uri         = $uri
        Method      = $Method
        Headers     = $headers
        TimeoutSec  = $timeoutSeconds
        ErrorAction = 'Stop'
      }
              
      if ($Body -and $Method -in @('POST', 'PUT', 'PATCH')) {
        $requestParams.Body = $Body | ConvertTo-Json -Depth 10 -Compress
      }
              
      $response = Invoke-RestMethod @requestParams
              
      # Check HYPR-specific response format
      if ($response.status -and $response.status.responseCode -and $response.status.responseCode -ne 200) {
        throw "HYPR API Error [$($response.status.responseCode)]: $($response.status.responseMessage)"
      }
              
      return $response
              
    }
    catch {
      $statusCode = $null
      if ($_.Exception.Response) {
        try {
          $statusCode = [int]$_.Exception.Response.StatusCode
        }
        catch { }
      }
              
      $errorMessage = $_.Exception.Message
              
      # Handle specific HTTP status codes
      switch ($statusCode) {
        400 { throw "Bad Request: Check request format and parameters. $errorMessage" }
        401 { throw "Unauthorized: Token invalid or expired. $errorMessage" }
        403 { throw "Forbidden: Insufficient permissions for this operation. $errorMessage" }
        404 { throw "Not Found: Endpoint or resource doesn't exist. $errorMessage" }
        429 { 
          if ($attempt -lt $retryAttempts) {
            $delay = [math]::Pow(2, $attempt) * 30
            Start-Sleep -Seconds $delay
            continue
          }
          throw "Rate limit exceeded: $errorMessage"
        }
        500 { throw "Internal Server Error: HYPR server error. $errorMessage" }
        default {
          if ($attempt -eq $retryAttempts) {
            throw "API call failed after $retryAttempts attempts: $errorMessage"
          }
          Start-Sleep -Seconds (2 * $attempt)
        }
      }
    }
  }
}