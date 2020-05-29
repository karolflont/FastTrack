#################################
### Avid.PSU.3rdPartySoftware ###
#################################
function Install-AvPDFReader {
}

function Invoke-AvPowershellCommand {

}

function Invoke-AvPowershellScript {
    -ScriptBlock
    -FilePath

    Write-Output 'Use Invoke-Command cmdlet with -FilePath parameter, e.g. Invoke-Command -FilePath c:\scripts\test.ps1 -ComputerName Server01'
}

function Invoke-AvCMDScript {
    -ScriptBlock

}
#############################
### Avid.PSU.AvidSoftware ###
#############################
function Push-AvNexisConfig {

}

function Invoke-AvAvidPrep {
}

############################
### Avid.PSU.Diagnostics ###
############################

function Invoke-AvCollectInSilentMode {
}

function New-AvSystemCheck {
}

#####################################
### Avid.PSU.FilesystemAndStorage ###
#####################################
function Get-AvPartitionInfo {
}
function Set-AvPartition {
    param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $true)] [switch] $resize,
        [Parameter(Mandatory = $true)] [switch] $create
    )
}


##################################
### Avid.PSU.HostnameAndDomain ###
##################################
function Get-AvPSGUserAccount {
    <#
.SYNOPSIS
   TODO
.DESCRIPTION
   TODO
.PARAMETER ComputerName
   Specifies the computer name.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   TODO
#>
    Param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )

    ### Check AvidPSG User account
    $AvidPSGUserStatus = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { Get-LocalUser }
    $AvidPSGUserGroupStatus = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { Get-LocalGroupMember -Group "Administrators" }
    Write-Host -ForegroundColor Cyan "`nAvidPSG User Status "
    $AvidPSGUserStatus | Select-Object PSComputerName, Name, Enabled, Description, UserMayChangePassword, AccountExpires, PasswordExpires | Where-Object { $_.Name -eq "AvidPSG" } | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
    Write-Host -ForegroundColor Cyan "`nAdministrators Group Members "
    $AvidPSGUserGroupStatus | Select-Object PSComputerName, Name, PrincipalSource, ObjectClass | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize # Where-Object {$_.Name -like "*AvidPSG*"} | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}
function Set-AvPSGUserAccount {
    <#
.SYNOPSIS
   TODO
.DESCRIPTION
   TODO
.PARAMETER ComputerName
   Specifies the computer name.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   TODO
#>
    Param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )
    ### Add AvidPSG User account
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
        $SecureStringPassword = Get-Credential -credential "AvidPSG"
        New-LocalUser -Name "AvidPSG" -Password $SecureStringPassword -PasswordNeverExpires -UserMayNotChangePassword -Description "Avid PSG Maintenace User - DO NOT DELETE"
        Add-LocalGroupMember -Group "Administrators" -Member "AvidPSG"
    }
}
function Get-AvDNSRecords {
}

############################
### Avid.PSU.InputOutput ###
############################
function New-AvMRemoteNGSessionsConfiguration { }

function New-AvMobaXtermSessionsConfiguration { }

########################
### Avid.PSU.Network ###
########################
function Get-AvNICPowerManagementStatus {
}
function Set-AvNICPowerManagement {
}

##########################
### Avid.PSU.OS.Tweaks ###
##########################
################################
### ADJUSTING VISUAL EFFECTS ###
################################
function Set-VisualEffects {
}
#####################
##### AUTOLOGON #####
#####################
function Get-AvAutologonStatus {
    <#
    .SYNOPSIS
        Gets Windows Autologon status.
    .DESCRIPTION
        The Get-AvAutologon function gets Windows Autologon status. 
    .PARAMETER ComputerName
        Specifies the computer name.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )
    <#
    $WinlogonKey = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
        (Get-Item -LiteralPath $path -ErrorAction SilentlyContinue).GetValue("AutoAdminLogon")
    }
    $AutologonStatusDefaultUsername = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
        Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUsername"
    }
    $AutologonStatusDefaultDomain = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
        Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultDomainName"
    }
    $AutologonStatusDefaultPassword = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
        Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "ShutdownWithoutLogon"}
    
    $AutologonStatus = $AutologonStatusAutoAdminLogon | Add-Member -MemberType NoteProperty -Name Username -Value $AutologonStatusDefaultUsername
    $AutologonStatus = $AutologonStatus | Add-Member -MemberType NoteProperty -Name Domain -Value $AutologonStatusDefaultDomain
    $AutologonStatus = $AutologonStatus | Add-Member -MemberType NoteProperty -Name Password -Value $AutologonStatusDefaultPassword
    #>
        
    
    ### Set autologon
    # https://www.powershellgallery.com/packages/DSCR_AutoLogon/2.1.0
    # http://easyadminscripts.blogspot.com/2013/01/enabledisable-autoadminlogon-with.html
    # http://andyarismendi.blogspot.com/2011/10/powershell-set-secureautologon.html - tu ejst wersja z LSA Secretem
    # https://github.com/chocolatey/boxstarter/blob/master/Boxstarter.Bootstrapper/Set-SecureAutoLogon.ps1
    #$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    #$DefaultUsername = "your username"
    #$DefaultPassword = "your password"
    
    #Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String 
    #Set-ItemProperty $RegPath "DefaultUsername" -Value "$DefaultUsername" -type String 
    #Set-ItemProperty $RegPath "DefaultPassword" -Value "$DefaultPassword" -type String
    
}
function Set-AvAutologon {
    <#
    .SYNOPSIS
        Enables or disables Windows Autologon.
    .DESCRIPTION
        The Set-Autologon function enables or disables Windows Autologon. 
    .PARAMETER ComputerName
        Specifies the computer name.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch]$Enable,
        [Parameter(Mandatory = $false)] [switch]$Disable
    )

    if ($Enable) {
        if ($Disable) {
            Write-Host -ForegroundColor Red "`nPlease specify ONLY ONE of the -Enable/-Disable switch parameters. "
            Return
        }
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { Set-MpPreference -DisableRealtimeMonitoring $false }
        Write-Host -ForegroundColor Green "`nWindows Defender Realtime Monitoring ENABLED. "
    }
    elseif ($Disable) {
        if ($Enable) {
            Write-Host -ForegroundColor Red "`nPlease specify ONLY ONE of the -Enable/-Disable switch parameters. "
            Return
        }
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { Set-MpPreference -DisableRealtimeMonitoring $true }
        Write-Host -ForegroundColor Green "`nWindows Defender Realtime Monitoring DISABLED. "
    }
    else {
        Write-Host -ForegroundColor Red "`nPlease specify ONE of the -Enable/-Disable switch parameters. "
        Return
    }

    Get-AvWindowsDefenderRealtimeMonitoringStatus $ComputerName $Credential
}
####################
##### KEYBOARD #####
####################
#https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-input-locales-for-windows-language-packs
function Get-AvKeyboardLayout {
    <#
.SYNOPSIS
   TODO
.DESCRIPTION
   TODO
.PARAMETER ComputerName
   Specifies the computer name.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   TODO
#>
    param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )

    ### Get keyboard layout - to nie do konca tak jest, bo co jak sa dwa jezyki??? - dostajemy liste i nie wiadomo ktory jest aktualnie wlaczony
    $InputMethodTips = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
        $LanguageList = Get-WinUserLanguageList
        $LanguageList.InputMethodTips }
    Write-Host -ForegroundColor Cyan "`nDefault keyboard layout (0409:0000000409 - en-US) `n"
    for ($i = 0; $i -le $ComputerName.Count; $i++) {
        Write-Host -NoNewline $ComputerName[$i], " "
        Write-Host $InputMethodTips[$i]
    }
}
function Set-AvKeyboardLayout {
    <#
.SYNOPSIS
   TODO
.DESCRIPTION
   TODO
.PARAMETER ComputerName
   Specifies the computer name.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   TODO
#>
    param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )

    ### Set keyboard layout to en-US
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { Set-WinDefaultInputMethodOverride -InputTip "0409:00000409" }
}

##########################################
### Avid.PSU.ServerSetupAndUpgrade.ps1 ###
##########################################
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

######################
### Avid.PSU.Time ####
######################

function Set-AvTimeAndTimeZone {
}
#####################
##### TIME SYNC #####
#####################
function Install-AvMeinbergNTPDaemon {
    <#
.SYNOPSIS
   Silently installs Meinberg NTP Daemon on remote hosts.
.DESCRIPTION
   The Install-MeinbergNTPDaemon consists of four steps:
   1) Create the C:\MeinbergNTPDTempDir directory on remote hosts
   2) Copy:
       - Meinberg NTP Daemon installer
       - install.ini
       - ntp.conf
      to the C:\MeinbergNTPDTempDir on remote hosts
   3) Unblock the copied installer file (so no "Do you want to run this file?" pop-out appears resulting in instalation hang in the next step)
   4) Run the installer on remote hosts
.PARAMETER ComputerName
   Specifies the computer name.
.PARAMETER Credentials
   Specifies the credentials used to login.
.PARAMETER PathToInstaller
   Specifies the LOCAL path to the installer.
.EXAMPLE
   Install-MeinbergNTPDaemon -ComputerName $all_hosts -Credential $Cred -PathToInstaller 'C:\AvidInstallers\NTP\' `
                                 -PathToInstallIni '' -PathToNtpConf
#>
    param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $true)] $PathToInstaller,
        [Parameter(Mandatory = $true)] $NTPServerPrimary,
        [Parameter(Mandatory = $false)] $NTPServerSecondary,
        [Parameter(Mandatory = $false)] $PrimaryPointingTo,
        [Parameter(Mandatory = $true)] $SecondaryPointingTo
    )

    Write-Host -ForegroundColor Yellow "`nWARNING: all the remote hosts will be automatically rebooted after the installation. Press Enter to continue or Ctrl+C to quit. "
    [void](Read-Host)

    $InstallerFileName = Split-Path $PathToInstaller -leaf
    $PathToInstallerRemote = 'C:\NexisTempDir\' + $InstallerFileName

    #1. Create the NexisTempDir on remote hosts
    Write-Host -ForegroundColor Cyan "`nCreating folder C:\NexisTempDir on remote hosts. Please wait... "
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { New-Item -ItemType 'directory' -Path 'C:\NexisTempDir' }
    Write-Host -ForegroundColor Green "`nFolder C:\NexisTempDir SUCCESSFULLY created on all remote hosts. "

    #2. Copy the AvidNEXIS installer to the local drive of remote hosts
    Write-Host -ForegroundColor Cyan "`nCopying the installer to remote hosts. Please wait... "
    $ComputerName | ForEach-Object -Process {
        $Session = New-PSSession -ComputerName $_ -Credential $Credential
        Copy-Item -LiteralPath $PathToInstaller -Destination "C:\NexisTempDir\" -ToSession $Session
    }
    Write-Host -ForegroundColor Green "`nInstaller SUCCESSFULLY copied to all remote hosts. "

    #3. Unblock the copied installer (so no "Do you want to run this file?" pop-out hangs the installation in the next step)
    Write-Host -ForegroundColor Cyan "`nUnblocking copied files. Please wait... "
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { Unblock-File -Path $using:PathToInstallerRemote }
    Write-Host -ForegroundColor Green "`nall files SUCCESSFULLY unblocked. "

    #4. Run the installer on remote hosts
    Write-Host -ForegroundColor Cyan "`nInstallation in progress. This should take up to a minute. Please wait... "
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { Start-Process -FilePath $using:PathToInstallerRemote -ArgumentList '/quiet' -Wait }
    Write-Host -ForegroundColor Green "`nInstallation on all remote hosts DONE. Rebooting... "
}
function Push-AvMeinbergNTPDaemonConfig {
}
function Get-AvTimeSyncStatus {
}

#######################################################


##############
### ACCESS ###
##############
function Install-AvAccess {
    <#
    .SYNOPSIS
       Silently installs Access Client on remote hosts.
    .DESCRIPTION
       The Install-Access consists of six steps:
       1) Check if the PathToInstaller is valid
       2) Create the C:\AccessTempDir on remote hosts
       3) Copy the Access installer to the C:\AccessTempDir on remote hosts
       4) Unblock the copied installer file (so no "Do you want to run this file?" pop-out appears resulting in instalation hang in the next step)
       5) Run the installer on remote hosts
       6) Remove folder C:\AccessTempDir from remote hosts
    .PARAMETER ComputerName
       Specifies the computer name.
    .PARAMETER Credentials
       Specifies the credentials used to login.
    .PARAMETER PathToInstaller
       Specifies the LOCAL path to the installer.
    .PARAMETER RebootAfterInstallation
       Specifies if remote hosts shuld be rebooted after the installation.
    .EXAMPLE
       Install-Access -ComputerName $all_hosts -Credential $Cred -PathToInstaller 'C:\AvidInstallers\InterplayAccessSetup.exe'
    #>
    
    Param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $true)] $PathToInstaller
    )
    
    Write-Host -ForegroundColor Red "`nNot working as expected for .exe. Exiting... "
    return

    $InstallerFileName = Split-Path $PathToInstaller -leaf
    $PathToInstallerRemote = 'C:\AccessTempDir\' + $InstallerFileName
    
    #1. Check if the PathToInstaller is valid - cancel installation if not.
    Write-Host -ForegroundColor Cyan "`nChecking if the path to installer is a valid one. Please wait... "
    if (-not (Test-Path -Path $PathToInstaller -PathType leaf)) {
        Write-Host -ForegroundColor Red "`nPath is not valid. Exiting... "
        return
    }
    else {
        Write-Host -ForegroundColor Green "`nPath is valid. Let's continue... "
    }
    
    #2. Create the AccessTempDir on remote hosts
    Write-Host -ForegroundColor Cyan "`nCreating folder C:\AccessTempDir on remote hosts. Please wait... "
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { New-Item -ItemType 'directory' -Path 'C:\AccessTempDir' | Out-Null }
    Write-Host -ForegroundColor Green "`nFolder C:\AccessTempDir SUCCESSFULLY created on all remote hosts. "
    
    #3. Copy the Access installer to the local drive of remote hosts
    Write-Host -ForegroundColor Cyan "`nCopying the installer to remote hosts. Please wait... "
    $ComputerName | ForEach-Object -Process {
        $Session = New-PSSession -ComputerName $_ -Credential $Credential
        Copy-Item -LiteralPath $PathToInstaller -Destination "C:\AccessTempDir\" -ToSession $Session
    }
    Write-Host -ForegroundColor Green "`nInstaller SUCCESSFULLY copied to all remote hosts. "
    
    #4. Unblock the copied installer (so no "Do you want to run this file?" pop-out hangs the installation in the next step)
    Write-Host -ForegroundColor Cyan "`nUnblocking copied files. Please wait... "
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { Unblock-File -Path $using:PathToInstallerRemote }
    Write-Host -ForegroundColor Green "`nall files SUCCESSFULLY unblocked. "
    
    #5. Run the installer on remote hosts
    Write-Host -ForegroundColor Cyan "`nInstallation in progress. This should take up to a minute. Please wait... "
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { Start-Process -FilePath $using:PathToInstallerRemote -ArgumentList '/quiet /norestart' -Wait }
    
    #6. Remove folder C:\AccessTempDir from remote hosts
    Write-Host -ForegroundColor Cyan "`nInstallation of Access Client on all remote hosts DONE. Cleaning up..."
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { Remove-Item -Path "C:\AccessTempDir\" -Recurse }
}

