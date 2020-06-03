#################################################
##### SHOW HIDDEN FILES, FOLDERS AND DRIVES #####
#################################################
function Get-FtHiddenFilesAndFoldersStatus {
    <#
.SYNOPSIS
   Displays the "Show hidden files, folders and drives" option status.
.DESCRIPTION
   The Get-FtHiddenFilesAndFoldersStatus function check the "Hidden" value of "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" key. This key is set in GUI by Folder Menu -> Tools -> Folder Options -> View -> Advanced settings -> Show hidden files checkbox.
.PARAMETER ComputerIP
   Specifies the computer IP.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   Get-FtHiddenFilesAndFoldersStatus -ComputerIP $all -Credential $cred
#>
    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    $HeaderMessage = "----- Hidden files and folders status -----"

    $ScriptBlock = {
        $HiddenFilesAndFoldersStatus = (Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden").Hidden
        if ($HiddenFilesAndFoldersStatus -eq 1){
            $HiddenFilesAndFoldersStatus = "SHOWN"
        }
        elseif ($HiddenFilesAndFoldersStatus -eq 2){
            $HiddenFilesAndFoldersStatus = "HIDDEN"
        }
        else {
            $HiddenFilesAndFoldersStatus = "UNKNOWN"
        }
        [pscustomobject]@{
            HiddenFilesAndFoldersStatus = $HiddenFilesAndFoldersStatus
        }
    }

    $NullMessage = "Something went wrong retrieving Hidden files and folders status from selected remote hosts"
   
    $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'HiddenFilesAndFoldersStatus') 

    $ActionIndex = 0
   
    if ($RawOutput) {
        Invoke-FtScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput
    }
    else {
        Invoke-FtScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex
    }
}


function Set-FtHiddenFilesAndFolders {
    <#
    .SYNOPSIS
        Shows or hides hidden files and folders.
    .DESCRIPTION
        The Set-HiddenFilesAndFolders function shows or hides hidden files and folders.

        The function sets the value of "Hidden" value in "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" key.
        NOTE: This function restarts Explorer process if it is running (server has a GUI and somebody is logged on). This is necessary for this registry settings change to work.
    .PARAMETER ComputerIP
        Specifies the computer IP.
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

    Write-Warning "This will restart the explorer.exe process on all hosts after changing the parameter."
    Write-Host -ForegroundColor Red "This means ALL your opened folders will be closed and ongoing copy processes will also be stopped. Press Enter to continue or Ctrl+C to quit."
    [void](Read-Host)

    if ($Show) {
        if ($Hide) {
            Write-Host -ForegroundColor Red "`nPlease specify ONLY ONE of the -Show/-Hide switch parameters."
            Return
        }
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
            Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value "1"
            if (Get-Process explorer -ErrorAction SilentlyContinue) {
                Stop-Process -ProcessName explorer -Force
            }
        }
        Write-Host -ForegroundColor Green "`nHidden files and folders SHOWN."
    }
    elseif ($Hide) {
        if ($Show) {
            Write-Host -ForegroundColor Red "`nPlease specify ONLY ONE of the -Show/-Hide switch parameters."
            Return
        }
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
            Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value "2"
            if (Get-Process explorer -ErrorAction SilentlyContinue) {
                Stop-Process -ProcessName explorer -Force
            }
        }
        Write-Host -ForegroundColor Green "`nHidden files and folders HIDDEN."
    }
    else {
        Write-Host -ForegroundColor Red "`nPlease specify ONE of the -Show/-Hide switch parameters."
        Return
    }

    Get-FtHiddenFilesAndFoldersStatus $ComputerIP $Credential
}