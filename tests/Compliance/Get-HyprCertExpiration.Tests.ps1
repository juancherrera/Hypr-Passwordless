Describe 'Get-HyprCertExpiration' {
    It 'Should run without errors' {
        Mock Invoke-HyprApi { return @{ status = 'OK' } }
        $result = Get-HyprCertExpiration
        $result | Should -Not -BeNullOrEmpty
    }
}