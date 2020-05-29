########################
### WINDOWS FIREWALL ###
########################
function Get-AvFirewallStatus {
    <#
    .SYNOPSIS
        Gets the status of Firewall service.
    .DESCRIPTION
        The Get-AvFirewallServiceStatus uses:
        - Get-Service -Name MpsSvc
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

    $AvidSoftwareVersions = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Get-Service -Name "MpsSvc" }
    $AvidSoftwareVersions | Select-Object PSComputerName, DisplayName, Status, StartType | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize

}

function Set-AvFirewall {

    <#
.SYNOPSIS
    Sets Windows Firewall service (MpsSvc) status i startup type .
.DESCRIPTION
    The Get-AvSoftwareVersions function retrieves the
.PARAMETER ComputerIP
    Specifies the computer IP.
.PARAMETER Credentials
    Specifies the credentials used to login.
.EXAMPLE
    TODO
#>
    <#
Write-Host -ForegroundColor Red "`nThis function is not yet implemented."
Return
    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )
    $ComputerIP = $YLEHKI_servers
    $Credential = $Cred
    $AvidSoftwareVersions = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Get-Service -Name "MpsSvc"}
    $AvidSoftwareVersions | Select-Object PSComputerName, DisplayName, Status, StartType | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize

}
#>
    <#
    .SYNOPSIS
        Turns the firewall ON or OFF for all profiles: Public, Private and Domain. (Turn ON/OFF!!! - not ENABLE/DISABLE the service)
    .DESCRIPTION
        The Set-Firewall function uses:
        1) "NetSh Advfirewall set allprofiles state on" to turn the firewall on
        2) "NetSh Advfirewall set allprofiles state off" to turn the firewall off
    .PARAMETER ComputerIP
        Specifies the computer IP.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        Set-Firewall -ComputerIP $srv_IP -Credential $cred -On
    #>

    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch]$On,
        [Parameter(Mandatory = $false)] [switch]$Off
    )

    $ActionIndex = Test-AvIfExactlyOneSwitchParameterIsTrue $On $Off
    
    if ($ActionIndex -eq 0) {
        #If On switch was selected
        $result = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
            NetSh Advfirewall set allprofiles state on
        }
        Write-Host -ForegroundColor Green "`nFirewall on all hosts turned ON for all profiles: Domain networks, Private networks and Guest or Public networks."
        $result
    }
    elseif ($ActionIndex -eq 1) {
        #If Off switch was selected
        $result = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
            NetSh Advfirewall set allprofiles state off
        }
        Write-Host -ForegroundColor Green "`nFirewall on all hosts turned OFF for all profiles: Domain networks, Private networks and Guest or Public networks."
        $result
    }   
}
########################
### WINDOWS DEFENDER ###
########################
function Get-AvDefenderStatus {
    <#
    .SYNOPSIS
       Gets the status of Windows Defender Realtime Monitoring.
    .DESCRIPTION
       The AvDefenderStatus function gets the Status of Windows Defender Realtime Monitoring on a server. 
    .PARAMETER ComputerIP
       Specifies the computer IP.
    .PARAMETER Credentials
       Specifies the credentials used to login.
    .EXAMPLE
       Get-AvHostname -ComputerIP $all -Credential $cred
    #>

    #TODO:
    #Add checking for these two services:
    #Get-Service -Name windefend
    #Get-Service -Name mpssvc
    #https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-antivirus/windows-defender-antivirus-on-windows-server-2016
    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    $WindowsDefenderRealtimeMonitoringStatus = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Get-MpPreference }
    Write-Host -ForegroundColor Cyan "`nWindows Defender Realtime Monitoring Status "
    $WindowsDefenderRealtimeMonitoringStatus | Select-Object PSComputerName, DisableRealTimeMonitoring | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}
function Install-AvDefender {
    <#
.SYNOPSIS
    Installs Windows Defender Feature.
.DESCRIPTION
    The Install-Defender function installs Windows Defender Windows Feature. 
.PARAMETER ComputerIP
    Specifies the computer IP.
.PARAMETER Credentials
    Specifies the credentials used to login.
.EXAMPLE
    TODO
#>
    Write-Host -ForegroundColor Red "`nThis function is not yet implemented."
    Return
    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )

    Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Install-WindowsFeature -Name Windows-Defender }
    Write-Host -ForegroundColor Green "`nWindows Defender INSTALLED on selected remote hosts."
}
function Uninstall-AvDefender {
    <#
    .SYNOPSIS
        Uninstalls Windows Defender Feature.
    .DESCRIPTION
        The Unnstall-Defender function uninstalls Windows Defender Windows Feature. 
    .PARAMETER ComputerIP
        Specifies the computer IP.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    Write-Host -ForegroundColor Red "`nThis function is not yet implemented."
    Return
    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )
    
    Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Uninstall-WindowsFeature -Name Windows-Defender }
    Write-Host -ForegroundColor Green "`nWindows Defender UNINSTALLED on selected remote hosts."
}
function Set-AvDefender {
    <#
.SYNOPSIS
    Enables or disables Windows Defender Realtime Monitoring.
.DESCRIPTION
    The Set-Defender function enables or disables Windows Defender Realtime Monitoring using Set-MpPreference cmdlet. 
.PARAMETER ComputerIP
    Specifies the computer IP.
.PARAMETER Credentials
    Specifies the credentials used to login.
.EXAMPLE
    TODO
#>
    Write-Host -ForegroundColor Red "`nThis function is not yet implemented."
    Return
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
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Set-MpPreference -DisableRealtimeMonitoring $false }
        Write-Host -ForegroundColor Green "`nWindows Defender Realtime Monitoring ENABLED."
    }
    elseif ($Disable) {
        if ($Enable) {
            Write-Host -ForegroundColor Red "`nPlease specify ONLY ONE of the -Enable/-Disable switch parameters."
            Return
        }
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Set-MpPreference -DisableRealtimeMonitoring $true }
        Write-Host -ForegroundColor Green "`nWindows Defender Realtime Monitoring DISABLED."
    }
    else {
        Write-Host -ForegroundColor Red "`nPlease specify ONE of the -Enable/-Disable switch parameters."
        Return
    }

    Get-AvWindowsDefenderRealtimeMonitoringStatus $ComputerIP $Credential
}



