function Initialize-PAMServer {
    param (
       
    )


### OS SETUP AND CONFIG ###
Join-Domain
Set-Hostname
Set-Autologon
#Set-AvidPSGUserAccount #(AvidPrep)
Set-RemoteDesktop #(merge Enable-RemoteDesktop and Disable-RemoteDesktop)
Run-AvidPrep
Set-SystemTimeZone
Set-KeyboardLayout
#Disable-UAC #AvidPrep
Set-ProcessorScheduling
Adjust-VisualEffects
Set-Firewall
Set-WindowsDefenderRealtimeMonitoring
###More
Set-NICPowerManagement
#Set-PowerPlanToHighPerformance #AvidPrep
Set-HiddenFilesAndFolders
Set-WindowsUpdateService
### GENERAL INSTALLERS ###
#Install-ASDT #AvidPrep
Install-MeinbergNTPDamon
Push-MeinbergNTPDaemonConfig
#Install-Chrome #AvidPrep
Install-NotepadPlusPlus
Install-PDFReader #AvidPrep - has issues on Win2016

### AVID INSTALLERS
Install-NexisClient
Push-NexisConfig
#Install-AvidServiceFramework #AvidPrep
#Install-Access #AvidPrep

### BEAUTIFIERS
Install-BGInfo
Create-DesktopShortcuts

### DIAGNOSTICS
Get-EventLogErrors
Run-CollectInSilentMode
Run-AvidSystemCheck
                  
}