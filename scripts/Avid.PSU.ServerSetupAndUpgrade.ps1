function Initialize-AvPAMServer {
    param (
       
    )


### OS SETUP AND CONFIG ###
Join-AvDomain
Set-AvHostname
Set-AvAutologon
#Set-AvAvidPSGUserAccount #(AvidPrep)
Set-AvRemoteDesktop #(merge Enable-AvRemoteDesktop and Disable-AvRemoteDesktop)
Run-AvAvidPrep
Set-AvSystemTimeZone
Set-AvKeyboardLayout
#Disable-AvUAC #AvidPrep
Set-AvProcessorScheduling
Adjust-AvVisualEffects
Set-AvFirewall
Set-AvWindowsDefenderRealtimeMonitoring
###More
Set-AvNICPowerManagement
#Set-AvPowerPlanToHighPerformance #AvidPrep
Set-AvHiddenFilesAndFolders
Set-AvWindowsUpdateService
### GENERAL INSTALLERS ###
#Install-AvASDT #AvidPrep
Install-AvMeinbergNTPDamon
Push-AvMeinbergNTPDaemonConfig
#Install-AvChrome #AvidPrep
Install-AvNotepadPlusPlus
Install-AvPDFReader #AvidPrep - has issues on Win2016

### AVID INSTALLERS
Install-AvNexisClient
Push-AvNexisConfig
#Install-AvAvidServiceFramework #AvidPrep
#Install-AvAccess #AvidPrep

### BEAUTIFIERS
Install-AvBGInfo

### DIAGNOSTICS
Get-AvEventLogErrors
Run-AvCollectInSilentMode
Run-AvAvidSystemCheck
                  
}