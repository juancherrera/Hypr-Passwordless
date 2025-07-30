Describe 'Get-HyprUser' {
    It 'Should run without errors' {
        Mock Invoke-HyprApi { return @{ status = 'OK' } }
        $result = Get-HyprUser
        $result.status | Should -Be 'OK'
    }
}