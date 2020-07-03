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
   Specifies if the output should be formatted (human friendly output) or not (Powershell pipeline friendly output)
.EXAMPLE
   Get-FtHiddenFilesAndFolders -ComputerIP $all -Credential $cred
#>
    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
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
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $false)] [switch]$Show,
        [Parameter(Mandatory = $false)] [switch]$Hide,
        [Parameter(Mandatory = $false)] [switch]$DontCheck
    )

    Write-Warning "This will restart the explorer.exe process on all hosts after changing the parameter. This means ALL your opened folders on the selected hosts will be closed and ongoing copy processes will also be stopped. Only yes will be accepted as confirmation."
    $Continue = Read-Host 'Do you really want to continue?'

    if ($Continue -ne 'yes') {
        Return
    }

    $ActionIndex = Confirm-FtSwitchParameters $Show $Hide
    $ScriptBlock = @()

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

    Invoke-FtSetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

    if (!$DontCheck -and ($ActionIndex -ne -1)) {
        Write-Host -ForegroundColor Cyan "Let's check the configuration with Get-FtHiddenFilesAndFolders."
        Get-FtHiddenFilesAndFolders -ComputerIP $ComputerIP -Credential $cred
    }
}