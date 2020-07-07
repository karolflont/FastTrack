#################
##### NEXIS #####
#################
function Install-FtAvidNexisClient {
    <#
    .SYNOPSIS
        Silently installs AvidNEXIS Client on remote hosts.
    .DESCRIPTION
        The Install-NexisClientconsists of six steps:
        1) Check if the PathToInstaller is valid
        2) Create the C:\FastTrackTempDir on remote hosts
        3) Copy the AvidNEXIS installer to the C:\FastTrackTempDir on remote hosts
        4) Unblock the copied installer file (so no "Do you want to run this file?" pop-out appears resulting in instalation hang in the next step)
        5) Run the installer on remote hosts
        6) Remove folder C:\FastTrackTempDir from remote hosts
        7) [OPTIONAL] Reboot the remote hosts
    .PARAMETER ComputerIP
        Specifies the computer IP.
    .PARAMETER Credential
        Specifies the credentials used to login.
    .PARAMETER PathToInstaller
        Specifies the LOCAL to your computer path to the installer. (The installer will be copied to all remote hosts.)
    .PARAMETER DontRebootAfterInstallation
        Specifies if remote hosts should be rebooted after the installation.
    .PARAMETER DontWaitForHostsAfterReboot
        Specifies if the command should wait for the remote hosts to come back online after triggering the reboot.
    .PARAMETER Force
        Auto-approves the reboot confirmation message.
    .EXAMPLE
        Install-NexisClient -ComputerIP $all_hosts -Credential $Cred -PathToInstaller 'C:\AvidInstallers\AvidNEXISClient_Win64_18.11.0.9.msi' -RebootAfterInstallation
    #>

    Param(
        [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $true)] $PathToInstaller,
        [Parameter(Mandatory = $false)] [switch]$DontRebootAfterInstallation,
        [Parameter(Mandatory = $false)] [switch]$DontWaitForHostsAfterReboot,
        [Parameter(Mandatory = $false)] [switch]$Force
    )

    $Reboot = $true
    if ($DontRebootAfterInstallation) { $Reboot = $false }
    else {
        if ($Force) { $Reboot = $true }
        else { $Reboot = Confirm-FtRestart }
    }

    $ArgumentList = '/quiet /norestart'

    $InstallationResult = Install-FtApplication -ComputerIP $ComputerIP -Credential $Credential -PathToInstaller $PathToInstaller -ArgumentList $ArgumentList

    if ($InstallationResult -ne -1) {
        if ($DontWaitForHostsAfterReboot) { Restart-FtRemoteComputer -ComputerIP $ComputerIP -Credential $Credential -Reboot $Reboot -DontWaitForHostsAfterReboot }
        else { Restart-FtRemoteComputer -ComputerIP $ComputerIP -Credential $Credential -Reboot $Reboot }
    }
}

function Uninstall-FtAvidNexisClient {
    <#
.SYNOPSIS
   Silently uninstalls AvidNEXIS Client on remote hosts.
.DESCRIPTION
   The Uninstall-NexisClient function uninstalls AvidNexis Client from selected remote hosts using msiexec.
.PARAMETER ComputerIP
   Specifies the computer IP.
.PARAMETER Credential
   Specifies the credentials used to login.
.EXAMPLE
   Uninstall-NexisClient -ComputerIP $all_hosts -Credential $Cred -RebootAfterUninstallation
#>

    Param(
        [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $false)] [switch]$DontRebootAfterUnInstallation,
        [Parameter(Mandatory = $false)] [switch]$DontWaitForHostsAfterReboot,
        [Parameter(Mandatory = $false)] [switch]$Force
    )

    $Reboot = $true
    if ($DontRebootAfterUninstallation) { $Reboot = $false }
    else {
        if ($Force) { $Reboot = $true }
        else { $Reboot = Confirm-FtRestart }
    }

    $ApplicationNameToMatch = "Avid NEXIS Client"

    Uninstall-FtApplication -ComputerIP $ComputerIP -Credential $Credential -ApplicationNameToMatch $ApplicationNameToMatch

    if ($DontWaitForHostsAfterReboot) { Restart-FtRemoteComputer -ComputerIP $ComputerIP -Credential $Credential -Reboot $Reboot -DontWaitForHostsAfterReboot }
    else { Restart-FtRemoteComputer -ComputerIP $ComputerIP -Credential $Credential -Reboot $Reboot }
    

}
###############################
##### AVID SOFTWARE CHECK #####
###############################
function Get-FtAvidSoftware {
    <#
    .SYNOPSIS
        Gets installed Avid Software versions.
    .DESCRIPTION
        The Get-FtAvidSoftware function retrieves all the keys from "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\" containing words:
        - Avid in the "Publishers" value
        - {Avid|Isis|Nexis} in "DisplayName" value
        Results are sorted by Alias, unless one of the 'SortBy' switches is selected.
    .PARAMETER ComputerIP
        Specifies computer IP.
    .PARAMETER Credential
        Specifies credentials used to login.
    .PARAMETER SortByAlias
        Allows sorting by Alias. This is the default sort property, if none of the sort parameters are selected.
    .PARAMETER SortByHostnameInConfig
        Allows sorting by Hostname in $SysConfig variable.
    .PARAMETER SortByDisplayName
        Allows sorting by Application Name.
    .PARAMETER SortByDisplayVersion
        Allows sorting by Application Version.
    .PARAMETER SortByInstallDate
        Allows sortign by Application Install Date.
    .PARAMETER RawOutput
        Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
    .EXAMPLE
        Get-FtAvidSoftware -ComputerIP $all -Credential $cred
        Get-FtAvidSoftware -ComputerIP $all -Credential $cred -SortByDisplayVersion

    #>
    
    Param(
        [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $false)] [switch]$SortByAlias,
        [Parameter(Mandatory = $false)] [switch]$SortByHostnameInConfig,
        [Parameter(Mandatory = $false)] [switch]$SortByDisplayName,
        [Parameter(Mandatory = $false)] [switch]$SortByDisplayVersion,
        [Parameter(Mandatory = $false)] [switch]$SortByInstallDate,
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    $HeaderMessage = "Installed Avid Software Versions"

    $ScriptBlock = @()
    $ScriptBlock = { Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Where-Object { ($_.Publisher -like "*Avid*") -or ($_.DisplayName -like "*Avid*") -or ($_.DisplayName -like "*Isis*") -or ($_.DisplayName -like "*Nexis*") } }

    $ActionIndex = Confirm-FtSwitchParameters $SortByAlias $SortByHostnameInConfig $SortByDisplayName $SortByDisplayVersion $SortByInstallDate -DefaultSwitch 0
    
    if ($ActionIndex -ne -1) {
        $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

        $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'DisplayName', 'DisplayVersion', 'InstallDate') 

        if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
        else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
    }  
}

function Get-FtAvidServices {
    <#
    .SYNOPSIS
        Gets information about Installed Avid Services.
    .DESCRIPTION
        The Get-FtServices function uses Get-Service -Displayname "Avid*" command to gather Status and StartType of Installed Avid Services on a server.
        Results are sorted by Alias, unless one of the 'SortBy' switches is selected.
    .PARAMETER ComputerIP
        Specifies the computer IP.
    .PARAMETER Credential
        Specifies the credentials used to login.
    .PARAMETER SortByAlias
        Allows sorting by Alias. This is the default sort property, if none of the sort parameters are selected.
    .PARAMETER SortByHostnameInConfig
        Allows sorting by Hostname in $SysConfig variable.
    .PARAMETER SortByDisplayName
        Allows sorting by Service Display Name.
    .PARAMETER SortByStatus
        Allows sorting by Service Status.
    .PARAMETER SortByStartType
        Allows sorting by Service Start Type.
    .PARAMETER RawOutput
        Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
    .EXAMPLE
        Get-FtAvidServices -ComputerIP $all -Credential $cred
        Get-FtAvidServices -ComputerIP $all -Credential $cred -SortByStatus
    #>
    Param(
        [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $false)] [switch]$SortByAlias,
        [Parameter(Mandatory = $false)] [switch]$SortByHostnameInConfig,
        [Parameter(Mandatory = $false)] [switch]$SortByDisplayName,
        [Parameter(Mandatory = $false)] [switch]$SortByStatus,
        [Parameter(Mandatory = $false)] [switch]$SortByStartType,
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    $HeaderMessage = "Avid Services Status"

    $ScriptBlock = { Get-Service -Displayname "Avid*" }

    $ActionIndex = Confirm-FtSwitchParameters $SortByAlias $SortByHostnameInConfig $SortByDisplayName $SortByStatus $SortByStartType -DefaultSwitch 0
    
    if ($ActionIndex -ne -1) {
        $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

        $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'DisplayName', 'Status', 'StartType') 

        if ($RawOutput) { 
            Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
        else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
    }
}




