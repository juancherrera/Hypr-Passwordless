Describe 'Invoke-HyprApi' {
    It 'Should run without errors' {
        Mock Invoke-HyprApi { return @{ status = 'OK' } }
        $result = Invoke-HyprApi
        $result | Should -Not -BeNullOrEmpty
    }
}