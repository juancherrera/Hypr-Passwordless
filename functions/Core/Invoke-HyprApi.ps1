function Invoke-HyprApi {
  <#
  .SYNOPSIS
      Base wrapper for HYPR API calls with comprehensive error handling.
  .DESCRIPTION
      Executes HTTP requests to HYPR API endpoints with retry logic, proper headers,
      and detailed error handling based on proven working implementations.
  .PARAMETER Method
      HTTP method (GET, POST, PUT, DELETE, PATCH).
  .PARAMETER Endpoint
      API endpoint path starting with / (e.g., "/rp/api/versioned/fido2/settings").
  .PARAMETER Config
      HYPR configuration object from Load-HyprConfig.
  .PARAMETER Body
      Request body for POST/PUT operations (will be converted to JSON).
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
      
  # Get and validate token
  $token = Get-HyprToken -Config $Config -TokenType $TokenType
      
  # Build URI
  $baseUrl = $Config.BaseUrl.TrimEnd('/')
  $uri = "$baseUrl$Endpoint"
      
  # Build headers (based on proven working implementation)
  $headers = @{
    'Authorization' = "Bearer $token"
    'Accept'        = 'application/json'
    'Cache-Control' = 'no-cache'
    'User-Agent'    = 'HYPR-PowerShell-Module/2.1'
  }
      
  if ($Method -in @('POST', 'PUT', 'PATCH')) {
    $headers['Content-Type'] = 'application/json'
  }
      
  # Get retry settings
  $retryAttempts = if ($Config.RetryAttempts -and $Config.RetryAttempts -gt 0) { $Config.RetryAttempts } else { 3 }
  $timeoutSeconds = if ($Config.TimeoutSeconds -and $Config.TimeoutSeconds -gt 0) { $Config.TimeoutSeconds } else { 60 }
      
  Write-Verbose "Making $Method request to $uri (attempt 1 of $retryAttempts)"
      
  # Retry loop with exponential backoff
  for ($attempt = 1; $attempt -le $retryAttempts; $attempt++) {
    try {
      $requestParams = @{
        Uri         = $uri
        Method      = $Method
        Headers     = $headers
        TimeoutSec  = $timeoutSeconds
        ErrorAction = 'Stop'
      }
              
      # Add body for POST/PUT/PATCH requests
      if ($Body -and $Method -in @('POST', 'PUT', 'PATCH')) {
        $jsonBody = if ($Body -is [string]) { $Body } else { $Body | ConvertTo-Json -Depth 10 -Compress }
        $requestParams.Body = $jsonBody
        Write-Verbose "Request body: $($jsonBody.Substring(0, [Math]::Min(200, $jsonBody.Length)))$(if($jsonBody.Length -gt 200){'...'})"
      }
              
      # Make the API call
      $response = Invoke-RestMethod @requestParams
              
      # Check HYPR-specific response format
      if ($response.status -and $response.status.responseCode -and $response.status.responseCode -ne 200) {
        $errorMsg = if ($response.status.responseMessage) { $response.status.responseMessage } else { "Unknown HYPR API error" }
        throw "HYPR API Error [$($response.status.responseCode)]: $errorMsg"
      }
              
      Write-Verbose "API call successful on attempt $attempt"
      return $response
              
    }
    catch {
      $statusCode = $null
      $errorMessage = $_.Exception.Message
              
      # Extract HTTP status code
      if ($_.Exception.Response) {
        try {
          $statusCode = [int]$_.Exception.Response.StatusCode
        }
        catch {
          Write-Verbose "Could not extract status code from response"
        }
      }
              
      Write-Verbose "API call failed on attempt $attempt with status $statusCode`: $errorMessage"
              
      # Handle specific HTTP status codes
      switch ($statusCode) {
        400 { 
          throw "Bad Request (400): Invalid request format or parameters. Check your input data. $errorMessage"
        }
        401 { 
          throw "Unauthorized (401): Token is invalid, expired, or missing. Please check your token configuration. $errorMessage"
        }
        403 { 
          throw "Forbidden (403): Token lacks permissions for this operation. You may need an Admin token or different RP App permissions. $errorMessage"
        }
        404 {
          throw "Not Found (404): API endpoint doesn't exist or resource not found. Check the endpoint URL. $errorMessage"
        }
        429 { 
          if ($attempt -lt $retryAttempts) {
            $delay = [math]::Pow(2, $attempt) * 15  # Exponential backoff: 15, 30, 60 seconds
            Write-Warning "Rate limited (429). Waiting $delay seconds before retry..."
            Start-Sleep -Seconds $delay
            continue
          }
          throw "Rate Limit Exceeded (429): Too many requests. Please wait before retrying. $errorMessage"
        }
        500 {
          throw "Internal Server Error (500): HYPR server error. Please try again later or contact support. $errorMessage"
        }
        502 {
          throw "Bad Gateway (502): Network connectivity issue. Please check your connection to HYPR. $errorMessage"
        }
        503 {
          throw "Service Unavailable (503): HYPR service is temporarily unavailable. Please try again later. $errorMessage"
        }
        default {
          if ($attempt -eq $retryAttempts) {
            throw "API call failed after $retryAttempts attempts: $errorMessage"
          }
          # Wait before retry for other errors
          $delay = 2 * $attempt
          Write-Verbose "Retrying after $delay seconds..."
          Start-Sleep -Seconds $delay
        }
      }
    }
  }
      
  # This should never be reached due to throw statements above
  throw "Unexpected error: Maximum retry attempts reached"
}