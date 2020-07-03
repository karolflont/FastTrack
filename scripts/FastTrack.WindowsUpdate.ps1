##########################
##### WINDOWS UPDATE #####
##########################
function Get-FtWindowsUpdateService {
    <#
.SYNOPSIS
   Gets the information about Windows Update Service on a server.
.DESCRIPTION
   The Get-FtWindowsUpdateService function retrieves the Status and StartType properties of Windows Update Service on a server using "Get-Service -Name wuauserv" cmdlet.
.PARAMETER ComputerIP
   Specifies the computer IP.
.PARAMETER Credential
   Specifies the credentials used to login.
.PARAMETER RawOutput
   Specifies if the output should be formatted (human friendly output) or not (Powershell pipeline friendly output)
.EXAMPLE
   Get-FtWindowsUpdateService -ComputerIP $all -Credential $cred
#>
    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    $HeaderMessage = "Windows Update service status"

    $ScriptBlock = {
        $WinUpdSrv = Get-Service -Name wuauserv

        [pscustomobject]@{
            DisplayName = $WinUpdSrv.DisplayName
            Status      = $WinUpdSrv.Status
            StartType   = $WinUpdSrv.StartType
        }
    }
  
    $ActionIndex = 0

    $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

    $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'DisplayName', 'Status', 'StartType') 

    if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
    else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}

function Set-FtWindowsUpdateService {
    <#
    .SYNOPSIS
        Enables and starts or stops and disables Windows Update Service on a server.
    .DESCRIPTION
        The Set-WindowsUpdateService function does two things, depending on the switch parameter used:
        1) For -EnableAndStart parameter it starts Windows Update Service on a server and sets its startup type to Automatic,
        2) For -DisableAndStop parameter it stops Windows Update Service on a server and sets its startup type to Disabled.
    .PARAMETER ComputerIP
        Specifies the computer IP.
    .PARAMETER Credential
        Specifies the credentials used to login.
    .PARAMETER DontCheck
        A switch disabling checking the set configuration with a correstponding 'get' function.
    .EXAMPLE
        Set-FtWindowsUpdateService -ComputerIP $all -Credential $cred -DisableAndStop
    #>
    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $false)] [switch]$EnableAndStart,
        [Parameter(Mandatory = $false)] [switch]$DisableAndStop,
        [Parameter(Mandatory = $false)] [switch]$DontCheck
    )

    $ActionIndex = Confirm-FtSwitchParameters $EnableAndStart $DisableAndStop
    #$ScriptBlock = @()

    if ($ActionIndex -eq 0) {
        #If EnableAndStart switch was selected
        $ScriptBlock = { Set-Service -Name wuauserv -StartupType Automatic -Status Running -PassThru }
    }
    elseif ($ActionIndex -eq 1) {
        #If DisableAndStop switch was selected
        $ScriptBlock = { 
            Stop-Service -Name wuauserv
            Set-Service -Name wuauserv -StartupType Disabled -PassThru
        }
    }

    Invoke-FtSetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

    if (!$DontCheck -and ($ActionIndex -ne -1)) {
        Write-Host -ForegroundColor Cyan "Let's check the configuration with Get-FtWindowsUpdateService."
        Get-FtWindowsUpdateService -ComputerIP $ComputerIP -Credential $cred
    }
}
