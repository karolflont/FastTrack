# Copyright (C) 2018  Karol Flont
# Full license notice can be found in FastTrack.psd1 file.

#Requires -RunAsAdministrator

Write-Host -ForegroundColor Green "`nUninstalling FastTrack module..."

# Setting the module's and TrustedHosts backup destination
$PSModulesDirectory = 'C:\Program Files\WindowsPowerShell\Modules'
$FastTrackModulePath = $PSModulesDirectory + "\FastTrack"
$TrustedHostsBackupPath = $PSModulesDirectory + "\FastTrackTrustedHostsBackup.bkp"

# Removing the module form user's PSModulePath
Remove-Item -LiteralPath $FastTrackModulePath -Recurse -Force -ErrorAction SilentlyContinue
Write-Host -ForegroundColor Green "`nModule FastTrack uninstalled."

# Unloading the module from the active memory
Remove-Module FastTrack -Force -ErrorAction SilentlyContinue
Write-Host -ForegroundColor Green "`nModule FastTrack unloaded from the active memory."

# Restoring TrustedHosts from backup
$TrustedHostsValue = [string](Get-Content -Path $TrustedHostsBackupPath)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $TrustedHostsValue -Force -PassThru
Write-Host -ForegroundColor Green "`nWSMan:\localhost\Client\TrustedHosts restored."