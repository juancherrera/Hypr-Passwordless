Describe 'Remove-HyprUserDevice' {
    It 'Should run without errors' {
        Mock Invoke-HyprApi { return @{ status = 'OK' } }
        $result = Remove-HyprUserDevice
        $result | Should -Not -BeNullOrEmpty
    }
}