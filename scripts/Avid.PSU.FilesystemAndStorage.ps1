#################################################
##### SHOW HIDDEN FILES, FOLDERS AND DRIVES #####
#################################################
# This is the equivalent of Folder Menu -> Tools -> Folder Options -> View -> Advanced settings -> Show hidden files, folders and drives
function Get-AvHiddenFilesAndFoldersStatus{
    ### Get "Show hidden files, folders and drives" option status
<#
.SYNOPSIS
   TODO
.DESCRIPTION
   TODO
.PARAMETER ComputerIP
   Specifies the computer name.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   TODO
#>
param(
    [Parameter(Mandatory = $true)] $ComputerIP,
    [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
)
    $HiddenFilesAndFoldersStatus = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden"}
    Write-Host -ForegroundColor Cyan "`n SHOW HIDDEN FILES, FOLDERS AND DRIVES STATUS"
    Write-Host -ForegroundColor Cyan " 1 - Hidden files, folders and drives SHOWN  "
    Write-Host -ForegroundColor Cyan " 2 - Hidden files, folders and drives HIDDEN "
    $HiddenFilesAndFoldersStatus | Select-Object PSComputerName, Hidden | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}


function Set-AvHiddenFilesAndFolders{
    <#
    .SYNOPSIS
        Shows or hides hidden files and folders.
    .DESCRIPTION
        The Set-HiddenFilesAndFolders function shows or hides hidden files and folders.

        The function sets the value of "Hidden" value in "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" key.
        NOTE: This function restarts Explorer process if it is running (server has a GUI and somebody is logged on). This is necessary for this registry settings change to work.
    .PARAMETER ComputerIP
        Specifies the computer name.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    param(
    [Parameter(Mandatory = $true)] $ComputerIP,
    [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
    [Parameter(Mandatory = $false)] [switch]$Show,
    [Parameter(Mandatory = $false)] [switch]$Hide
    )

    Write-Host -ForegroundColor Yellow "`nWARNING: This will restart the explorer.exe process on all hosts after changing the parameter. "
    Write-Host -ForegroundColor Red "This means ALL your opened folders will be closed and ongoing copy processes will also be stopped. Press Enter to continue or Ctrl+C to quit. "
    [void](Read-Host)

    if ($Show) {
        if ($Hide) {
            Write-Host -ForegroundColor Red "`nPlease specify ONLY ONE of the -Show/-Hide switch parameters. "
        Return
        }
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
            Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value "1"
            if (Get-Process explorer -ErrorAction SilentlyContinue){
                Stop-Process -ProcessName explorer -Force
            }
        }
        Write-Host -ForegroundColor Green "`nHidden files and folders SHOWN. "
    }
    elseif ($Hide) {
        if ($Show) {
            Write-Host -ForegroundColor Red "`nPlease specify ONLY ONE of the -Show/-Hide switch parameters. "
            Return
        }
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
            Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value "2"
            if (Get-Process explorer -ErrorAction SilentlyContinue){
                Stop-Process -ProcessName explorer -Force
            }
        }
        Write-Host -ForegroundColor Green "`nHidden files and folders HIDDEN. "
    }
    else {
        Write-Host -ForegroundColor Red "`nPlease specify ONE of the -Show/-Hide switch parameters. "
        Return
    }

    Get-AvHiddenFilesAndFoldersStatus $ComputerIP $Credential
}