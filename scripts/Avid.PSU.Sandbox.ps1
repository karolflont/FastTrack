##############
### ACCESS ###
##############
function Install-AvAccess{
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
    
    Write-Host -BackgroundColor White -ForegroundColor Red "`n Not working as expected for .exe. Exiting... "
    return

    $InstallerFileName = Split-Path $PathToInstaller -leaf
    $PathToInstallerRemote = 'C:\AccessTempDir\' + $InstallerFileName
    
    #1. Check if the PathToInstaller is valid - cancel installation if not.
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Checking if the path to installer is a valid one. Please wait... "
    if (-not (Test-Path -Path $PathToInstaller -PathType leaf)){
        Write-Host -BackgroundColor White -ForegroundColor Red "`n Path is not valid. Exiting... "
        return
    }
    else {
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Path is valid. Let's continue... "
    }
    
    #2. Create the AccessTempDir on remote hosts
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Creating folder C:\AccessTempDir on remote hosts. Please wait... "
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {New-Item -ItemType 'directory' -Path 'C:\AccessTempDir' | Out-Null}
    Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Folder C:\AccessTempDir SUCCESSFULLY created on all remote hosts. "
    
    #3. Copy the Access installer to the local drive of remote hosts
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Copying the installer to remote hosts. Please wait... "
    $ComputerName | ForEach-Object -Process {
        $Session = New-PSSession -ComputerName $_ -Credential $Credential
        Copy-Item -LiteralPath $PathToInstaller -Destination "C:\AccessTempDir\" -ToSession $Session
    }
    Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Installer SUCCESSFULLY copied to all remote hosts. "
    
    #4. Unblock the copied installer (so no "Do you want to run this file?" pop-out hangs the installation in the next step)
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Unblocking copied files. Please wait... "
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Unblock-File -Path $using:PathToInstallerRemote}
    Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n All files SUCCESSFULLY unblocked. "
    
    #5. Run the installer on remote hosts
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Installation in progress. This should take up to a minute. Please wait... "
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Start-Process -FilePath $using:PathToInstallerRemote -ArgumentList '/quiet /norestart' -Wait}
    
    #6. Remove folder C:\AccessTempDir from remote hosts
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Installation of Access Client on all remote hosts DONE. Cleaning up..."
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Remove-Item -Path "C:\AccessTempDir\" -Recurse}
}

<#
CREATING NEW OBJECT
$obj = New-Object -TypeName psobject
$obj | Add-Member -MemberType NoteProperty -Name firstname -Value 'Prateek'
$obj | Add-Member -MemberType NoteProperty -Name lastname -Value 'Singh'

# add a method to an object
$obj | Add-Member -MemberType ScriptMethod -Name "GetName" -Value {$this.firstname +' '+$this.lastname}
#>