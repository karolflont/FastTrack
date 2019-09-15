####################
##### FIREWALL #####
####################

function Get-FirewallServiceStatus($ComputerName,[System.Management.Automation.PSCredential] $Credential){
    <#
    .SYNOPSIS
        Gets the status of Firewall service.
    .DESCRIPTION
        The Get-AvidSoftwareVersions function retrieves the
    .PARAMETER ComputerName
        Specifies the computer name.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    $ComputerName = $YLEHKI_servers
    $Credential = $Cred
    $AvidSoftwareVersions = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-Service -Name "MpsSvc"}
    $AvidSoftwareVersions | Select-Object PSComputerName, DisplayName, Status, StartType | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize

}

function Set-Firewall($ComputerName,[System.Management.Automation.PSCredential] $Credential,[switch]$ON, [switch]$OFF)
{
 <#
    .SYNOPSIS
        Turns the firewall ON or OFF for all profiles: Public, Private and Domain. (Turn ON/OFF!!! - not ENABLE/DISABLE the service)
    .DESCRIPTION
        The Set-Firewall function uses:
        1) "NetSh Advfirewall set allprofiles state on" to turn the firewall on
        2) "NetSh Advfirewall set allprofiles state off" to turn the firewall off
    .PARAMETER ComputerName
        Specifies the computer name.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    if ($ON) {
        if ($OFF) {
            Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONLY ONE of the -ON/-OFF switch parameters. "
        Return
        }
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
            $result = NetSh Advfirewall set allprofiles state on
            }
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Firewall turned ON. "
    }
    elseif ($OFF) {
        if ($ON) {
            Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONLY ONE of the -ON/-OFF switch parameters. "
            Return
        }
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
            $result = NetSh Advfirewall set allprofiles state off
            }
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Firewall turned OFF. "
    }
    else {
        Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONE of the -ON/-OFF switch parameters. "
        Return
    }
    $result    
}


########################
### WINDOWS DEFENDER ###
########################

function Get-WindowsDefenderRealtimeMonitoringStatus($ComputerName,[System.Management.Automation.PSCredential] $Credential) {
    <#
    .SYNOPSIS
       Gets the status of Windows Defender Realtime Monitoring.
    .DESCRIPTION
       The Get-WindowsDefenderRealtimeMonitoringStatus function gets the Status of Windows Defender Realtime Monitoring on a server. 
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
    
function Set-WindowsDefenderRealtimeMonitoring($ComputerName,[System.Management.Automation.PSCredential] $Credential, [switch]$Enable, [switch]$Disable){
    <#
    .SYNOPSIS
        Enables or disables Windows Defender Realtime Monitoring.
    .DESCRIPTION
        The Set-WindowsDefender function enables or disables Windows Defender Realtime Monitoring using Set-MpPreference cmdlet. 
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

    Get-WindowsDefenderRealtimeMonitoringStatus $ComputerName $Credential
}
