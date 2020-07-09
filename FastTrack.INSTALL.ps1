# Copyright (C) 2018  Karol Flont
# Full license notice can be found in FastTrack.psd1 file.

#Requires -RunAsAdministrator

# Getting the path to current directory
$source = Get-Location

# Validating the directory path
while ((-not (Test-Path ([string]$source + "\" + "FastTrack.psd1")))) {
  if ($source.Length -eq 0) {
    $source = Get-Location
  }
  if (-not (Test-Path ([string]$source + "\" + "FastTrack.psd1"))) {
    Write-Host -ForegroundColor Red "`nYou must change your working directory to the folder contining FastTrack.psd1 file."
    Write-Host -ForegroundColor Red "`nHit Enter to quit."
  }
  [void](Read-Host)
  return
}

Write-Host -ForegroundColor Green "`nInstalling FastTrack module..."

# Setting the module's destination - using user's PSModulePath
$PSMPaths = $env:PSModulePath -split ';'
foreach ($PSMPAth in $PSMPaths) {
  if ($PSMPath -like "*Documents*") {
    $destination = $PSMPath + "\FastTrack"
    $BackupDestination = $PSMPath
  }
}

# Copying the module to the user's PSModulePath
$sourceFiles = [string]$source + '\'
#New-Item -ItemType 'directory' -Path $destination -ErrorAction SilentlyContinue
Copy-Item -LiteralPath $sourceFiles -Destination $destination -Recurse -Force
Write-Host -ForegroundColor Green "`nModule FastTrack installed."

# Loading the module to the active memory
Import-Module FastTrack -Force
Write-Host -ForegroundColor Green "`nModule FastTrack imported."

# Backing up TrustedHosts Value
$FastTrackTrustedHostsBackup = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value
$BackupPath = $BackupDestination + "\FastTrackTrustedHostsBackup.bkp"
Out-File -FilePath $BackupPath -InputObject $FastTrackTrustedHostsBackup
Write-Host -ForegroundColor Green "`nMWSMan:\localhost\Client\TrustedHosts backed up. "

# Adding "all hosts" to trusted hosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
Write-Host -ForegroundColor Green "`nMWSMan:\localhost\Client\TrustedHosts updated with '*'. "

# Footer message
Write-Host -ForegroundColor Yellow "`nCheck FastTrack.SAMPLE.ps1 for sample usage of FastTrack module."