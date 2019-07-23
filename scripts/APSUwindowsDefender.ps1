########################
### WINDOWS DEFENDER ###
########################

function Get-APSUWindowsDefenderRealtimeMonitoringStatus($ComputerName,[System.Management.Automation.PSCredential] $Credential) {
    <#
    .SYNOPSIS
       Gets the status of Windows Defender Realtime Monitoring.
    .DESCRIPTION
       The Get-APSUWindowsDefenderRealtimeMonitoringStatus function gets the Status of Windows Defender Realtime Monitoring on a server. 
    .PARAMETER ComputerName
       Specifies the computer name.
    .PARAMETER Credentials
       Specifies the credentials used to login.
    .EXAMPLE
       TODO
    #>
        $WindowsDefenderRealtimeMonitoringStatus = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-MpPreference}
        Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Windows Defender Realtime Monitoring Status "
        $WindowsDefenderRealtimeMonitoringStatus | Select-Object PSComputerName, DisableRealTimeMonitoring | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
    }
    
function Set-APSUWindowsDefenderRealtimeMonitoring($ComputerName,[System.Management.Automation.PSCredential] $Credential, [switch]$Enable, [switch]$Disable){
    <#
    .SYNOPSIS
        Enables or disables Windows Defender Realtime Monitoring.
    .DESCRIPTION
        The Set-APSUWindowsDefender function enables or disables Windows Defender Realtime Monitoring using Set-MpPreference cmdlet. 
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
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-MpPreference -DisableRealtimeMonitoring $false}
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Windows Defender Realtime Monitoring ENABLED. "
    }
    elseif ($Disable) {
        if ($Enable) {
            Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONLY ONE of the -Enable/-Disable switch parameters. "
            Return
        }
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-MpPreference -DisableRealtimeMonitoring $true}
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Windows Defender Realtime Monitoring DISABLED. "
    }
    else {
        Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONE of the -Enable/-Disable switch parameters. "
        Return
    }

    Get-APSUWindowsDefenderRealtimeMonitoringStatus $ComputerName $Credential
}
