###########################
### POWERSHELL REMOTING ###
###########################
function Test-FtPowershellRemoting {
   <#
    .SYNOPSIS
       Test if Powershell Remoting to a list of hosts is possible.
    .DESCRIPTION
       The Test-FtPowershellRemoting function uses:
       - Test-WSMan
       - New-PSSession
    .PARAMETER ComputerIP
       Specifies the computer IP.
    .PARAMETER Credentials
       Specifies the credentials used to login.
    .EXAMPLE
       Test-FtPowershellRemoting -ComputerIP $all
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
      if ($m) {
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
      if ($s) {
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
function Get-FtRemoteDesktopStatus {
<#
   .SYNOPSIS
      Checks if Remote Desktop connection to a specific computer is possible.
   .DESCRIPTION
      The Get-FtRemoteDesktopStatus function checks four parameters determining if Remote Desktop to a computer is possible. These are:
      1) "Remote Desktop Services" service status
      2) "fDenyTSConnections" value of "HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server" registry key.
      3) "Remote Desktop" DisplayGroup firewall rule existance
      4) "Network Level Authentication" setting status
   .PARAMETER ComputerIP
      Specifies the computer IP.
   .PARAMETER Credentials
      Specifies the credentials used to login.
   .EXAMPLE
      Get-FtRemoteDesktopStatus -ComputerIP $all -Credential $cred
   #>
   param(
      [Parameter(Mandatory = $true)] $ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )

   $HeaderMessage = "----- Remote Desktop status -----"

   $ScriptBlock = {
      $RDPServiceStatus = (Get-Service -Name TermService).Status

      $RDPStatusNum = (Get-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections").fDenyTSConnections
      if ($RDPStatusNum -eq 0) {
         $RDPStatus = "ENABLED"
      }
      elseif ($RDPStatusNum -eq 1) {
         $RDPStatus = "DISABLED"
      }
      else {
         $RDPStatus = "UNKNOWN"
      }

      $RDPFirewallRuleStatusNum = (Get-NetFirewallRule -Name "RemoteDesktop-UserMode-In-TCP").Enabled
      if ($RDPFirewallRuleStatusNum -eq "True") {
         $RDPFirewallRuleStatus = "ENABLED"
      }
      elseif ($RDPFirewallRuleStatusNum -eq "False") {
         $RDPFirewallRuleStatus = "DISABLED"
      }
      else {
         $RDPFirewallRuleStatus = "UNKNOWN"
      }

      $NLAStatusNum = (Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication").UserAuthentication
      if ($NLAStatusNum -eq 1) {
         $NLAStatus = "ENABLED"
      }
      elseif ($NLAStatusNum -eq 0) {
         $NLAStatus = "DISABLED"
      }
      else {
         $NLAStatus = "UNKNOWN"
      }

      [pscustomobject]@{
         RDPServiceStatus = $RDPServiceStatus
         RDPStatus = $RDPStatus
         RDPFirewallRuleStatus = $RDPFirewallRuleStatus
         NLAStatus = $NLAStatus
      }
   }

   $NullMessage = "Something went wrong retrieving Remote Desktop status from selected remote hosts"
  
   $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'RDPServiceStatus','RDPStatus','RDPFirewallRuleStatus','NLAStatus') 

   $ActionIndex = 0
  
   if ($RawOutput) {
       Invoke-FtScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput
   }
   else {
       Invoke-FtScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex
   }
}   
function Set-FtRemoteDesktop {
   <#
    .SYNOPSIS
    TODO
    .DESCRIPTION
    TODO
    .PARAMETER ComputerIP
    Specifies the computer IP.
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
 
   $ActionIndex = Test-FtIfExactlyOneSwitchParameterIsTrue $EnableWithDisabledNLA $EnableWithEnabledNLA $Disable $DisableRDPService
 
   if ($ActionIndex -eq 0) {
      #If EnableWithDisabledNLA switch was selected
      Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Set-Service -Name TermServiceset-service -Name TermService -Status Running -StartupType Manual }
      Write-Host -ForegroundColor Green "`nRemote Desktop Services (TermService) service ENABLED for all hosts."
      Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Set-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0 }
      Write-Host -ForegroundColor Green "`nRDP ENABLED for all hosts."
      Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Enable-NetFirewallRule -DisplayGroup "Remote Desktop" }
      Write-Host -ForegroundColor Green "`nRDP firewall rule ADDED for selected remote hosts."
      Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 0 }
      Write-Host -ForegroundColor Green "`nNetwork Level Authentication for RDP DISABLED for selected remote hosts."
   }
   elseif ($ActionIndex -eq 1) {
      #If EnableWithEnabledNLA switch was selected
      Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Set-Service -Name TermServiceset-service -Name TermService -Status Running -StartupType Manual }
      Write-Host -ForegroundColor Green "`nRemote Desktop Services (TermService) service ENABLED for all hosts."
      Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Set-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0 }
      Write-Host -ForegroundColor Green "`nRDP ENABLED for all hosts."
      Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Disable-NetFirewallRule -DisplayGroup "Remote Desktop" }
      Write-Host -ForegroundColor Green "`nRDP firewall rule ADDED for selected remote hosts."
      Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1 }
      Write-Host -ForegroundColor Green "`nNetwork Level Authentication for RDP ENABLED for selected remote hosts."
   }
   elseif ($ActionIndex -eq 2) {
      #If Disable switch was selected
      Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Set-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 1 }
      Write-Host -ForegroundColor Green "`nRDP DISABLED for all hosts."
      Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Disable-NetFirewallRule -DisplayGroup "Remote Desktop" }
      Write-Host -ForegroundColor Green "`nRDP firewall rule REMOVED for selected remote hosts."
      Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1 }
      Write-Host -ForegroundColor Green "`nNetwork Level Authentication for RDP ENABLED for selected remote hosts (default value)."
   }
   elseif ($ActionIndex -eq 3) {
      #If DisableRDPService switch was selected
      Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Set-Service -Name TermService -Status Stopped -StartupType Disabled }
      Write-Host -ForegroundColor Green "`nRemote Desktop Services (TermService) service STOPPED and DISABLED for all hosts."
   }
}