###########################
### POWERSHELL REMOTING ###
###########################
function Test-FtPowershellRemoting {
   <#
    .SYNOPSIS
       Test if Powershell Remoting to a list of hosts is possible.
    .DESCRIPTION
       The Test-FtPowershellRemoting function tests:
       - If the conenction over WSMan is possible, using Test-WSMan
       - If the given credentials are valid on the remote host, using New-PSSession
    .PARAMETER ComputerIP
       Specifies the computer IP.
    .PARAMETER Credential
       Specifies the credentials used to login.
    .EXAMPLE
       Test-FtPowershellRemoting -ComputerIP $all -Credential $cred
    #>
   param (
      [Parameter(Mandatory = $true)] $ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential
   )
 
   $PowershellRemotingStatusTable = @()
   $AnythingFailed = $false
   $ComputerIP = [string[]]$ComputerIP

   for ($i = 0; $i -lt $ComputerIP.Count; $i++) {
      Write-Host -ForegroundColor Cyan "Testing host $($ComputerIP[$i]) - $($i+1)/$($ComputerIP.Count)."
      $PowershellRemotingStatus = New-Object -TypeName PSObject
      $PowershellRemotingStatus | Add-Member -MemberType NoteProperty -Name ComputerIP -Value $ComputerIP[$i]
      $PowershellRemotingStatus | Add-Member -MemberType NoteProperty -Name PSRemoting -Value "RESULT UNKNOWN"
      $PowershellRemotingStatus | Add-Member -MemberType NoteProperty -Name Credential -Value "RESULT UNKNOWN"
       
      #testing WSMan
      try {
         Test-WSMan $ComputerIP[$i] -ErrorAction Stop | Out-Null
         $PowershellRemotingStatus.PSRemoting = "OK"
      }
      catch {
         $PowershellRemotingStatus.PSRemoting = "FAILED"
         $AnythingFailed = $true
      }
 
      #testing PSSession
      try {
         $s = New-PSSession -ComputerName $ComputerIP[$i] -Credential $Credential -ErrorAction Stop
         $PowershellRemotingStatus.Credential = "OK"
      }
      catch {
         $PowershellRemotingStatus.Credential = "FAILED"
         $AnythingFailed = $true

      }
      Remove-PSSession $s
      Remove-Variable $s

      $PowershellRemotingStatusTable += $PowershellRemotingStatus
   }

   Write-Output "`n----- Powershell Remoting -----"
   $PowershellRemotingStatusTable | Format-Table -Wrap -AutoSize
 
   if ($AnythingFailed) {
      Write-Host -ForegroundColor Red "Some of the tests FAILED. You can start troubleshooting the issue using:"
      Write-Host -ForegroundColor Red " - Test-WSMan -ComputerName <IP>"
      Write-Host -ForegroundColor Red " - Enter-PSSession -ComputerName <IP> -Credential <credential object>"
   }
   else {
      Write-Host -ForegroundColor Green "All tests PASSED. Powershell remoting is working on all selected hosts."
   }
}

#IN PROGRESS
###############
##### RDP #####
###############
#IN PROGRESS
function Get-FtRemoteDesktop {
   <#
   .SYNOPSIS
      Checks if Remote Desktop connection to a specific computer is possible.
   .DESCRIPTION
      The Get-FtRemoteDesktop function checks four parameters determining if Remote Desktop to a computer is possible. These are:
      - "Remote Desktop Services" service status (and start type)
      - "fDenyTSConnections" value of "HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server" registry key
      - "Remote Desktop" DisplayGroup firewall rule existance
      - "UserAuthentication" value of 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' registry key ("Network Level Authentication" setting)
   .PARAMETER ComputerIP
      Specifies the computer IP.
   .PARAMETER Credential
      Specifies the credentials used to login.
   .PARAMETER RawOutput
      Specifies if the output should be formatted (human friendly output) or not (Powershell pipeline friendly output)
   .EXAMPLE
      Get-FtRemoteDesktop -ComputerIP $all -Credential $cred
   #>
   param(
      [Parameter(Mandatory = $true)] $ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )

   ### BEGIN

   #########

   $HeaderMessage = "Remote Desktop status"

   $ScriptBlock = {
      $RDPService = Get-Service -Name TermService
      $RDPServiceStatus = $RDPService.Status
      $RDPServiceStartType = $RDPService.StartType

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
         RDPServiceStatus      = $RDPServiceStatus
         RDPServiceStartType   = $RDPServiceStartType
         RDPStatus             = $RDPStatus
         RDPFirewallRuleStatus = $RDPFirewallRuleStatus
         NLAStatus             = $NLAStatus
      }
   }
  
   $ActionIndex = 0
  
   $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

   $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'RDPServiceStatus', 'RDPServiceStartType', 'RDPStatus', 'RDPFirewallRuleStatus', 'NLAStatus') 

   if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
   else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}   
function Set-FtRemoteDesktop {
   <#
    .SYNOPSIS
    Enables or Disables Remote Desktop Access to selected remote computers.
    .DESCRIPTION
    The Set-FtRemoteDesktop function enables or disables Remote Desktop Access to selected remote computers by setting the appropriate values of the following:
      - "Remote Desktop Services" service status (and start type)
      - "fDenyTSConnections" value of "HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server" registry key
      - "Remote Desktop" DisplayGroup firewall rule
      - "UserAuthentication" value of 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' registry key ("Network Level Authentication" setting)
    .PARAMETER ComputerIP
    Specifies the computer IP.
    .PARAMETER Credential
    Specifies the credentials used to login.
    .PARAMETER DontCheck
    A switch disabling checking the set configuration with a correstponding 'get' function.
    .EXAMPLE
    Set-FtRemoteDesktop -ComputerIP $all -Credential $cred -EnableWithEnabledNLA
    #>
   param (
      [Parameter(Mandatory = $true)] $ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] [switch] $EnableWithDisabledNLA,
      [Parameter(Mandatory = $false)] [switch] $EnableWithEnabledNLA,
      [Parameter(Mandatory = $false)] [switch] $Disable,
      [Parameter(Mandatory = $false)] [switch] $DontCheck
   ) 
 
   $ActionIndex = Confirm-FtSwitchParameters $EnableWithDisabledNLA $EnableWithEnabledNLA $Disable
   $ScriptBlock = @()


   if ($ActionIndex -eq 0) {
      #If EnableWithDisabledNLA switch was selected
      $ScriptBlock = {
         Set-Service -Name TermService -Status Running -StartupType Manual
         Set-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
         Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
         Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 0
      }
   }
   elseif ($ActionIndex -eq 1) {
      #If EnableWithEnabledNLA switch was selected
      $ScriptBlock = {
         Set-Service -Name TermService -Status Running -StartupType Manual
         Set-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
         Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
         Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1
      }

   }
   elseif ($ActionIndex -eq 2) {
      #If Disable switch was selected
      $ScriptBlock = {
         Stop-Service -Name TermService -Force
         Set-Service -Name TermService -StartupType Disabled
         Set-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 1
         Disable-NetFirewallRule -DisplayGroup "Remote Desktop"
         Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1
      
      
      }
   }

   Invoke-FtSetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

   if (!$DontCheck -and ($ActionIndex -ne -1)) {
      Write-Host -ForegroundColor Cyan "Let's check the configuration with Get-FtRemoteDesktop."
      Get-FtRemoteDesktop -ComputerIP $ComputerIP -Credential $cred
   }

}