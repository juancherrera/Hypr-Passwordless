# HyprPasswordless.psm1

# Import all core and supporting functions
$basePath = $PSScriptRoot

# Recursively import all functions in subfolders
Get-ChildItem -Path "$basePath\functions" -Filter *.ps1 -Recurse | ForEach-Object {
  . $_.FullName
}
