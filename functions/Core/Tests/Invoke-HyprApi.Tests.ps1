Describe 'Invoke-HyprApi' {
  BeforeAll {
    $mockConfig = [PSCustomObject]@{
      BaseUrl        = "https://test.hypr.com"
      RPAppToken     = "test-token"
      CCAdminToken   = "admin-token"
      TimeoutSeconds = 30
      RetryAttempts  = 2
    }
  }
  
  It 'Should make successful API call' {
    Mock Invoke-RestMethod { return @{ response = @{ data = "test" } } }
      
    $result = Invoke-HyprApi -Method GET -Endpoint "/test" -Config $mockConfig
    $result.response.data | Should -Be "test"
  }
  
  It 'Should handle 401 errors appropriately' {
    Mock Invoke-RestMethod { 
      $response = [System.Net.HttpWebResponse]::new()
      $response.StatusCode = [System.Net.HttpStatusCode]::Unauthorized
      throw [System.Net.WebException]::new("Unauthorized", $null, [System.Net.WebExceptionStatus]::ProtocolError, $response)
    }
      
    { Invoke-HyprApi -Method GET -Endpoint "/test" -Config $mockConfig } | Should -Throw "*Unauthorized*"
  }
  
  It 'Should retry on transient failures' {
    $script:callCount = 0
    Mock Invoke-RestMethod { 
      $script:callCount++
      if ($script:callCount -lt 2) {
        throw "Temporary failure"
      }
      return @{ response = @{ data = "success" } }
    }
      
    $result = Invoke-HyprApi -Method GET -Endpoint "/test" -Config $mockConfig
    $result.response.data | Should -Be "success"
    $script:callCount | Should -Be 2
  }
}