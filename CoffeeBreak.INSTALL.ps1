#Requires -RunAsAdministrator

# Getting the path to current directory
$source = Get-Location

# Validating the directory path
while ((-not (Test-Path ([string]$source + "\" + "CoffeeBreak.psd1")))) {
  if ($source.Length -eq 0) {
    $source = Get-Location
  }
  if (-not (Test-Path ([string]$source + "\" + "CoffeeBreak.psd1"))) {
    Write-Host -ForegroundColor Red "`nYou are running this script from $source folder. This script requires two conditions to run properly: "
    Write-Host -ForegroundColor Red " - This script must be placed in CoffeeBreak folder, "
    Write-Host -ForegroundColor Red " - There has to be a valid CoffeeBreak.psd1 file in the CoffeeBreak folder."
    Write-Host -ForegroundColor Red "`nHit Enter to quit."
  }
  [void](Read-Host)
  return
}

Write-Host -ForegroundColor Green "`nInstalling CoffeeBreak module..."

# Setting the module's destination - using user's PSModulePath
$PSMPaths = $env:PSModulePath -split ';'
foreach ($PSMPAth in $PSMPaths) {
  if ($PSMPath -like "*Documents*") {
    $destination = $PSMPath
  }
}

# Copying the module to the user's PSModulePath
Copy-Item -LiteralPath $source -Destination $destination -Recurse -Force
Write-Host -ForegroundColor Green "`nModule CoffeeBreak installed."

# Loading the module to the active memory
Import-Module CoffeeBreak -Force
Write-Host -ForegroundColor Green "`nModule CoffeeBreak imported."

# Adding "all hosts" to trusted hosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
Write-Host -ForegroundColor Green "`nMWSMan:\localhost\Client\TrustedHosts updated with '*' "

# Footer message
Write-Host -ForegroundColor Yellow "`nCheck CoffeeBreak.SAMPLE.ps1 for sample usage of CoffeeBreak module."