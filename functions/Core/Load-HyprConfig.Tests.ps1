Describe 'Load-HyprConfig' {
  BeforeAll {
    $testConfigPath = "TestDrive:\test_config.json"
    $validConfig = @{
      BaseUrl      = "https://test.hypr.com"
      RPAppId      = "TestApp"
      RPAppToken   = "test-token"
      CCAdminToken = ""
    }
  }
  
  It 'Should load valid configuration' {
    $validConfig | ConvertTo-Json | Set-Content $testConfigPath
    $result = Load-HyprConfig -Path $testConfigPath
    $result.BaseUrl | Should -Be "https://test.hypr.com"
    $result.RPAppId | Should -Be "TestApp"
  }
  
  It 'Should create default config if none exists' {
    $newConfigPath = "TestDrive:\new_config.json"
    { Load-HyprConfig -Path $newConfigPath } | Should -Not -Throw
    Test-Path $newConfigPath | Should -Be $true
  }
  
  It 'Should throw on missing required fields' {
    $invalidConfig = @{ BaseUrl = "" }
    $invalidConfig | ConvertTo-Json | Set-Content $testConfigPath
    { Load-HyprConfig -Path $testConfigPath } | Should -Throw
  }
}