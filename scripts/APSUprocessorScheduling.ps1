################################
##### PROCESSOR SCHEDULING #####
################################


function Get-APSUProcessorScheduling($ComputerName,[System.Management.Automation.PSCredential] $Credential){
    <#
    .SYNOPSIS
        Gets the Processor Scheduling setting: programs or background services
    .DESCRIPTION
        TODO
    .PARAMETER ComputerName
        Specifies the computer name.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    $ProcesorSchedulingStatus = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
        Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation
    }
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Processor scheduling status: 38 - programs; 0(default) or 24 - background services "
    $ProcesorSchedulingStatus | Select-Object PSComputerName, Win32PrioritySeparation | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}

function Set-APSUProcessorScheduling($ComputerName,[System.Management.Automation.PSCredential] $Credential, [switch]$Programs, [switch]$BackgroundServices){
    <#
    .SYNOPSIS
        Sets processor schedulling to Programs or Background Services.
    .DESCRIPTION
        The Set-APSUProcessorScheduling function sets processor scheduling to Programs or Background Services. 
    .PARAMETER ComputerName
        Specifies the computer name.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    if ($Programs) {
        if ($BackgroundServices) {
            Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONLY ONE of the -Programs/-BackgroundServices switch parameters. "
        Return
        }
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
            Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation -Value 38
        }
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Processor scheduling set to PROGRAMS. "
    }
    elseif ($BackgroundServices) {
        if ($Programs) {
            Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONLY ONE of the -Programs/-BackgroundServices switch parameters. "
            Return
        }
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
            Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation -Value 24
        }
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Processor scheduling set to BACKGROUND SERVICES. "
    }
    else {
        Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONE of the -Programs/-BackgroundServices switch parameters. "
        Return
    }

    Get-APSUProcessorScheduling $ComputerName $Credential
}
