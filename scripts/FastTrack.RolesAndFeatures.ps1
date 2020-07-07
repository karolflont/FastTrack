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

function Install-FtFailoverClusteringFeature {
   <#
.SYNOPSIS
   Installs Failover Clustering Feature on selected hosts.
.DESCRIPTION
   The Install-FtFailoverClusteringFeature function uses "Install-WindowsFeature -Name Failover-Clustering -IncludeAllSubFeature -IncludeManagementTools" cmdlet to install Failover Clustering Feature.
.PARAMETER ComputerIP
   Specifies the computer IP.
.PARAMETER Credential
   Specifies the credentials used to login.
.EXAMPLE
   Install-FtFailoverClusteringFeature -ComputerIP $all -Credential $cred
#>
   param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential
   )

   Write-Warning "All the remote hosts will be automatically rebooted after the installation. Press Enter to continue or Ctrl+C to quit."
   [void](Read-Host)

   try {
      Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Install-WindowsFeature -Name Failover-Clustering -IncludeAllSubFeature -IncludeManagementTools } | Out-Null
      Write-Host -ForegroundColor Cyan "Waiting for selected remote hosts to reboot (We'll not wait more than 5 minutes though.)..."
      Restart-Computer -ComputerName $ComputerIP -Credential $Credential -Wait -For PowerShell -Timeout 300 -WsmanAuthentication Default -Force
      Write-Host -ForegroundColor Cyan "All remote hosts rebooted and available for PowerShell Remoting again."
   }
   catch {
      Write-Host -ForegroundColor Red "Something went wrong installing Failover Clustering Feature on remote hosts."
      Return
   }
   Write-Host -ForegroundColor Green "Failover Clustering Feature installed on selected remote hosts."
   Write-Host -ForegroundColor Cyan "Checking the status with Get-FtFailoverClusteringFeature."

   Get-FtFailoverClusteringFeature -ComputerIP $ComputerIP -Credential $Credential
}

function Uninstall-FtFailoverClusteringFeature {
   <#
   .SYNOPSIS
      Uninstalls Failover Clustering Feature on selected hosts.
   .DESCRIPTION
      The Uninstall-FtFailoverClusteringFeature function uses "Uninstall-WindowsFeature -Name Failover-Clustering -IncludeManagementTools" cmdlet to install Failover Clustering Feature.
   .PARAMETER ComputerIP
      Specifies the computer IP.
   .PARAMETER Credential
      Specifies the credentials used to login.
   .EXAMPLE
      Uninstall-FtFailoverClusteringFeature -ComputerIP $all -Credential $cred
   #>
   param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential
   )

   Write-Warning "All the remote hosts will be automatically rebooted after the installation. Press Enter to continue or Ctrl+C to quit."
   [void](Read-Host)
   
   try {
      Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Uninstall-WindowsFeature -Name Failover-Clustering -IncludeManagementTools } | Out-Null
      Write-Host -ForegroundColor Cyan "`nWaiting for selected remote hosts to reboot (We'll not wait more than 5 minutes though.)..."
      Restart-Computer -ComputerName $ComputerIP -Credential $Credential -Wait -For PowerShell -Timeout 300 -WsmanAuthentication Default -Force
      Write-Host -ForegroundColor Cyan "`nAll remote hosts rebooted and available for PowerShell Remoting again."
   
   }
   catch {
      Write-Host -ForegroundColor Red "`nSomething went wrong uninstalling Failover Clustering Feature on remote hosts."
      Return
   }


   Write-Host -ForegroundColor Green "`nFailover Clustering Feature installed on selected remote hosts."
   Write-Host -ForegroundColor Cyan "`Checking the status with Get-FtFailoverClusteringFeature."
   
   Get-FtFailoverClusteringFeature -ComputerIP $ComputerIP -Credential $Credential
}