Describe 'Get-HyprWebhooks' {
    It 'Should run without errors' {
        Mock Invoke-HyprApi { return @{ status = 'OK' } }
        $result = Get-HyprWebhooks
        $result | Should -Not -BeNullOrEmpty
    }
}