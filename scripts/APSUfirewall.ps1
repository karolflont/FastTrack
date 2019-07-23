####################
##### FIREWALL #####
####################

function Get-APSUFirewallServiceStatus($ComputerName,[System.Management.Automation.PSCredential] $Credential){
    <#
    .SYNOPSIS
        Gets the status of Firewall service.
    .DESCRIPTION
        The Get-APSUAvidSoftwareVersions function retrieves the
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

function Set-APSUFirewall($ComputerName,[System.Management.Automation.PSCredential] $Credential,[switch]$ON, [switch]$OFF)
{
 <#
    .SYNOPSIS
        Turns the firewall ON or OFF for all profiles: Public, Private and Domain. (Turn ON/OFF!!! - not ENABLE/DISABLE the service)
    .DESCRIPTION
        The Set-APSUFirewall function uses:
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
