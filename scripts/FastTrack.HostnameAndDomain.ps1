####################
##### HOSTNAME #####
####################
function Get-FtHostname {
   <#
   .SYNOPSIS
      Compares current hostnames set on selected remote computers with their hostnames defined in $sysConfig variable.
   .DESCRIPTION
      The Get-FtHostname function outputs a table comparing $env:computername variable set on remote hosts with corresponding "hostname" field from $sysConfig global variable.
      The comparison is done using IP address as the key.
   .PARAMETER ComputerIP
      Specifies the computer IP.
   .PARAMETER Credential
      Specifies the credentials used to login.
   .PARAMETER SortByLineNumber
      Allows sorting by the line number of the CMD Expression Output
   .PARAMETER RawOutput
      Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
   .EXAMPLE
      Get-FtHostname -ComputerIP $all -Credential $cred
   #>
 
   Param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] [switch]$SortByIPAddress,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )

   $HeaderMessage = "Hostnames Summary"

   $ScriptBlock = {
      $ComputerIP = $using:ComputerIP
      $IP = (Get-NetIPConfiguration -Detailed | Where-Object { ($_.IPv4Address.IPAddress -In $ComputerIP) }).IPv4Address.IPAddress
      [pscustomobject]@{
         HostnameSetOnHost = $env:computername
         IPAddress         = $IP
      }
   }
 
   $ActionIndex = Confirm-FtSwitchParameters $SortByIPAddress -DefaultSwitch 1

   $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

   ### END BLOCK
   $Result = $Result | Select-Object -Property IPAddress, Alias, HostnameInConfig, HostnameSetOnHost, @{Name = "HostnamesInSync" ; Expression = { if ($_.HostnameSetOnHost -eq $_.HostnameInConfig) { "Yes" } else { "No" } } }
   #############

   $PropertiesToDisplay = ('IPAddress', 'Alias', 'HostnameInConfig', 'HostnameSetOnHost', 'HostnamesInSync') 

   if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
   else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}
function Set-FtHostname {
   <#
   .SYNOPSIS
      Changes the hostnames of remote computers with values defined in $sysConfig variable.
   .DESCRIPTION
      The Set-FtHostname function uses Rename-Computer cmdlet to change the hostnames of the selected remote computers.
      Various switch parameters can be used for more or less verbose operation. See parameters descriptions for details.
   .PARAMETER ComputerIP
      Specifies the computer IP.
   .PARAMETER Credential
      Specifies the credentials used to login.
   .PARAMETER DontWaitForHostsAfterReboot
      Specifies if the command should wait for the remote hosts to come back online after triggering the reboot.
   .PARAMETER DontCheck
      A switch disabling checking the set configuration with a correstponding 'get' function.
   .PARAMETER Force
      No questions are asked during the execution.
   .EXAMPLE
      Set-FtHostname -ComputerIP $all -Credential $Cred
    #>
   Param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] [switch]$DontWaitForHostsAfterReboot,
      [Parameter(Mandatory = $false)] [switch]$DontCheck,
      [Parameter(Mandatory = $false)] [switch]$Force
   )

   $Reboot = $true
   if ($Force) { $Reboot = $true }
   else { $Reboot = Confirm-FtRestart }

   $sc = $global:SysConfig | ConvertFrom-Json

   Write-Host -ForegroundColor Cyan "Changing remote hosts configuration... " -NoNewline
   $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
   foreach ($item in $ComputerIP) {
      $NCN = ($sc.hosts | Where-object { $_.IP -eq $item }).hostname
      Invoke-Command -ComputerName $item -Credential $Credential -ScriptBlock { Rename-Computer -ComputerName $using:item -NewName $using:NCN -WarningAction SilentlyContinue }
   }
   $StopWatch.Stop()
   $ElapsedSeconds = $StopWatch.Elapsed.TotalSeconds 
   Write-Host -ForegroundColor Green "DONE " -NoNewline
   Write-Host -ForegroundColor Cyan "in $ElapsedSeconds sec."

   if ($DontWaitForHostsAfterReboot) { Restart-FtRemoteComputer -ComputerIP $ComputerIP -Credential $Credential -Reboot $Reboot -DontWaitForHostsAfterReboot }
   else { Restart-FtRemoteComputer -ComputerIP $ComputerIP -Credential $Credential -Reboot $Reboot }

   if (!$DontCheck -and $Reboot) {
      Write-Host -ForegroundColor Cyan "Let's check the configuration with Get-FtHostname."
      Get-FtHostname -ComputerIP $ComputerIP -Credential $cred
   }
}

##############
### DOMAIN ###
##############
function Get-FtDomain {
   <#
   .SYNOPSIS
      Checks the Active Directory Domain or Workgroup name for a Computer.
   .DESCRIPTION
      The Get-Domain retrieves the Domain information from Win32_ComputerSystem WMI Class.
   .PARAMETER ComputerIP
      Specifies the computer IP.
   .PARAMETER Credential
      Specifies the credentials used to login.
   .PARAMETER RawOutput
   Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
   .EXAMPLE
      Get-FtDomain -ComputerIP $all -Credential $Cred
   #>
   Param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )

   $HeaderMessage = "Domain Membership Status"

   $ScriptBlock = { Get-WmiObject -Class Win32_ComputerSystem }

   $ActionIndex = 0

   $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

   $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'PartOfDomain', 'Domain')

   if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
   else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}
function Set-FtDomain {
   <#
   .SYNOPSIS
      Joins computers to (or leaves) an Active Directory Domain.
   .DESCRIPTION
      The Set-FtDomain joins selected remote computers to (or leaves) an Active Directory Domain.
   .PARAMETER ComputerIP
      Specifies the computer name or IP.
   .PARAMETER Credential
      Specifies the credentials used to login.
   .PARAMETER DomainName
      Specifies the domain name (shortname or FQDN) to join or leave.
   .PARAMETER DomainAdminUsername
      Specifies the Domain Administrator credentials used to join (leave) the domain. DO NOT include the domain prefix!
   .PARAMETER Join
      Specifies that the selected computers should join the domain specified in $DomainName parameter.
   .PARAMETER Leave
      Specifies that the selected computers should leave the domain specified in $DomainName parameter.
   .PARAMETER DontWaitForHostsAfterReboot
      Specifies if the command should wait for the remote hosts to come back online after triggering the reboot.
   .PARAMETER DontCheck
      A switch disabling checking the set configuration with a correstponding 'get' function.
   .PARAMETER Force
      No questions are asked during the execution.
   .EXAMPLE
      Set-FtDomain -ComputerIP $all -Credential $cred -DomainName lop.pri -DomainAdminUsername administrator -Join
   .EXAMPLE
      Set-FtDomain -ComputerIP $all -Credential $cred -DomainName lop.pri -DomainAdminUsername administrator -Leave
   #>
   Param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $true)] $DomainName,
      [Parameter(Mandatory = $true)] $DomainAdminUsername,
      [Parameter(Mandatory = $false)] [switch]$Join,
      [Parameter(Mandatory = $false)] [switch]$Leave,
      [Parameter(Mandatory = $false)] [switch]$DontWaitForHostsAfterReboot,
      [Parameter(Mandatory = $false)] [switch]$DontCheck,
      [Parameter(Mandatory = $false)] [switch]$Force
   )

   $DomainAdminUserNameFull = $DomainName + "\" + $DomainAdminUsername

   $ActionIndex = Confirm-FtSwitchParameters $Join $Leave

   if ($ActionIndex -eq 0) {
      $Reboot = $true
      if ($Force) { $Reboot = $true }
      else { $Reboot = Confirm-FtRestart }

      $ScriptBlock = [ScriptBlock]::create("Add-Computer -DomainName $DomainName -Credential $DomainAdminUsernameFull -Force -WarningAction SilentlyContinue")

      #Run Script Block on remote computers
      Write-Host -ForegroundColor Cyan "Changing remote hosts configuration... "
      $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
      Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock $ScriptBlock | Out-Null
      $StopWatch.Stop()
      $ElapsedSeconds = $StopWatch.Elapsed.TotalSeconds 
      Write-Host -ForegroundColor Green "DONE " -NoNewline
      Write-Host -ForegroundColor Cyan "in $ElapsedSeconds sec."

      if ($DontWaitForHostsAfterReboot) { Restart-FtRemoteComputer -ComputerIP $ComputerIP -Credential $Credential -Reboot $Reboot -DontWaitForHostsAfterReboot }
      else { Restart-FtRemoteComputer -ComputerIP $ComputerIP -Credential $Credential -Reboot $Reboot }

      if (!$DontCheck -and $Reboot) {
         Write-Host -ForegroundColor Cyan "Let's check the configuration with Get-FtDomain."
         Get-FtDomain -ComputerIP $ComputerIP -Credential $cred
      }
   }
   elseif ($ActionIndex -eq 1) {
      Write-Warning "An INSTANT AUTOMATIC reboot of the remote hosts is needed after this operation."
      $Continue = Read-Host "Do you want to proceed with leaving the domain for selected remote hosts? Only yes will be accepted as confirmation."
      if ($Continue -eq 'yes') {
         $ScriptBlock = [ScriptBlock]::create("Remove-Computer -UnjoinDomaincredential $DomainAdminUsernameFull -Restart -Force")
         #Run Script Block on remote computers
         Write-Host -ForegroundColor Cyan "Changing remote hosts configuration... "
         $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
         Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock $ScriptBlock | Out-Null
         $StopWatch.Stop()
         $ElapsedSeconds = $StopWatch.Elapsed.TotalSeconds 
         Write-Host -ForegroundColor Green "DONE " -NoNewline
         Write-Host -ForegroundColor Cyan "in $ElapsedSeconds sec."
      }
      else { Return }
   }
}