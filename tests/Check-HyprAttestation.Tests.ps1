Describe 'Check-HyprAttestation' {
    It 'Should run without errors' {
        Mock Invoke-HyprApi { return @{ status = 'OK' } }
        $result = Check-HyprAttestation
        $result.status | Should -Be 'OK'
    }
}