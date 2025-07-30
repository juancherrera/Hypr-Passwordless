Describe 'Get-HyprToken' {
    It 'Should run without errors' {
        Mock Invoke-HyprApi { return @{ status = 'OK' } }
        $result = Get-HyprToken
        $result | Should -Not -BeNullOrEmpty
    }
}