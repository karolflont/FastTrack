#################
##### NEXIS #####
#################

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
function Get-APSUNexisClientVersion($ComputerName,[System.Management.Automation.PSCredential] $Credential){
### Check if NEXIS/ISIS client is already installed ###
    $Results = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, InstallDate | Where-Object {($_.DisplayName -like "*Isis*") -or ($_.DisplayName -like "*Nexis*")}}
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Nexis Client Versions Installed "
    $Results | Select-Object PSComputerName, DisplayName, DisplayVersion, InstallDate | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}


function Install-APSUNexisClient($ComputerName, [System.Management.Automation.PSCredential] $Credential, $PathToInstaller, [switch]$RebootAfterInstallation){
<#
.SYNOPSIS
   Silently installs AvidNEXIS Client on remote hosts.
.DESCRIPTION
   The Install-APSUNexisClientconsists of six steps:
   1) Create the C:\NexisTempDir on remote hosts
   2) Copy the AvidNEXIS installer to the C:\NexisTempDir on remote hosts
   3) Unblock the copied installer file (so no "Do you want to run this file?" pop-out appears resulting in instalation hang in the next step)
   4) Run the installer on remote hosts
   5) Remove folder C:\NexisTempDir from remote hosts
   6) [OPTIONAL] Reboot the remote hosts
.PARAMETER ComputerName
   Specifies the computer name.
.PARAMETER Credentials
   Specifies the credentials used to login.
.PARAMETER PathToInstaller
   Specifies the LOCAL path to the installer.
.PARAMETER RebootAfterInstallation
   Specifies if remote hosts shuld be rebooted after the installation.
.EXAMPLE
   Install-APSUNexisClient -ComputerName $all_hosts -Credential $Cred -PathToInstaller 'C:\AvidInstallers\AvidNEXISClient_Win64_18.11.0.9.msi' -RebootAfterInstallation
#>

if ($RebootAfterInstallation)
    {
        Write-Host -BackgroundColor White -ForegroundColor Red "`n WARNING: All the remote hosts will be automatically rebooted after the installation. Press Enter to continue or Ctrl+C to quit. "
        [void](Read-Host)
    }

$InstallerFileName = Split-Path $PathToInstaller -leaf
$PathToInstallerRemote = 'C:\NexisTempDir\' + $InstallerFileName

#1. Create the NexisTempDir on remote hosts
Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Creating folder C:\NexisTempDir on remote hosts. Please wait... "
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {New-Item -ItemType 'directory' -Path 'C:\NexisTempDir'}
Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Folder C:\NexisTempDir SUCCESSFULLY created on all remote hosts. "

#2. Copy the AvidNEXIS installer to the local drive of remote hosts
Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Copying the installer to remote hosts. Please wait... "
$ComputerName | ForEach-Object -Process {
    $Session = New-PSSession -ComputerName $_ -Credential $Credential
    Copy-Item -LiteralPath $PathToInstaller -Destination "C:\NexisTempDir\" -ToSession $Session
}
Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Installer SUCCESSFULLY copied to all remote hosts. "

#3. Unblock the copied installer (so no "Do you want to run this file?" pop-out hangs the installation in the next step)
Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Unblocking copied files. Please wait... "
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Unblock-File -Path $using:PathToInstallerRemote}
Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n All files SUCCESSFULLY unblocked. "

#4. Run the installer on remote hosts
Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Installation in progress. This should take up to a minute. Please wait... "
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Start-Process -FilePath $using:PathToInstallerRemote -ArgumentList '/quiet /norestart' -Wait}

#5. Remove folder C:\NexisTempDir from remote hosts
Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Installation of AvidNEXIS Client on all remote hosts DONE. Cleaning up..."
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Remove-Item -Path "C:\NexisTempDir\" -Recurse}

#6. Reboot remote hosts if $RebootAfterInstallation switch present
if ($RebootAfterInstallation) 
    {
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Restart-Computer -Force}
        Write-Host -BackgroundColor White -ForegroundColor Red "`n Reboot triggered for all remote hosts. "
    }
else
    {
        Write-Host -BackgroundColor White -ForegroundColor Red "`n Remote hosts were NOT REBOOTED after the installation of AvidNEXIS Client. "
        Write-Host -BackgroundColor White -ForegroundColor Red " Please REBOOT manually later as this is required for AvidNEXIS Client to work properly. "
    }
}

function Uninstall-APSUNexisClient($ComputerName,[System.Management.Automation.PSCredential] $Credential,[switch]$RebootAfterUninstallation){
<#
.SYNOPSIS
   Silently uninstalls AvidNEXIS Client on remote hosts.
.DESCRIPTION
   The Uninstall-APSUNexisClient
.PARAMETER ComputerName
   Specifies the computer name.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   Uninstall-APSUNexisClient -ComputerName $all_hosts -Credential $Cred -RebootAfterUninstallation
#>

if ($RebootAfterUninstallation)
    {
        Write-Host -BackgroundColor White -ForegroundColor Red "`n WARNING: All the remote hosts will be automatically rebooted after the installation. Press Enter to continue or Ctrl+C to quit. "
        [void](Read-Host)
    }

#1. Uninstall AvidNEXIS Client on remote hosts
Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Uninstallation in progress. This can take a while. Please wait... "
Invoke-Command -ComputerName $ComputerName -Credential $Cred -ScriptBlock
    {
        $app = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -match "Avid NEXIS Client"}
        $app.Uninstall()
    }
Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Uninstallation of AvidNEXIS Client on all remote hosts DONE. "

#2. Reboot remote hosts if $reboot switch present
if ($RebootAfterUninstallation) 
    {
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Restart-Computer -Force}
        Write-Host -BackgroundColor White -ForegroundColor Red "`n Reboot triggered for all remote hosts. "
    }
else
    {
        Write-Host -BackgroundColor White -ForegroundColor Red "`n Remote hosts were NOT REBOOTED after uninstallation of AvidNEXISClient. "
    }

}

###############################
##### AVID SOFTWARE CHECK #####
###############################

function Get-APSUAvidSoftwareVersions($ComputerName,[System.Management.Automation.PSCredential] $Credential, [switch]$SortByPSComputerName, [switch]$SortByDisplayName, [switch]$SortByDisplayVersion, [switch]$SortByInstallDate){
    <#
    .SYNOPSIS
        Gets installed Avid Software versions.
    .DESCRIPTION
        The Get-APSUAvidSoftwareVersions function consists of two parts:
        1) First, retrieves the version of NXNServer.exe file for Interplay Engine
        2) Second, retrieves all the keys from "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\" containing word "Avid" in the "Publishers" value
    .PARAMETER ComputerName
        Specifies the computer name.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>

    #Default sort property
    $DefaultSortProperty = "PSComputerName"
    $PropertiesToDisplay = ('PSComputerName', 'DisplayName', 'DisplayVersion', 'InstallDate') 

    $SortProperty = Test-SelectedProperties $DefaultSortProperty $PropertiesToDisplay $SortByPSComputerName $SortByDisplayName $SortByDisplayVersion $SortByInstallDate


    if (!$SortProperty) 
    {
        Return
    }
    else {

     <#
    #Checking the input
    $SwitchCount = 0

    if ($SortByPSComputerName)  {
        $SwitchCount = $SwitchCount + 1
        $SortProperty = "PSComputerName"
    }
    if ($SortByDisplayName)  {
        $SwitchCount = $SwitchCount + 1
        $SortProperty = "DisplayName"
    }
    if ($SortByDisplayVersion)  {
        $SwitchCount = $SwitchCount + 1
        $SortProperty = "DisplayVersion"
    }
    if ($SortByInstallDate)  {
        $SwitchCount = $SwitchCount + 1
        $SortProperty = "InstallDate"
    }
    

    if ($SwitchCount -gt 1){
        Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONLY ONE of the -SortByPSComputerName/-SortByDisplayName/-SortByDisplayVersion/-SortByInstallDate switch parameters. "
        Return
    }
    #>

    <# NOT NEEDED ANY MORE IN 2018.11 AND LATER
    $InterplayEngineVersion = Invoke-Command -ComputerName $YLEHKI_servers -Credential $Cred -ScriptBlock{
        If (Test-Path "C:\Program Files\Avid\Avid Interplay Engine\Server\NXNServer.exe"){
            (Get-Item "C:\Program Files\Avid\Avid Interplay Engine\Server\NXNServer.exe").VersionInfo
        }
    }
    $InterplayEngineVersion| Add-Member -MemberType NoteProperty -Name DisplayName -Value "Avid Interplay Engine"
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Interplay Engine and other software versions "
    $InterplayEngineVersion | Select-Object PSComputerName, DisplayName, ProductVersion, FileVersion | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
    #>
    $AvidSoftwareVersions = Invoke-Command -ComputerName $ComputerName -Credential $Cred -ScriptBlock {Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Where-Object {$_.Publisher -like "*Avid*"}}
    #$PropertiesToDisplay = 'PSComputerName, DisplayName, DisplayVersion, InstallDate'

    $AvidSoftwareVersions | Select-Object $PropertiesToDisplay | Sort-Object -Property $SortProperty | Format-Table -Wrap -AutoSize
    }
}
   
function Get-APSUAvidServices($ComputerName,[System.Management.Automation.PSCredential] $Credential){
        <#
    .SYNOPSIS
        Gets information about Installed Avid Services.
    .DESCRIPTION
        The Get-APSUAvidServices function gets Status and StartType of Installed Avid Services on a server.
    .PARAMETER ComputerName
        Specifies the computer name.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    $AvidServices = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-Service -Displayname "Avid*"}
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Avid Services Status "
    $AvidServices | Select-Object PSComputerName, DisplayName, Status, StartType | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}
