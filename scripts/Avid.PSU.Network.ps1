############################
### NETWORK RELATED INFO ###
############################
function Get-NetworkInfo{
   <#
   .SYNOPSIS
   TODO
   .DESCRIPTION
   TODO
   .PARAMETER ComputerName
   Specifies the computer name.
   .PARAMETER Credentials
   Specifies the credentials used to login.
   .EXAMPLE
   TODO
   #>
   param (
      [Parameter(Mandatory = $true)] $ComputerName,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
      [Parameter(Mandatory = $false)] [switch]$SortByPSComputerName,
      [Parameter(Mandatory = $false)] [switch]$SortByName,
      [Parameter(Mandatory = $false)] [switch]$SortByInterfaceAlias,
      [Parameter(Mandatory = $false)] [switch]$SortByInterfaceIndex,
      [Parameter(Mandatory = $false)] [switch]$SortByIPv4Connectivity,
      [Parameter(Mandatory = $false)] [switch]$SortByNetworkCategory
   )
   
   #Default sort property
   $DefaultSortProperty = "PSComputerName"
   $PropertiesToDisplay = ('PSComputerName','Name','InterfaceAlias','InterfaceIndex','IPv4Connectivity','NetworkCategory') 
   
   $SortPropertyIndex = Test-IfExactlyOneSwitchParameterIsTrue $SortByPSComputerName $SortByName $SortByInterfaceAlias $SortByInterfaceIndex $SortByIPv4Connectivity $SortByNetworkCategory
   
   if ($null -eq $SortPropertyIndex){
      #If none of the switches is selected, use the DafaultSortProperty
      $SortProperty = $DefaultSortProperty
   }
   elseif ($SortPropertyIndex -ge 0){
      #If one switch is selected, use it as SortProperty
      $SortProperty = $PropertiesToDisplay[$SortPropertyIndex]
   }
   else{
      #If more than one switch is selected, return
      Return
   }
   
   $NetworkInfo = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-NetConnectionProfile}
   $NetworkInfo | Select-Object $PropertiesToDisplay | Sort-Object -Property $SortProperty | Format-Table -Wrap -AutoSize

   #Retrieving only IPv4 addresses
   #get-netipaddress | Where-Object -FilterScript {$_.AddressFamily -match “IPv4”} |Where-Object -FilterScript {$_.InterfaceAlias -notlike “Loopback*”}| Select-Object -ExpandProperty IPAddress | out-file C:\bginfo\MyIPv4Address.txt

   #GWMI Win32_NetworkAdapterConfiguration -Filter "IPEnabled = $true" |select @{N='IPv4'; E={($_."IPAddress").split(",")[0]}}
}
function Get-NICPowerManagementStatus{

}
function Set-NICPowerManagement{

}
#IN PROGRESS
###############
##### RDP #####
###############
#IN PROGRESS
function Get-RemoteDesktopStatus{
   <#
   .SYNOPSIS
      Checks if Remote Desktop connection to a specific computer is possible.
   .DESCRIPTION
      The Get-RemoteDesktopStatus function checks four parameters determining if Remote Desktop to a computer is possible. These are:
      1) "Remote Desktop Services" service status
      2) "fDenyTSConnections" value of "HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server" registry key.
      3) "Remote Desktop" DisplayGroup firewall rule existance
      4) "Network Level Authentication" status
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

   Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Remote Desktop access status summary "
   $StatusTable | Select-Object PSComputerName, RDPServices, RemoteDesktop, RDPFirewallRule, NetworkLevelAuthentication | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
   }   
function Set-RemoteDesktop{
   <#
   .SYNOPSIS
   TODO
   .DESCRIPTION
   TODO
   .PARAMETER ComputerName
   Specifies the computer name.
   .PARAMETER Credentials
   Specifies the credentials used to login.
   .EXAMPLE
   TODO
   #>
   param (
      [Parameter(Mandatory = $true)] $ComputerName,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
      [Parameter] [switch] $EnableWithDisabledNLA,
      [Parameter] [switch] $EnableWithEnabledNLA,
      [Parameter] [switch] $Disable,
      [Parameter] [switch] $DisableRDPService
   ) 

   $ActionIndex = Test-IfExactlyOneSwitchParameterIsTrue $EnableWithDisabledNLA $EnableWithEnabledNLA $Disable $DisableRDPService

   if ($ActionIndex -eq 0){
      #If EnableWithDisabledNLA switch was selected
      Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-Service -Name TermServiceset-service -Name TermService -Status Running -StartupType Manual}
      Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Remote Desktop Services (TermService) service ENABLED for all hosts. "
      Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0}
      Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n RDP ENABLED for all hosts. "
      Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Enable-NetFirewallRule -DisplayGroup "Remote Desktop"}
      Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n RDP firewall rule ADDED for all remote hosts. "
      Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 0}
      Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Network Level Authentication for RDP DISABLED for all remote hosts. "
   }
   elseif ($ActionIndex -eq 1){
      #If EnableWithEnabledNLA switch was selected
      Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-Service -Name TermServiceset-service -Name TermService -Status Running -StartupType Manual}
      Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Remote Desktop Services (TermService) service ENABLED for all hosts. "
      Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0}
      Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n RDP ENABLED for all hosts. "
      Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Disable-NetFirewallRule -DisplayGroup "Remote Desktop"}
      Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n RDP firewall rule ADDED for all remote hosts. "
      Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1}
      Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Network Level Authentication for RDP ENABLED for all remote hosts. "
   }
   elseif ($ActionIndex -eq 2){
      #If Disable switch was selected
      Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 1}
      Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n RDP DISABLED for all hosts. "
      Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Disable-NetFirewallRule -DisplayGroup "Remote Desktop"}
      Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n RDP firewall rule REMOVED for all remote hosts. "
      Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1}
      Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Network Level Authentication for RDP ENABLED for all remote hosts (default value). "
   }
   elseif ($ActionIndex -eq 3){
      #If DisableRDPService switch was selected
      Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-Service -Name TermService -Status Stopped -StartupType Disabled}
      Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Remote Desktop Services (TermService) service STOPPED and DISABLED for all hosts. "
   }
}