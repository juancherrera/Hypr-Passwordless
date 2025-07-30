# Load all scripts from functions folder
$folders = @("Core", "Certificates", "Compliance", "Devices", "Users")

foreach ($folder in $folders) {
  $path = Join-Path -Path $PSScriptRoot -ChildPath "functions\$folder"
  Get-ChildItem -Path $path -Filter *.ps1 -Recurse | ForEach-Object {
    . $_.FullName
  }
}
