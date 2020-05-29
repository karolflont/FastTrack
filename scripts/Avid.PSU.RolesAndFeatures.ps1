###################################
### FAILOVER CLUSTERING FEATURE ###
#####################################
function Get-AvFailoverClusteringFeature {
   <#
   .SYNOPSIS
      Checks if Failover Clustering Feature is installed on selected hosts.
   .DESCRIPTION
      The Get-AvFailoverClusteringFeature function uses "Get-WindowsFeature -Name Failover-Clustering" cmdlet to check the presence of Failover Clustering Feature on selected hosts.
   .PARAMETER ComputerIP
      Specifies the computer IP.
   .PARAMETER Credentials
      Specifies the credentials used to login.
   .EXAMPLE
      Get-AvFailoverClusteringFeature -ComputerIP $all -Credential $cred
   #>
   param(
      [Parameter(Mandatory = $true)] $ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )

   $HeaderMessage = "----- Failover Clustering Feature status -----"

   $ScriptBlock = { Get-WindowsFeature -Name Failover-Clustering }

   $NullMessage = "Something went wrong retrieving Failover Clustering Feature status from selected remote hosts"
   
   $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'Name', 'Installed') 

   $ActionIndex = 0
   
   if ($RawOutput) {
        Invoke-AvScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput
    }
    else {
        Invoke-AvScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex
    }
}

function Install-AvFailoverClusteringFeature {
   <#
.SYNOPSIS
   Installs Failover Clustering Feature on selected hosts.
.DESCRIPTION
   The Install-AvFailoverClusteringFeature function uses "Install-WindowsFeature -Name Failover-Clustering -IncludeAllSubFeature -IncludeManagementTools" cmdlet to install Failover Clustering Feature.
.PARAMETER ComputerIP
   Specifies the computer IP.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   Install-AvFailoverClusteringFeature -ComputerIP $all -Credential $cred
#>
   param(
      [Parameter(Mandatory = $true)] $ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
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
   Write-Host -ForegroundColor Cyan "Checking the status with Get-AvFailoverClusteringFeature."

   Get-AvFailoverClusteringFeature -ComputerIP $ComputerIP -Credential $Credential
}

function Uninstall-AvFailoverClusteringFeature {
   <#
   .SYNOPSIS
      Uninstalls Failover Clustering Feature on selected hosts.
   .DESCRIPTION
      The Uninstall-AvFailoverClusteringFeature function uses "Uninstall-WindowsFeature -Name Failover-Clustering -IncludeManagementTools" cmdlet to install Failover Clustering Feature.
   .PARAMETER ComputerIP
      Specifies the computer IP.
   .PARAMETER Credentials
      Specifies the credentials used to login.
   .EXAMPLE
      Uninstall-AvFailoverClusteringFeature -ComputerIP $all -Credential $cred
   #>
   param(
      [Parameter(Mandatory = $true)] $ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
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
   Write-Host -ForegroundColor Cyan "`Checking the status with Get-AvFailoverClusteringFeature."
   
   Get-AvFailoverClusteringFeature -ComputerIP $ComputerIP -Credential $Credential
}