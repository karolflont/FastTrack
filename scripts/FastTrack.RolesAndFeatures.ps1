# Copyright (C) 2018  Karol Flont
# Full license notice can be found in FastTrack.psd1 file.

###################################
### FAILOVER CLUSTERING FEATURE ###
#####################################
function Get-FtFailoverClusteringFeature {
   <#
   .SYNOPSIS
      Checks if Failover Clustering Feature is installed on selected hosts.
   .DESCRIPTION
      The Get-FtFailoverClusteringFeature function uses "Get-WindowsFeature -Name Failover-Clustering" cmdlet to check the presence of Failover Clustering Feature on selected hosts.
   .PARAMETER ComputerIP
      Specifies the computer IP.
   .PARAMETER Credential
      Specifies the credentials used to login.
   .PARAMETER RawOutput
      Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
   .EXAMPLE
      Get-FtFailoverClusteringFeature -ComputerIP $all -Credential $cred
   #>
   param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )

   $HeaderMessage = "Failover Clustering Feature status"

   $ScriptBlock = { Get-WindowsFeature -Name Failover-Clustering }
   
   $ActionIndex = 0
   
   $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

   $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'Name', 'Installed') 

   if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
   else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}

function Set-FtFailoverClusteringFeature {
   <#
.SYNOPSIS
   Installs or uninstalls Failover Clustering Feature on selected hosts.
.DESCRIPTION
   The Set-FtFailoverClusteringFeature function uses:
      - "Install-WindowsFeature -Name Failover-Clustering -IncludeAllSubFeature -IncludeManagementTools" cmdlet to install Failover Clustering Feature on selected remote hosts,
      - "Uninstall-WindowsFeature -Name Failover-Clustering -IncludeManagementTools" cmdlet to uninstall Failover Clustering Feature from selected remote hosts.
.PARAMETER ComputerIP
   Specifies the computer IP.
.PARAMETER Credential
   Specifies the credentials used to login.
.PARAMETER Install
   A switch installing Failover Clustering Feature.
.PARAMETER Uninstall
   A switch uninstalling Failover Clustering Feature.
.PARAMETER DontRestart
.PARAMETER DontCheck
   A switch disabling checking the set configuration with a correstponding 'get' function.
.EXAMPLE
   Set-FtFailoverClusteringFeature -ComputerIP $all -Credential $cred -Install
#>
   param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] [switch]$Install,
      [Parameter(Mandatory = $false)] [switch]$Uninstall,
      [Parameter(Mandatory = $false)] [switch]$DontRestart,
      [Parameter(Mandatory = $false)] [switch]$DontWaitForHostsAfterTriggeringRestart,
      [Parameter(Mandatory = $false)] [switch]$Force,
      [Parameter(Mandatory = $false)] [switch]$DontCheck
   )

   $HeaderMessage = "Failover Clustering Feature status"

   $ActionIndex = Confirm-FtSwitchParameters $Install $Uninstall

   $Restart = $true
   if ($DontRestart) { $Restart = $false }
   else {
      if ($Force) { $Restart = $true }
      else { $Restart = Confirm-FtRestart }
   }

   if ($ActionIndex -eq 0) {
      #If Install switch was selected
      $ScriptBlock = { Install-WindowsFeature -Name Failover-Clustering -IncludeAllSubFeature -IncludeManagementTools }
   }
   elseif ($ActionIndex -eq 1) {
      #If Uninstall switch was selected
      $ScriptBlock = { Uninstall-WindowsFeature -Name Failover-Clustering -IncludeManagementTools }
   }

   Invoke-FtSetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

   if ($DontWaitForHostsAfterTriggeringRestart) { Restart-FtRemoteComputer -ComputerIP $ComputerIP -Credential $Credential -Restart $Restart -DontWaitForHostsAfterTriggeringRestart }
   else { Restart-FtRemoteComputer -ComputerIP $ComputerIP -Credential $Credential -Restart $Restart }

   if (!$DontCheck -and ($ActionIndex -ne -1)) {
      Write-Host -ForegroundColor Cyan "Let's check the configuration with Get-FtFailoverClusteringFeature."
      Get-FtFailoverClusteringFeature -ComputerIP $ComputerIP -Credential $cred
   }
}