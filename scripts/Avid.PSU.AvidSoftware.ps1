#################
##### NEXIS #####
#################
function Install-AvNexisClient {
    <#
.SYNOPSIS
   Silently installs AvidNEXIS Client on remote hosts.
.DESCRIPTION
   The Install-NexisClientconsists of six steps:
   1) Check if the PathToInstaller is valid
   2) Create the C:\NexisTempDir on remote hosts
   3) Copy the AvidNEXIS installer to the C:\NexisTempDir on remote hosts
   4) Unblock the copied installer file (so no "Do you want to run this file?" pop-out appears resulting in instalation hang in the next step)
   5) Run the installer on remote hosts
   6) Remove folder C:\NexisTempDir from remote hosts
   7) [OPTIONAL] Reboot the remote hosts
.PARAMETER ComputerIP
   Specifies the computer IP.
.PARAMETER Credentials
   Specifies the credentials used to login.
.PARAMETER PathToInstaller
   Specifies the LOCAL path to the installer.
.PARAMETER RebootAfterInstallation
   Specifies if remote hosts shuld be rebooted after the installation.
.EXAMPLE
   Install-NexisClient -ComputerIP $all_hosts -Credential $Cred -PathToInstaller 'C:\AvidInstallers\AvidNEXISClient_Win64_18.11.0.9.msi' -RebootAfterInstallation
#>

    <#
TODO
Wait for rebooted hosts to come back.
#>

    Param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $true)] $PathToInstaller,
        [Parameter(Mandatory = $false)] [switch]$RebootAfterInstallation
    )

    if ($RebootAfterInstallation) {
        Write-Warning "All the remote hosts will be automatically rebooted after the installation. Press Enter to continue or Ctrl+C to quit."
        [void](Read-Host)
    }

    $InstallerFileName = Split-Path $PathToInstaller -leaf
    $PathToInstallerRemote = 'C:\NexisTempDir\' + $InstallerFileName

    #1. Check if the PathToInstaller is valid - cancel installation if not.
    Write-Host -ForegroundColor Cyan "`nChecking if the path to installer is a valid one. Please wait..."
    if (-not (Test-Path -Path $PathToInstaller -PathType leaf)) {
        Write-Host -ForegroundColor Red "`nPath is not valid. Exiting..."
        return
    }
    else {
        Write-Host -ForegroundColor Green "`nPath is valid. Let's continue..."
    }

    #2. Create the NexisTempDir on remote hosts
    Write-Host -ForegroundColor Cyan "`nCreating folder C:\NexisTempDir on remote hosts. Please wait..."
    Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { New-Item -ItemType 'directory' -Path 'C:\NexisTempDir' | Out-Null }
    Write-Host -ForegroundColor Green "`nFolder C:\NexisTempDir SUCCESSFULLY created on selected remote hosts."

    #3. Copy the AvidNEXIS installer to the local drive of remote hosts
    Write-Host -ForegroundColor Cyan "`nCopying the installer to remote hosts. Please wait..."
    $ComputerIP | ForEach-Object -Process {
        $Session = New-PSSession -ComputerName $_ -Credential $Credential
        Copy-Item -LiteralPath $PathToInstaller -Destination "C:\NexisTempDir\" -ToSession $Session
    }
    Write-Host -ForegroundColor Green "`nInstaller SUCCESSFULLY copied to selected remote hosts."

    #4. Unblock the copied installer (so no "Do you want to run this file?" pop-out hangs the installation in the next step)
    Write-Host -ForegroundColor Cyan "`nUnblocking copied files. Please wait..."
    Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Unblock-File -Path $using:PathToInstallerRemote }
    Write-Host -ForegroundColor Green "`nAll files SUCCESSFULLY unblocked."

    #5. Run the installer on remote hosts
    Write-Host -ForegroundColor Cyan "`nInstallation in progress. This should take up to a minute. Please wait..."
    Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Start-Process -FilePath $using:PathToInstallerRemote -ArgumentList '/quiet /norestart' -Wait }

    #6. Remove folder C:\NexisTempDir from remote hosts
    Write-Host -ForegroundColor Cyan "`nInstallation of AvidNEXIS Client on selected remote hosts DONE. Cleaning up..."
    Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Remove-Item -Path "C:\NexisTempDir\" -Recurse }

    #7. Reboot remote hosts if $RebootAfterInstallation switch present
    if ($RebootAfterInstallation) {
        Write-Host -ForegroundColor Cyan "`nWaiting for selected remote hosts to reboot (We'll not wait more than 5 minutes though.)..."
        Restart-Computer -ComputerName $ComputerIP -Credential $Credential -Wait -For PowerShell -Timeout 300 -WsmanAuthentication Default -Force
        Write-Host -ForegroundColor Cyan "`nselected remote hosts rebooted and available for PowerShell Remoting again."
    }
    else {
        Write-Host -ForegroundColor Red "`nRemote hosts were NOT REBOOTED after the installation of AvidNEXIS Client."
        Write-Host -ForegroundColor Red "Please REBOOT manually later as this is required for AvidNEXIS Client to work properly."
    }
}

function Uninstall-AvNexisClient {
    <#
.SYNOPSIS
   Silently uninstalls AvidNEXIS Client on remote hosts.
.DESCRIPTION
   The Uninstall-NexisClient
.PARAMETER ComputerIP
   Specifies the computer IP.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   Uninstall-NexisClient -ComputerIP $all_hosts -Credential $Cred -RebootAfterUninstallation
#>

    Param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch]$RebootAfterUninstallation
    )

    if ($RebootAfterUninstallation) {
        Write-Warning "All the remote hosts will be automatically rebooted after the installation. Press Enter to continue or Ctrl+C to quit."
        [void](Read-Host)
    }

    #1. Uninstall AvidNEXIS Client on remote hosts
    Write-Host -ForegroundColor Cyan "`nUninstallation in progress. This can take a while. Please wait..."
    Invoke-Command -ComputerName $ComputerIP -Credential $Cred -ScriptBlock {
        $app = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match "Avid NEXIS Client" }
        $app.Uninstall()
    }
    Write-Host -ForegroundColor Green "`nUninstallation of AvidNEXIS Client on selected remote hosts DONE."

    #2. Reboot remote hosts if $reboot switch present
    if ($RebootAfterUninstallation) {
        Write-Host -ForegroundColor Cyan "`nWaiting for selected remote hosts to reboot (We'll not wait more than 5 minutes though.)..."
        Restart-Computer -ComputerName $ComputerIP -Credential $Credential -Wait -For PowerShell -Timeout 300 -WsmanAuthentication Default -Force
        Write-Host -ForegroundColor Cyan "`nselected remote hosts rebooted and available for PowerShell Remoting again."
    }
    else {
        Write-Host -ForegroundColor Red "`nRemote hosts were NOT REBOOTED after uninstallation of AvidNEXIS Client."
    }

}
###############################
##### AVID SOFTWARE CHECK #####
###############################
function Get-AvSoftwareVersions {
    <#
    .SYNOPSIS
        Gets installed Avid Software versions.
    .DESCRIPTION
        The Get-AvSoftwareVersions function retrieves all the keys from "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\" containing words:
        - Avid in the "Publishers" value
        - {Avid|Isis|Nexis} in "DisplayName" value
        Results are sorted by Alias, unless one of the 'SortBy' switches is selected.
    .PARAMETER ComputerIP
        Specifies computer IP.
    .PARAMETER Credentials
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
    .EXAMPLE
        Get-AvSoftwareVersions -ComputerIP $all -Credential $cred
        Get-AvSoftwareVersions -ComputerIP $all -Credential $cred -SortByDisplayVersion

    #>
    
    Param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch]$SortByAlias,
        [Parameter(Mandatory = $false)] [switch]$SortByHostnameInConfig,
        [Parameter(Mandatory = $false)] [switch]$SortByDisplayName,
        [Parameter(Mandatory = $false)] [switch]$SortByDisplayVersion,
        [Parameter(Mandatory = $false)] [switch]$SortByInstallDate,
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    $HeaderMessage = "----- Installed Avid Software Versions -----"

    $ScriptBlock = { Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Where-Object { ($_.Publisher -like "*Avid*") -or ($_.DisplayName -like "*Avid*") -or ($_.DisplayName -like "*Isis*") -or ($_.DisplayName -like "*Nexis*") } }

    $NullMessage = "NO Avid Software installed on any of the remote hosts."

    $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'DisplayName', 'DisplayVersion', 'InstallDate') 

    $ActionIndex = Test-AvIfExactlyOneSwitchParameterIsTrue $SortByAlias $SortByHostnameInConfig $SortByDisplayName $SortByDisplayVersion $SortByInstallDate
    
    if ($RawOutput) {
        Invoke-AvScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput
    }
    else {
        Invoke-AvScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex
    }
}

function Get-AvServicesStatus {
    <#
    .SYNOPSIS
        Gets information about Installed Avid Services.
    .DESCRIPTION
        The Get-AvServices function uses Get-Service -Displayname "Avid*" command to gather Status and StartType of Installed Avid Services on a server.
        Results are sorted by Alias, unless one of the 'SortBy' switches is selected.
    .PARAMETER ComputerIP
        Specifies the computer IP.
    .PARAMETER Credentials
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
    .EXAMPLE
        Get-AvServicesStatus -ComputerIP $all -Credential $cred
        Get-AvServicesStatus -ComputerIP $all -Credential $cred -SortByStatus
    #>
    Param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch]$SortByAlias,
        [Parameter(Mandatory = $false)] [switch]$SortByHostnameInConfig,
        [Parameter(Mandatory = $false)] [switch]$SortByDisplayName,
        [Parameter(Mandatory = $false)] [switch]$SortByStatus,
        [Parameter(Mandatory = $false)] [switch]$SortByStartType,
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    $HeaderMessage = "----- Avid Services Status -----"

    $ScriptBlock = { Get-Service -Displayname "Avid*" }

    $NullMessage = "`nNO Avid Services running on any of the remote hosts."

    $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'DisplayName', 'Status', 'StartType') 

    $ActionIndex = Test-AvIfExactlyOneSwitchParameterIsTrue $SortByAlias $SortByHostnameInConfig $SortByDisplayName $SortByStatus $SortByStartType
    
    if ($RawOutput) {
        Invoke-AvScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput
    }
    else {
        Invoke-AvScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex
    }
}




