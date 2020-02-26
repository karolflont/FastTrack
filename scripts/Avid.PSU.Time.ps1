#########################
##### TIME SETTINGS #####
#########################
function Get-AvTimeAndTimeZone{
<#
.SYNOPSIS
   Gets current time and time zone from servers.
.DESCRIPTION
   The Get-AvTime function gets current Date, Time, Time Zone and Daylight Saving Time information from a server.
   
   The function uses Get-Date and Get-TimeZone cmdlet.
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

    Write-Host "This funciton does not work when the computer from which you run the function has a different timezone set than"
    Write-Host "the computers you provide in the -ComputerName parameter. It displays time in your computer timezone and not the remote hosts one."
    Write-Host "This needs to be corrected."

    $TimeZone = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{Get-TimeZone}
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Current TIMEZONE on servers "
    $TimeZone | Select-Object PSComputerName, StandardName, BaseUtcOffset, SupportsDaylightSavingTime | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize

    #$Time = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{Get-Date | Out-String}
    #Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Current TIME on servers "
    #$Time | Select-Object PSComputerName, DateTime | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}
function Set-AvTimeAndTimeZone{
}
#####################
##### TIME SYNC #####
#####################
function Install-AvMeinbergNTPDaemon{
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

Write-Host -BackgroundColor White -ForegroundColor Red "`n WARNING: All the remote hosts will be automatically rebooted after the installation. Press Enter to continue or Ctrl+C to quit. "
[void](Read-Host)

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
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Start-Process -FilePath $using:PathToInstallerRemote -ArgumentList '/quiet' -Wait}
Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Installation on all remote hosts DONE. Rebooting... "
}
function Push-AvMeinbergNTPDaemonConfig{
}
function Get-AvTimeSyncStatus{
}