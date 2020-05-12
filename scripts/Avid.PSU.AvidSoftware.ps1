#################
##### NEXIS #####
#################
function Install-AvNexisClient{
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
.PARAMETER ComputerName
   Specifies the computer name.
.PARAMETER Credentials
   Specifies the credentials used to login.
.PARAMETER PathToInstaller
   Specifies the LOCAL path to the installer.
.PARAMETER RebootAfterInstallation
   Specifies if remote hosts shuld be rebooted after the installation.
.EXAMPLE
   Install-NexisClient -ComputerName $all_hosts -Credential $Cred -PathToInstaller 'C:\AvidInstallers\AvidNEXISClient_Win64_18.11.0.9.msi' -RebootAfterInstallation
#>

<#
TODO
Wait for rebooted hosts to come back.
#>

Param(
    [Parameter(Mandatory = $true)] $ComputerName,
    [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
    [Parameter(Mandatory = $true)] $PathToInstaller,
    [Parameter(Mandatory = $false)] [switch]$RebootAfterInstallation
)

if ($RebootAfterInstallation)
    {
        Write-Host -ForegroundColor Yellow "`nWARNING: All the remote hosts will be automatically rebooted after the installation. Press Enter to continue or Ctrl+C to quit. "
        [void](Read-Host)
    }

$InstallerFileName = Split-Path $PathToInstaller -leaf
$PathToInstallerRemote = 'C:\NexisTempDir\' + $InstallerFileName

#1. Check if the PathToInstaller is valid - cancel installation if not.
Write-Host -ForegroundColor Cyan "`nChecking if the path to installer is a valid one. Please wait... "
if (-not (Test-Path -Path $PathToInstaller -PathType leaf)){
    Write-Host -ForegroundColor Red "`nPath is not valid. Exiting... "
    return
}
else {
    Write-Host -ForegroundColor Green "`nPath is valid. Let's continue... "
}

#2. Create the NexisTempDir on remote hosts
Write-Host -ForegroundColor Cyan "`nCreating folder C:\NexisTempDir on remote hosts. Please wait... "
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {New-Item -ItemType 'directory' -Path 'C:\NexisTempDir' | Out-Null}
Write-Host -ForegroundColor Green "`nFolder C:\NexisTempDir SUCCESSFULLY created on all remote hosts. "

#3. Copy the AvidNEXIS installer to the local drive of remote hosts
Write-Host -ForegroundColor Cyan "`nCopying the installer to remote hosts. Please wait... "
$ComputerName | ForEach-Object -Process {
    $Session = New-PSSession -ComputerName $_ -Credential $Credential
    Copy-Item -LiteralPath $PathToInstaller -Destination "C:\NexisTempDir\" -ToSession $Session
}
Write-Host -ForegroundColor Green "`nInstaller SUCCESSFULLY copied to all remote hosts. "

#4. Unblock the copied installer (so no "Do you want to run this file?" pop-out hangs the installation in the next step)
Write-Host -ForegroundColor Cyan "`nUnblocking copied files. Please wait... "
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Unblock-File -Path $using:PathToInstallerRemote}
Write-Host -ForegroundColor Green "`nAll files SUCCESSFULLY unblocked. "

#5. Run the installer on remote hosts
Write-Host -ForegroundColor Cyan "`nInstallation in progress. This should take up to a minute. Please wait... "
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Start-Process -FilePath $using:PathToInstallerRemote -ArgumentList '/quiet /norestart' -Wait}

#6. Remove folder C:\NexisTempDir from remote hosts
Write-Host -ForegroundColor Cyan "`nInstallation of AvidNEXIS Client on all remote hosts DONE. Cleaning up..."
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Remove-Item -Path "C:\NexisTempDir\" -Recurse}

#7. Reboot remote hosts if $RebootAfterInstallation switch present
if ($RebootAfterInstallation) 
    {
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Restart-Computer -Force}
        Write-Host -ForegroundColor Red "`nReboot triggered for all remote hosts. "
    }
else
    {
        Write-Host -ForegroundColor Red "`nRemote hosts were NOT REBOOTED after the installation of AvidNEXIS Client. "
        Write-Host -ForegroundColor Red "Please REBOOT manually later as this is required for AvidNEXIS Client to work properly. "
    }
}

function Uninstall-AvNexisClient{
<#
.SYNOPSIS
   Silently uninstalls AvidNEXIS Client on remote hosts.
.DESCRIPTION
   The Uninstall-NexisClient
.PARAMETER ComputerName
   Specifies the computer name.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   Uninstall-NexisClient -ComputerName $all_hosts -Credential $Cred -RebootAfterUninstallation
#>

Param(
[Parameter(Mandatory = $true)] $ComputerName,
[Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
[Parameter(Mandatory = $false)] [System.Diagnostics.Switch]$RebootAfterUninstallation
)

if ($RebootAfterUninstallation)
    {
        Write-Host -ForegroundColor Yellow "`nWARNING: All the remote hosts will be automatically rebooted after the installation. Press Enter to continue or Ctrl+C to quit. "
        [void](Read-Host)
    }

#1. Uninstall AvidNEXIS Client on remote hosts
Write-Host -ForegroundColor Cyan "`nUninstallation in progress. This can take a while. Please wait... "
Invoke-Command -ComputerName $ComputerName -Credential $Cred -ScriptBlock
    {
        $app = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -match "Avid NEXIS Client"}
        $app.Uninstall()
    }
Write-Host -ForegroundColor Green "`nUninstallation of AvidNEXIS Client on all remote hosts DONE. "

#2. Reboot remote hosts if $reboot switch present
if ($RebootAfterUninstallation) 
    {
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Restart-Computer -Force}
        Write-Host -ForegroundColor Red "`nReboot triggered for all remote hosts. "
    }
else
    {
        Write-Host -ForegroundColor Red "`nRemote hosts were NOT REBOOTED after uninstallation of AvidNEXISClient. "
    }

}
###############################
##### AVID SOFTWARE CHECK #####
###############################
function Get-AvSoftwareVersions{
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
    .EXAMPLE
        Get-AvSoftwareVersions -ComputerIP $all -Credential $cred
        Get-AvSoftwareVersions -ComputerIP $all -Credential $cred -SortByDisplayVersion

    #>
    
    Param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch]$SortByAlias,
        [Parameter(Mandatory = $false)] [switch]$SortByHostnameInConfigFile,
        [Parameter(Mandatory = $false)] [switch]$SortByDisplayName,
        [Parameter(Mandatory = $false)] [switch]$SortByDisplayVersion,
        [Parameter(Mandatory = $false)] [switch]$SortByInstallDate
    )

    $PropertiesToDisplay = ('Alias', 'HostnameInConfigFile', 'DisplayName', 'DisplayVersion', 'InstallDate') 

    $ActionIndex = Test-AvIfExactlyOneSwitchParameterIsTrue $SortByAlias $SortByHostnameInConfigFile $SortByDisplayName $SortByDisplayVersion $SortByInstallDate

    # A message displayed in case empty objects are returned from all remote computers
    $NullMessage = "`nNO Avid Software installed on any of the remote hosts. "

    $ScriptBlock = {Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Where-Object {($_.Publisher -like "*Avid*") -or ($_.DisplayName -like "*Avid*") -or ($_.DisplayName -like "*Isis*") -or ($_.DisplayName -like "*Nexis*")}}

    Invoke-AvScriptBlock -ScriptBlock $ScriptBlock -NullMessage $NullMessage -ActionIndex $ActionIndex -PropertiesToDisplay $PropertiesToDisplay -ComputerIP $ComputerIP -Credential $Credential
}

function Get-AvServicesStatus{
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
    .EXAMPLE
        Get-AvServicesStatus -ComputerIP $all -Credential $cred
        Get-AvServicesStatus -ComputerIP $all -Credential $cred -SortByStatus
    #>
    Param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch]$SortByAlias,
        [Parameter(Mandatory = $false)] [switch]$SortByHostnameInConfigFile,
        [Parameter(Mandatory = $false)] [switch]$SortByDisplayName,
        [Parameter(Mandatory = $false)] [switch]$SortByStatus,
        [Parameter(Mandatory = $false)] [switch]$SortByStartType
    )

    $PropertiesToDisplay = ('Alias', 'HostnameInConfigFile', 'DisplayName', 'Status', 'StartType') 

    $ActionIndex = Test-AvIfExactlyOneSwitchParameterIsTrue $SortByAlias $SortByHostnameInConfigFile $SortByDisplayName $SortByStatus $SortByStartType

    # A message displayed in case empty objects are returned from all remote computers
    $NullMessage = "`nNO Avid Services running on any of the remote hosts. "

    $ScriptBlock = {Get-Service -Displayname "Avid*"}

    Invoke-AvScriptBlock -ScriptBlock $ScriptBlock -NullMessage $NullMessage -ActionIndex $ActionIndex -PropertiesToDisplay $PropertiesToDisplay -ComputerIP $ComputerIP -Credential $Credential
}




