Describe 'Load-HyprConfig' {
    It 'Should run without errors' {
        Mock Invoke-HyprApi { return @{ status = 'OK' } }
        $result = Load-HyprConfig
        $result | Should -Not -BeNullOrEmpty
    }
}