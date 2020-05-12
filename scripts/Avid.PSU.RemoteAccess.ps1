###########################
### POWERSHELL REMOTING ###
###########################
function Test-AvPowershellRemoting {
    <#
    .SYNOPSIS
       Test if Powershell Remoting to a list of hosts is possible.
    .DESCRIPTION
       The Test-AvPowershellRemoting function uses:
       - Test-WSMan
       - New-PSSession
    .PARAMETER ComputerIP
       Specifies the computer name.
    .PARAMETER Credentials
       Specifies the credentials used to login.
    .EXAMPLE
       Test-AvPowershellRemoting -ComputerIP $all
    #>
    param (
       [Parameter(Mandatory = $true)] $ComputerIP,
       [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )
 
    $PowershellRemotingStatusTable = @()
    $AnythingFailed = $false

    Write-Host ""
    for ($i = 0; $i -lt $ComputerIP.Count; $i++) {
       Write-Host -ForegroundColor Cyan "Testing host $($ComputerIP[$i]) - $($i+1)/$($ComputerIP.Count)."
       $PowershellRemotingStatus = New-Object -TypeName PSObject
       $PowershellRemotingStatus | Add-Member -MemberType NoteProperty -Name ComputerIP -Value $ComputerIP[$i]
       $PowershellRemotingStatus | Add-Member -MemberType NoteProperty -Name PSRemotingTest -Value "RESULT UNKNOWN"
       $PowershellRemotingStatus | Add-Member -MemberType NoteProperty -Name CredentialTest -Value "RESULT UNKNOWN"
       
       #testing WSMan
       try {
          $m = Test-WSMan $ComputerIP[$i]
       }
       catch {
          $PowershellRemotingStatus.PSRemotingTest = "FAILED"
          $AnythingFailed = $true
       }
       if ($m){
          $PowershellRemotingStatus.PSRemotingTest = "PASSED"
       }
       #testing PSSession
       try {
          $s = New-PSSession -ComputerName $ComputerIP[$i] -Credential $Credential -ErrorAction Stop
       }
       catch {
          $PowershellRemotingStatus.CredentialTest = "FAILED"
          $AnythingFailed = $true
       }
       if ($s){
          $PowershellRemotingStatus.CredentialTest = "PASSED"
          Remove-PSSession $s
       }
       $PowershellRemotingStatusTable += $PowershellRemotingStatus
    }
 
    Write-Host -ForegroundColor Cyan "`n`nPowershell Remoting Tests Summary"
    $PowershellRemotingStatusTable | Format-Table -Wrap -AutoSize
 
    if ($AnythingFailed) {
       Write-Host -ForegroundColor Red "Some of the tests FAILED."
       Write-Host -ForegroundColor Red "You can start troubleshooting the issue using:"
       Write-Host -ForegroundColor Red "1) Test-WSMan -ComputerName <IP>"
       Write-Host -ForegroundColor Red "2) Enter-PSSession -ComputerName <IP> -Credential <credential object>"
       Write-Host -ForegroundColor Red "`n"
    }
    else {
       Write-Host -ForegroundColor Green "All tests PASSED. Powershell remoting is working on all tested hosts."
    }
 }

 #IN PROGRESS
###############
##### RDP #####
###############
#IN PROGRESS
function Get-AvRemoteDesktopStatus{
    <#
    .SYNOPSIS
       Checks if Remote Desktop connection to a specific computer is possible.
    .DESCRIPTION
       The Get-AvRemoteDesktopStatus function checks four parameters determining if Remote Desktop to a computer is possible. These are:
       1) "Remote Desktop Services" service status
       2) "fDenyTSConnections" value of "HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server" registry key.
       3) "Remote Desktop" DisplayGroup firewall rule existance
       4) "Network Level Authentication" status
    .PARAMETER ComputerIP
       Specifies the computer name.
    .PARAMETER Credentials
       Specifies the credentials used to login.
    .EXAMPLE
       TODO
    #>
    param(
         [Parameter(Mandatory = $true)] $ComputerIP,
         [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
     )
 
     $StatusTable = Invoke-Command -ComputerName $srv_IP -Credential $Cred -ScriptBlock {
       $RDPServicesStatus = (Get-Service -Name TermService).Status
       $RDPStatus = (Get-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections").fDenyTSConnections
       $RDPFirewallRuleStatus = (Get-NetFirewallRule -Name "RemoteDesktop-UserMode-In-TCP").Enabled
       $NLAStatus = (Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication").UserAuthentication
    
       $HostStatus = New-Object -TypeName psobject
       $HostStatus | Add-Member -MemberType NoteProperty -Name "RDPServices" -Value $RDPServicesStatus
       $HostStatus | Add-Member -MemberType NoteProperty -Name "RemoteDesktop" -Value $RDPStatus
       $HostStatus | Add-Member -MemberType NoteProperty -Name "RDPFirewallRule" -Value $RDPFirewallRuleStatus
       $HostStatus | Add-Member -MemberType NoteProperty -Name "NetworkLevelAuthentication" -Value $NLAStatus
       $HostStatus
    }
    
    for ($i = 0; $i -lt $StatusTable.Length; $i++) {
       if ($StatusTable[$i].RemoteDesktop -eq 0) {$StatusTable[$i].RemoteDesktop = "Enabled"}
       elseif ($StatusTable[$i].RemoteDesktop -eq 1) {$StatusTable[$i].RemoteDesktop = "Disabled"}
 
       if ($StatusTable[$i].RDPFirewallRule -eq $false) {$StatusTable[$i].RDPFirewallRule = "Disabled"}
       elseif ($StatusTable[$i].RDPFirewallRule -eq $true) {$StatusTable[$i].RDPFirewallRule = "Enabled"}
 
       if ($StatusTable[$i].NetworkLevelAuthentication -eq 0) {$StatusTable[$i].NetworkLevelAuthentication = "Disabled"}
       elseif ($StatusTable[$i].NetworkLevelAuthentication -eq 1) {$StatusTable[$i].NetworkLevelAuthentication = "Enabled"}      
    }
 
    Write-Host -ForegroundColor Cyan "`nRemote Desktop access status summary "
    $StatusTable | Select-Object PSComputerName, RDPServices, RemoteDesktop, RDPFirewallRule, NetworkLevelAuthentication | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
    }   
 function Set-AvRemoteDesktop{
    <#
    .SYNOPSIS
    TODO
    .DESCRIPTION
    TODO
    .PARAMETER ComputerIP
    Specifies the computer name.
    .PARAMETER Credentials
    Specifies the credentials used to login.
    .EXAMPLE
    TODO
    #>
    param (
       [Parameter(Mandatory = $true)] $ComputerIP,
       [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
       [Parameter(Mandatory = $false)] [switch] $EnableWithDisabledNLA,
       [Parameter(Mandatory = $false)] [switch] $EnableWithEnabledNLA,
       [Parameter(Mandatory = $false)] [switch] $Disable,
       [Parameter(Mandatory = $false)] [switch] $DisableRDPService
    ) 
 
    $ActionIndex = Test-AvIfExactlyOneSwitchParameterIsTrue $EnableWithDisabledNLA $EnableWithEnabledNLA $Disable $DisableRDPService
 
    if ($ActionIndex -eq 0){
       #If EnableWithDisabledNLA switch was selected
       Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Set-Service -Name TermServiceset-service -Name TermService -Status Running -StartupType Manual}
       Write-Host -ForegroundColor Green "`nRemote Desktop Services (TermService) service ENABLED for all hosts. "
       Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Set-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0}
       Write-Host -ForegroundColor Green "`nRDP ENABLED for all hosts. "
       Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Enable-NetFirewallRule -DisplayGroup "Remote Desktop"}
       Write-Host -ForegroundColor Green "`nRDP firewall rule ADDED for all remote hosts. "
       Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 0}
       Write-Host -ForegroundColor Green "`nNetwork Level Authentication for RDP DISABLED for all remote hosts. "
    }
    elseif ($ActionIndex -eq 1){
       #If EnableWithEnabledNLA switch was selected
       Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Set-Service -Name TermServiceset-service -Name TermService -Status Running -StartupType Manual}
       Write-Host -ForegroundColor Green "`nRemote Desktop Services (TermService) service ENABLED for all hosts. "
       Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Set-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0}
       Write-Host -ForegroundColor Green "`nRDP ENABLED for all hosts. "
       Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Disable-NetFirewallRule -DisplayGroup "Remote Desktop"}
       Write-Host -ForegroundColor Green "`nRDP firewall rule ADDED for all remote hosts. "
       Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1}
       Write-Host -ForegroundColor Green "`nNetwork Level Authentication for RDP ENABLED for all remote hosts. "
    }
    elseif ($ActionIndex -eq 2){
       #If Disable switch was selected
       Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Set-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 1}
       Write-Host -ForegroundColor Green "`nRDP DISABLED for all hosts. "
       Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Disable-NetFirewallRule -DisplayGroup "Remote Desktop"}
       Write-Host -ForegroundColor Green "`nRDP firewall rule REMOVED for all remote hosts. "
       Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1}
       Write-Host -ForegroundColor Green "`nNetwork Level Authentication for RDP ENABLED for all remote hosts (default value). "
    }
    elseif ($ActionIndex -eq 3){
       #If DisableRDPService switch was selected
       Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Set-Service -Name TermService -Status Stopped -StartupType Disabled}
       Write-Host -ForegroundColor Green "`nRemote Desktop Services (TermService) service STOPPED and DISABLED for all hosts. "
    }
 }