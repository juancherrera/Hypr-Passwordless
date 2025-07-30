# Hypr-Passwordless.psm1
# Automatically dot-sources all core HYPR module scripts

$functionPaths = @(
  "$PSScriptRoot\functions\Core\*.ps1",
  "$PSScriptRoot\functions\Certificates\*.ps1",
  "$PSScriptRoot\functions\Compliance\*.ps1",
  "$PSScriptRoot\functions\Devices\*.ps1",
  "$PSScriptRoot\functions\Users\*.ps1"
)

foreach ($path in $functionPaths) {
  Get-ChildItem -Path $path -File | ForEach-Object {
    . $_.FullName
  }
}
