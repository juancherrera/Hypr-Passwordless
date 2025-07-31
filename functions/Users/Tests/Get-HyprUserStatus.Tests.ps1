Describe 'Get-HyprUserStatus' {
  BeforeAll {
    $mockConfig = [PSCustomObject]@{
      BaseUrl    = "https://test.hypr.com"
      RPAppToken = "test-token"
    }
  }
  
  It 'Should return user status for enrolled user' {
    Mock Invoke-HyprApi { 
      return @{ 
        response = @{ 
          registered  = $true
          deviceCount = 2
        }
      }
    }
      
    $result = Get-HyprUserStatus -Username "test@example.com" -Config $mockConfig
    $result.registered | Should -Be $true
    $result.deviceCount | Should -Be 2
  }
  
  It 'Should return user status for non-enrolled user' {
    Mock Invoke-HyprApi { 
      return @{ 
        response = @{ 
          registered  = $false
          deviceCount = 0
        }
      }
    }
      
    $result = Get-HyprUserStatus -Username "newuser@example.com" -Config $mockConfig
    $result.registered | Should -Be $false
    $result.deviceCount | Should -Be 0
  }
  
  It 'Should handle API errors gracefully' {
    Mock Invoke-HyprApi { throw "API Error" }
      
    { Get-HyprUserStatus -Username "test@example.com" -Config $mockConfig } | Should -Throw "*API Error*"
  }
}