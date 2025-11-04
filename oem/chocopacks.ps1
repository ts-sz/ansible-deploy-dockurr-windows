# Fetch the user and system Path environment variables
$userPath = [Environment]::GetEnvironmentVariable('Path',[System.EnvironmentVariableTarget]::User)
$systemPath = [Environment]::GetEnvironmentVariable('Path',[System.EnvironmentVariableTarget]::Machine)

# Update local process' path
if ($userPath) {
  $env:Path = $systemPath + ";" + $userPath
} else {
  $env:Path = $systemPath
}

Write-Host "Installing Chocolatey Apps"

# Specify the directory where the .choco.config files are located (same as script location)
$chocoPackagesDir = $PSScriptRoot

# Loop through each .choco.config file in the directory
Get-ChildItem -Path $chocoPackagesDir -Filter "*.choco.config" | ForEach-Object {
  Write-Host $_.FullName
  if ($_.Name -match '^.+\.choco\.config$') {
    $chocoConfigFile = $_.FullName
    Write-Host "Installing applications from $chocoConfigFile"
    C:\ProgramData\chocolatey\bin\choco.exe install -y --detailedExitCodes $chocoConfigFile
  }
}
