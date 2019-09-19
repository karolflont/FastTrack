####################
##### FIREWALL #####
####################
function Get-FirewallServiceStatus{
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
    param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )
    $ComputerName = $YLEHKI_servers
    $Credential = $Cred
    $AvidSoftwareVersions = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-Service -Name "MpsSvc"}
    $AvidSoftwareVersions | Select-Object PSComputerName, DisplayName, Status, StartType | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize

}
function Set-Firewall{
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
        Set-Firewall -ComputerName $srv_IP -Credential $cred -On
    #>
    param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch]$On,
        [Parameter(Mandatory = $false)] [switch]$Off
    )

    $ActionIndex = Test-IfExactlyOneSwitchParameterIsTrue $On $Off
    
    if ($ActionIndex -eq 0){
        #If On switch was selected
        $result = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
            NetSh Advfirewall set allprofiles state on
            }
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Firewall on all hosts turned ON for all profiles: Domain networks, Private networks and Guest or Public networks. "
        $result
    }
    elseif ($ActionIndex -eq 1){
        #If Off switch was selected
        $result = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
            NetSh Advfirewall set allprofiles state off
            }
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Firewall on all hosts turned OFF for all profiles: Domain networks, Private networks and Guest or Public networks. "
        $result
    }   
}
########################
### WINDOWS DEFENDER ###
########################
function Get-WindowsDefenderRealtimeMonitoringStatus{
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
    param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )

        $WindowsDefenderRealtimeMonitoringStatus = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-MpPreference}
        Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Windows Defender Realtime Monitoring Status "
        $WindowsDefenderRealtimeMonitoringStatus | Select-Object PSComputerName, DisableRealTimeMonitoring | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
    }
    function Set-WindowsDefenderRealtimeMonitoring{
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
    param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch]$Enable,
        [Parameter(Mandatory = $false)] [switch]$Disable
    )

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
