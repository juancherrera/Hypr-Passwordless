Describe 'Get-HyprAuditLog' {
    It 'Should run without errors' {
        Mock Invoke-HyprApi { return @{ status = 'OK' } }
        $result = Get-HyprAuditLog
        $result | Should -Not -BeNullOrEmpty
    }
}