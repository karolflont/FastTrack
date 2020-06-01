####################
##### HOSTNAME #####
####################
function Get-CbHostname {
   <#
    .SYNOPSIS
    Outputs a table comparing current hostnames and hostnames defined in $sysConfig variable for a list of computers.
    .DESCRIPTION
    The Get-CbHostname function uses:
    - $env:computername variable on remote hosts
    - "IP" and "hostname" fields from $sysConfig global variable
    .PARAMETER ComputerIP
    Specifies the computer IP.
    .PARAMETER Credentials
    Specifies the credentials used to login.
    .PARAMETER RawOutput
    Specifies if the output should be formatted or not.
    .EXAMPLE
    Get-CbHostname -ComputerIP $all -Credential $cred
    #>
 
   <# TODO
       1) Check domain sufix of remote hosts and compare with suffix set in $AvidPSUSystemConfiguration
    #>
 
   Param(
      [Parameter(Mandatory = $true)] $ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
      [Parameter(Mandatory = $false)] [switch] $RawOutput
   )
 
   $Hostnames = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
      [pscustomobject]@{HostnameSetOnHost = $env:computername }
   }
 
   $sc = $global:SysConfig | ConvertFrom-Json
 
   $HostnamesRaw = $Hostnames | Select-Object -Property @{Name = "ComputerIP" ; Expression = { $_.PSComputerName } },
   HostnameSetOnHost,
   @{Name = "HostnameInConfig" ; Expression = {
         $CurrentIP = $_.PSComputerName
         ($sc.hosts | Where-object { $_.IP -eq $CurrentIP }).hostname
      }
   }
 
   $HostnamesRaw = $HostnamesRaw | Select-Object -Property ComputerIP, HostnameSetOnHost, HostnameInConfig,
   @{Name = "HostnamesInSync" ; Expression = {
         if ($_.HostnameSetOnHost -eq $_.HostnameInConfig) { "YES" }
         else { "NO" }
      }
   }
 
   if ($RawOutput) {
      $HostnamesRaw
   }
   else {
      $HostnamesRaw | Sort-Object -Property ComputerIP | Format-Table -Wrap -AutoSize
   }
}
function Set-CbHostname {
   <#
    .SYNOPSIS
       Changes the hostnames of remote computers with values defined in $sysConfig variable.
    .DESCRIPTION
       The Set-CbHostname function uses:
       - Get-CbHostname
       - Rename-Computer
       - Restart-Computer
    .PARAMETER ComputerIP
       Specifies the computer IP.
    .PARAMETER Credentials
       Specifies the credentials used to login.
    .PARAMETER NewComputerIP
       Specifies the new computer name to be used.
    .PARAMETER Force
       If Force switch is used, no questions are asked during the execution of this function.
    .EXAMPLE
       Set-CbHostname -ComputerIP $all -Credential $Cred
    #>
   Param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
      [Parameter(Mandatory = $false)] [Switch] $RebootAfterHostnameChange,
      [Parameter(Mandatory = $false)] [Switch] $Force
   )
 
   if (-not $Force) {
      $hostnames = Get-CbHostname -ComputerIP $ComputerIP -Credential $Credential -RawOutput
      Write-Warning "You're about to change the hostname(-s) of remote computer(-s) according to the below table. This can possibly be a harmful operation. Press Enter to continue or Ctrl+C to quit."
      $Hostnames | Select-Object -Property ComputerIP,
      @{Name = "OldName"; Expression = { $_.HostnameSetOnHost } },
      @{Name = "NewName"; Expression = { $_.HostnameInConfig } } `
      | Sort-Object -Property ComputerIP | Format-Table -Wrap -AutoSize
      [void](Read-Host)
      if ($RebootAfterHostnameChange) {
         Write-Warning "All remote hosts will be automatically rebooted after changing the hostnames. Press Enter to continue or Ctrl+C to quit."
         [void](Read-Host)
      }
   }

   $sc = $global:SysConfig | ConvertFrom-Json
 
   for ($i = 0; $i -lt $ComputerIP.Length; $i++) {
      $IP = $ComputerIP[$i]
      $NCN = ($sc.hosts | Where-object { $_.IP -eq $IP }).hostname
      Invoke-Command -ComputerName $ComputerIP[$i] -Credential $Credential -ScriptBlock { Rename-Computer -ComputerName $using:IP -NewName $using:NCN }
   }
    
   Write-Host -ForegroundColor Cyan "`nall hostnames changed."

   if ($RebootAfterHostnameChange) {
      Write-Host -ForegroundColor Cyan "`nWaiting for selected remote hosts to reboot (We'll not wait more than 5 minutes though.)..."
      Restart-Computer -ComputerName $ComputerIP -Credential $Credential -Wait -For PowerShell -Timeout 300 -WsmanAuthentication Default -Force
      Write-Host -ForegroundColor Cyan "`nselected remote hosts rebooted and available for PowerShell Remoting again."
   }
   else {
      Write-Host -ForegroundColor Cyan "`nRemote hosts were NOT REBOOTED after the hostname change."
      Write-Warning "Please reboot manually later as this is required for the hostname change to take effect."
   }
}

##############
### DOMAIN ###
##############
function Get-CbDomain {
   <#
   .SYNOPSIS
      Checks the Active Directory Domain or Workgroup name for a Computer.
   .DESCRIPTION
      The Get-Domain retrieves the Domain information from Win32_ComputerSystem WMI Class.
   .PARAMETER ComputerIP
      Specifies the computer IP.
   .PARAMETER Credentials
      Specifies the credentials used to login.
   .EXAMPLE
      Get-CbDomain -ComputerIP $all -Credential $Cred
   #>
   Param(
      [Parameter(Mandatory = $true)] $ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )

   $HeaderMessage = "----- Domain Membership Status -----"

   $ScriptBlock = { Get-WmiObject -Class Win32_ComputerSystem }

   #A message displayed in case empty objects are returned from all remote computers
   $NullMessage = "Class Win32_ComputerSystem is not present on any of the remote computers."

   $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'PartOfDomain', 'Domain')

   $ActionIndex = 0

   if ($RawOutput) {
        Invoke-CbScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput
    }
    else {
        Invoke-CbScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex
    }
}
function Join-CbDomain {
   <#
 .SYNOPSIS
    Joins computers to an Active Directory Domain.
 .DESCRIPTION
    The Join-Domain joins computers to an Active Directory Domain.
 .PARAMETER ComputerIP
    Specifies the computer name or IP.
 .PARAMETER Credentials
    Specifies the credentials used to login.
 .PARAMETER DomainName
    Specifies the domain name.
 .PARAMETER DomainAdminCredential
    Specifies the Doamin Administrator credentials used to join to the domain.
 .PARAMETER NewComputerName
    Specifies the new computer name to be used.
 .EXAMPLE
    Join-Domain -ComputerIP $all_hosts -Credential $Cred -DomainName 'example.domain.com' -DomainAdminCredentials $AaminCred
 #>
   Param(
      [Parameter(Mandatory = $true)] $ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
      [Parameter(Mandatory = $true)] $DomainName,
      [Parameter(Mandatory = $true)] $DomainAdminUsername
   )
 
   $DomainAdminUserNameFull = $DomainName + "\" + $DomainAdminUsername
 
   #Joining the domain is interactive (will ask for domain admin password) as I did not figure out yet how to pass full credentials
   Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Add-Computer -DomainName $using:DomainName -Credential $using:DomainAdminUsernameFull  -Restart }
   Write-Host -ForegroundColor Cyan "`n ALL COMPUTERS JOINED TO THE $DomainName DOMAIN."
   Write-Host -ForegroundColor Cyan "Reboot triggered for selected remote hosts."
}