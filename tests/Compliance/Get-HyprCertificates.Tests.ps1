Describe 'Get-HyprCertificates' {
    It 'Should run without errors' {
        Mock Invoke-HyprApi { return @{ status = 'OK' } }
        $result = Get-HyprCertificates
        $result | Should -Not -BeNullOrEmpty
    }
}