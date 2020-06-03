##########################
##### WINDOWS UPDATE #####
##########################
function Get-FtWindowsUpdateServiceStatus {
    <#
.SYNOPSIS
   Gets the information about Windows Update Service on a server.
.DESCRIPTION
   The Get-FtWindowsUpdateServiceStatus function gets the Status and StartType properties of Windows Update Service on a server. 
   The function reads the Status and StartType properties of wuauserv service.
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
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    $WindowsUpdateStatus = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Get-Service -Name wuauserv }
    Write-Host -ForegroundColor Cyan "`nWindows Update Status "
    $WindowsUpdateStatus | Select-Object PSComputerName, Status, StartType | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}
function Set-FtWindowsUpdateService {
    <#
    .SYNOPSIS
        Enables or disables Windows Update Service on a server.
    .DESCRIPTION
        The Set-WindowsUpdateService function does two things, depending on the switch parameter used:
        1) For -Enable parameter it starts Windows Update Service on a server and sets its startup type to Automatic,
        2) For -Disable parameter it stops Windows Update Service on a server and sets its startup type to Disabled.
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
        [Parameter(Mandatory = $false)] [switch]$Enable,
        [Parameter(Mandatory = $false)] [switch]$Disable
    )

    if ($Enable) {
        if ($Disable) {
            Write-Host -ForegroundColor Red "`nPlease specify ONLY ONE of the -Enable/-Disable switch parameters."
            Return
        }
        $WindowsUpdateStatus = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Set-Service -Name wuauserv -StartupType Automatic -Status Running -PassThru }
        Write-Host -ForegroundColor Green "`nWindows Update Service ENABLED."
    }
    elseif ($Disable) {
        if ($Enable) {
            Write-Host -ForegroundColor Red "`nPlease specify ONLY ONE of the -Enable/-Disable switch parameters."
            Return
        }
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Stop-Service -Name wuauserv -Force }
        $WindowsUpdateStatus = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Set-Service -Name wuauserv -StartupType Disabled -PassThru }
        Write-Host -ForegroundColor Green "`nWindows Update Service DISABLED."
    }
    else {
        Write-Host -ForegroundColor Red "`nPlease specify ONE of the -Enable/-Disable switch parameters."
        Return
    }

    Write-Host -ForegroundColor Cyan "`nWindows Update Status "
    $WindowsUpdateStatus | Select-Object PSComputerName, Status, StartType | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}
