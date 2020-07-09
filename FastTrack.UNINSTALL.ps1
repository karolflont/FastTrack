# Copyright (C) 2018  Karol Flont
# Full license notice can be found in FastTrack.psd1 file.

#Requires -RunAsAdministrator

Write-Host -ForegroundColor Green "`nUninstalling FastTrack module..."

# Getting the module's destination - using user's PSModulePath
$PSMPaths = $env:PSModulePath -split ';'
foreach ($PSMPAth in $PSMPaths) {
  if ($PSMPath -like "*Documents*") {
    $destination = $PSMPath
  }
}

# Removing the module form user's PSModulePath
Remove-Item -LiteralPath ($destination + "\" + "FastTrack") -Recurse -Force -ErrorAction SilentlyContinue
Write-Host -ForegroundColor Green "`nModule FastTrack uninstalled."

# Unloading the module from the active memory
Remove-Module FastTrack -Force -ErrorAction SilentlyContinue
Write-Host -ForegroundColor Green "`nModule FastTrack unloaded from the active memory."

# Restoring TrustedHosts from backup
$BackupPath = $destination + "\FastTrackTrustedHostsBackup.bkp"
$FastTrackTrustedHostsBackup = [string](Get-Content -Path $BackupPath)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $FastTrackTrustedHostsBackup -Force -PassThru
Write-Host -ForegroundColor Green "`nWSMan:\localhost\Client\TrustedHosts restored."