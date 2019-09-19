function Get-PartitionInfo{
}
function Set-Partition{
    param(
    [Parameter(Mandatory = $true)] $ComputerName,
    [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
    [Parameter(Mandatory = $true)] [switch] $resize,
    [Parameter(Mandatory = $true)] [switch] $create
)
}
#################################################
##### SHOW HIDDEN FILES, FOLDERS AND DRIVES #####
#################################################
# This is the equivalent of Folder Menu -> Tools -> Folder Options -> View -> Advanced settings -> Show hidden files, folders and drives
function Get-HiddenFilesAndFoldersStatus{
    ### Get "Show hidden files, folders and drives" option status
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
    $HiddenFilesAndFoldersStatus = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden"}
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue " `n SHOW HIDDEN FILES, FOLDERS AND DRIVES STATUS"
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue " 1 - Hidden files, folders and drives SHOWN  "
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue " 2 - Hidden files, folders and drives HIDDEN "
    $HiddenFilesAndFoldersStatus | Select-Object PSComputerName, Hidden | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}
function Set-HiddenFilesAndFolders{
    <#
    .SYNOPSIS
        Shows or hides hidden files and folders.
    .DESCRIPTION
        The Set-HiddenFilesAndFolders function shows or hides hidden files and folders.

        The function sets the value of "Hidden" value in "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" key.
        NOTE: This function restarts Explorer process if it is running (server has a GUI and somebody is logged on). This is necessary for this registry settings change to work.
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
    [Parameter(Mandatory = $false)] [switch]$Show,
    [Parameter(Mandatory = $false)] [switch]$Hide
    )

    Write-Host -BackgroundColor White -ForegroundColor Red "`n WARNING: This will restart the explorer.exe process on all hosts after changing the parameter. "
    Write-Host -BackgroundColor White -ForegroundColor Red "This means ALL your opened folders will be closed and ongoing copy processes will also be stopped. Press Enter to continue or Ctrl+C to quit. "
    [void](Read-Host)

    if ($Show) {
        if ($Hide) {
            Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONLY ONE of the -Show/-Hide switch parameters. "
        Return
        }
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
            Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value "1"
            if (Get-Process explorer -ErrorAction SilentlyContinue){
                Stop-Process -ProcessName explorer -Force
            }
        }
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Hidden files and folders SHOWN. "
    }
    elseif ($Hide) {
        if ($Show) {
            Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONLY ONE of the -Show/-Hide switch parameters. "
            Return
        }
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
            Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value "2"
            if (Get-Process explorer -ErrorAction SilentlyContinue){
                Stop-Process -ProcessName explorer -Force
            }
        }
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Hidden files and folders HIDDEN. "
    }
    else {
        Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONE of the -Show/-Hide switch parameters. "
        Return
    }

    Get-HiddenFilesAndFoldersStatus $ComputerName $Credential
}