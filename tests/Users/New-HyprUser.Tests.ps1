Describe 'New-HyprUser' {
    It 'Should run without errors' {
        Mock Invoke-HyprApi { return @{ status = 'OK' } }
        $result = New-HyprUser
        $result | Should -Not -BeNullOrEmpty
    }
}