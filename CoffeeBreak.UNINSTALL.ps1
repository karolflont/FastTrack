#Requires -RunAsAdministrator

Write-Host -ForegroundColor Green "`nUninstalling CoffeeBreak module..."

# Getting the module's destination - using user's PSModulePath
$PSMPaths = $env:PSModulePath -split ';'
foreach ($PSMPAth in $PSMPaths) {
  if ($PSMPath -like "*Documents*") {
    $destination = $PSMPath
  }
}

# Removing the module form user's PSModulePath
Remove-Item -LiteralPath ($destination + "\" + "CoffeeBreak") -Recurse -Force -ErrorAction SilentlyContinue
Write-Host -ForegroundColor Green "`nModule CoffeeBreak uninstalled."

# Unloading the module from the active memory
Remove-Module CoffeeBreak -Force -ErrorAction SilentlyContinue
Write-Host -ForegroundColor Green "`nModule CoffeeBreak unloaded from the active memory."

# Clearing "all hosts" from trusted hosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "" -Force
Write-Host -ForegroundColor Green "`nWSMan:\localhost\Client\TrustedHosts cleared."

# Footer message
Write-Host -ForegroundColor Yellow "`nPlease restore manually WSMan:\localhost\Client\TrustedHosts if you had some entries there."