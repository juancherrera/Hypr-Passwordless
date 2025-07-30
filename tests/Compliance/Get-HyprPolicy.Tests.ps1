Describe 'Get-HyprPolicy' {
    It 'Should run without errors' {
        Mock Invoke-HyprApi { return @{ status = 'OK' } }
        $result = Get-HyprPolicy
        $result | Should -Not -BeNullOrEmpty
    }
}