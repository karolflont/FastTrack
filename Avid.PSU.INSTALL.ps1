### Copy
# source
$source = $null
Write-Host -ForegroundColor Green "`nPlease type the path to Avid.PSUtilities folder, e.g. c:\My Folder\Avid.PSUtilities or hit ENTER to keep the default path, which is $(Get-Location). "
$source = Read-Host
# Validating the Avid.PSUtilities folder path
while((-not (Test-Path ([string]$source + "\" + "Avid.PSUtilities.psd1")))){
   if ($source.Length -eq 0){
     $source = Get-Location
   }
   if(-not (Test-Path ([string]$source + "\" + "Avid.PSUtilities.psd1"))){
    Write-Host -ForegroundColor Red "`nThe path you entered is not valid. Cannot find Avid.PSUtilities.psd1 file in the specified path. Please try again or hit Ctrl+c to quit. "
   }
   $source = Read-Host
}

Write-Host -ForegroundColor Green "`nInstalling... "

# destination - using user PS module path (no need for admin rights of the user running the session)
$PSMPaths = $env:PSModulePath -split ';'
foreach ($PSMPAth in $PSMPaths) {
  if ($PSMPath -like "*Documents*"){
    $destination = $PSMPath
  }
}

Copy-Item -LiteralPath $source -Destination $destination -Recurse -Force

### Loading the module to the active memory
Import-Module Avid.PSUtilities -Force
Write-Host -ForegroundColor Green "`nModule Avid.PSUtilites imported successfully. "

### Listing all cmdlets from AvidPSUtilities module
Write-Host -ForegroundColor Green "`nFunctions available in Avid.PSUtilities module: "
Get-Command -Module Avid.PSUtilities

### Adding "all hosts" to trusted hosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

### Footer message
Write-Host -ForegroundColor Green "`nCheck Avid.PSU.SAMPLE.ps1 for sample usage of Avid.PSUtilities module. "
Write-Host -ForegroundColor Green "Hit enter to close this window. "
[void](Read-Host)
