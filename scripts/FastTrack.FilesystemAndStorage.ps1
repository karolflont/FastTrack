# Copyright (C) 2018  Karol Flont
# Full license notice can be found in FastTrack.psd1 file.

#################################################
##### SHOW HIDDEN FILES, FOLDERS AND DRIVES #####
#################################################
function Get-FtHiddenFilesAndFolders {
    <#
.SYNOPSIS
   Displays the "Show hidden files, folders and drives" option status.
.DESCRIPTION
   The Get-FtHiddenFilesAndFolders function check the "Hidden" value of "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" key. This key is set in GUI by Folder Menu -> Tools -> Folder Options -> View -> Advanced settings -> Show hidden files checkbox.
.PARAMETER ComputerIP
   Specifies the computer IP.
.PARAMETER Credential
   Specifies the credentials used to login.
.PARAMETER RawOutput
   Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
.EXAMPLE
   Get-FtHiddenFilesAndFolders -ComputerIP $all -Credential $cred
#>
    param(
        [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    $HeaderMessage = "Hidden files and folders status"

    $ScriptBlock = {
        $HiddenFilesAndFoldersStatus = (Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden").Hidden
        if ($HiddenFilesAndFoldersStatus -eq 1) {
            $HiddenFilesAndFoldersStatus = "SHOWN"
        }
        elseif ($HiddenFilesAndFoldersStatus -eq 2) {
            $HiddenFilesAndFoldersStatus = "HIDDEN"
        }
        else {
            $HiddenFilesAndFoldersStatus = "UNKNOWN"
        }
        [pscustomobject]@{
            HiddenFilesAndFoldersStatus = $HiddenFilesAndFoldersStatus
        }
    }
   
    $ActionIndex = 0
   
    $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

    $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'HiddenFilesAndFoldersStatus') 

    if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
    else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}


function Set-FtHiddenFilesAndFolders {
    <#
    .SYNOPSIS
        Shows or hides hidden files and folders.
    .DESCRIPTION
        The Set-HiddenFilesAndFolders function sets the "Hidden" value in "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" key.
        WARNING: This function restarts Explorer process if the process is running (i.e. server has a GUI and somebody is logged on). This is necessary for this registry settings change to work.
    .PARAMETER ComputerIP
        Specifies the computer IP.
    .PARAMETER Credential
        Specifies the credentials used to login.
    .PARAMETER DontCheck
        A switch disabling checking the set configuration with a correstponding 'get' function.
    .EXAMPLE
        Set-FtHiddenFilesAndFolders -ComputerIP $all -Credential $cred -Show
    #>
    param(
        [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $false)] [switch]$Show,
        [Parameter(Mandatory = $false)] [switch]$Hide,
        [Parameter(Mandatory = $false)] [switch]$DontCheck
    )

    $HeaderMessage = "Hidden files and folders status"

    $ActionIndex = Confirm-FtSwitchParameters $Show $Hide

    Write-Warning "A restart of explorer.exe process on all remote hosts is needed after this operation. This means ALL your opened folders on the selected hosts will be closed and ongoing copy processes will also be stopped."
    $Continue = Read-Host 'Do you want to continue? Only yes will be accepted as confirmation.'

    if ($Continue -ne 'yes') {
        Return
    }

    if ($ActionIndex -eq 0) {
        #If Show switch was selected
        $ScriptBlock = {
            Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value "1"
            if (Get-Process explorer -ErrorAction SilentlyContinue) {
                Stop-Process -ProcessName explorer -Force
            }
        }
    }
    elseif ($ActionIndex -eq 1) {
        #If Hide switch was selected
        $ScriptBlock = {
            Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value "2"
            if (Get-Process explorer -ErrorAction SilentlyContinue) {
                Stop-Process -ProcessName explorer -Force
            }
        }
    }

    Invoke-FtSetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

    if (!$DontCheck -and ($ActionIndex -ne -1)) {
        Write-Host -ForegroundColor Cyan "Let's check the configuration with Get-FtHiddenFilesAndFolders."
        Get-FtHiddenFilesAndFolders -ComputerIP $ComputerIP -Credential $cred
    }
}