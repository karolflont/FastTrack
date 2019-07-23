##########################
##### WINDOWS UPDATE #####
##########################

function Get-APSUWindowsUpdateServiceStatus($ComputerName,[System.Management.Automation.PSCredential] $Credential) {
<#
.SYNOPSIS
   Gets the information about Windows Update Service on a server.
.DESCRIPTION
   The Get-APSUWindowsUpdateService function gets the Status and StartType properties of Windows Update Service on a server. 

   The function reads the Status and StartType properties of wuauserv service.
.PARAMETER ComputerName
   Specifies the computer name.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   TODO
#>
    $WindowsUpdateStatus = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-Service -Name wuauserv}
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Windows Update Status "
    $WindowsUpdateStatus | Select-Object PSComputerName, Status, StartType | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}

function Set-APSUWindowsUpdateService($ComputerName,[System.Management.Automation.PSCredential] $Credential, [switch]$Enable, [switch]$Disable){
    <#
    .SYNOPSIS
        Enables or disables Windows Update Service on a server.
    .DESCRIPTION
        The Set-APSUWindowsUpdateService function does two things, depending on the switch parameter used:
        1) For -Enable parameter it starts Windows Update Service on a server and sets its startup type to Automatic,
        2) For -Disable parameter it stops Windows Update Service on a server and sets its startup type to Disabled.
    .PARAMETER ComputerName
        Specifies the computer name.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    if ($Enable) {
        if ($Disable) {
            Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONLY ONE of the -Enable/-Disable switch parameters. "
        Return
        }
        $WindowsUpdateStatus = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-Service -Name wuauserv -StartupType Automatic -Status Running -PassThru}
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Windows Update Service ENABLED. "
    }
    elseif ($Disable) {
        if ($Enable) {
            Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONLY ONE of the -Enable/-Disable switch parameters. "
            Return
        }
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Stop-Service -Name wuauserv -Force}
        $WindowsUpdateStatus = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-Service -Name wuauserv -StartupType Disabled -PassThru}
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Windows Update Service DISABLED. "
    }
    else {
        Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONE of the -Enable/-Disable switch parameters. "
        Return
    }

    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Windows Update Status "
    $WindowsUpdateStatus | Select-Object PSComputerName, Status, StartType | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}
