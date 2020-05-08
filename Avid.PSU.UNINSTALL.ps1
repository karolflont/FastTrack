Write-Host -ForegroundColor Green "`nUninstalling Avid.PSUtilities module... "

# destination - using user PS module path
$PSMPaths = $env:PSModulePath -split ';'
foreach ($PSMPAth in $PSMPaths) {
  if ($PSMPath -like "*Documents*"){
    $destination = $PSMPath
  }
}

Remove-Item -LiteralPath ($destination + "\" + "Avid.PSUtilities") -Recurse -Force
Write-Host -ForegroundColor Green "`nModule Avid.PSUtilites uninstalled. "

### Unloading the module from the active memory
Remove-Module Avid.PSUtilities -Force
Write-Host -ForegroundColor Green "`nModule Avid.PSUtilites unloaded from the active memory. "

### Clearing "all hosts" from trusted hosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "" -Force
Write-Host -ForegroundColor Green "`nWSMan:\localhost\Client\TrustedHosts cleared. "

### Footer message
Write-Host -ForegroundColor Green "Hit enter to close this window. "
[void](Read-Host)
