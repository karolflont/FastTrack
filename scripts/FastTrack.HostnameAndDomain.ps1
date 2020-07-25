# Copyright (C) 2018  Karol Flont
# Full license notice can be found in FastTrack.psd1 file.

####################
##### HOSTNAME #####
####################
function Get-FtHostnameAndDomain {
   <#
   .SYNOPSIS
      Compares current hostnames set on selected remote computers with their hostnames defined in $FtConfig variable, and checks the Active Directory Domain or Workgroup name for a Computer.
   .DESCRIPTION
      The Get-FtHostnameAndDomain function outputs a table containing:
      - a comparison of $env:computername variable set on selected remote computers with corresponding "hostname" field from $FtConfig global variable (The comparison is done using IP address as the key.)
      - the domain membership information for selected remote computers (retrieved from Win32_ComputerSystem WMI Class).
   .PARAMETER ComputerIP
      Specifies the computer IP.
   .PARAMETER Credential
      Specifies the credentials used to login.
   .PARAMETER SortByIPAddress
      Allows sorting by the IPAddress of selected remote computers.
   .PARAMETER RawOutput
      Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
   .EXAMPLE
      Get-FtHostnameAndDomain -ComputerIP $all -Credential $cred
   #>
 
   Param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] [switch]$SortByIPAddress,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )

   $HeaderMessage = "Hostname and Domain Membership Summary"

   $ScriptBlock = {
      $ComputerIP = $using:ComputerIP
      $IP = (Get-NetIPConfiguration -Detailed | Where-Object { ($_.IPv4Address.IPAddress -In $ComputerIP) }).IPv4Address.IPAddress
      $CSObject = Get-WmiObject -Class Win32_ComputerSystem

      [pscustomobject]@{
         HostnameSetOnHost = $env:computername
         IPAddress         = $IP
         PartOfDomain      = $CSObject.PartOfDomain
         Domain            = $CSObject.Domain
      }
   }
 
   $ActionIndex = Confirm-FtSwitchParameters $SortByIPAddress -DefaultSwitch 1

   $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

   ### END BLOCK
   $Result = $Result | Select-Object -Property IPAddress, Alias, HostnameInConfig, HostnameSetOnHost, @{Name = "HostnamesInSync" ; Expression = { if ($_.HostnameSetOnHost -eq $_.HostnameInConfig) { "Yes" } else { "No" } } }, PartOfDomain, Domain
   #############

   $PropertiesToDisplay = ('IPAddress', 'Alias', 'HostnameInConfig', 'HostnameSetOnHost', 'HostnamesInSync', 'PartOfDomain', 'Domain')

   if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
   else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}
function Set-FtHostname {
   <#
   .SYNOPSIS
      Changes the hostnames of remote computers with values defined in $FtConfig variable.
   .DESCRIPTION
      The Set-FtHostname function uses Rename-Computer cmdlet to change the hostnames of the selected remote computers.
      Please note that:
       - to change a hostname of a computer in a workgroup, you need to specify a local account with administrative privileges (use just the username, without ".\" prefix),
       - to change a hostname of a computer in a domain, yo uneed to specify a domain account with alocal administrative privileges (use domainname\username syntax),
       - you cannot use Set-FtHostname function to change the hostnames of workgroup and domain joined computers at the same run.
   .PARAMETER ComputerIP
      Specifies the computer IP.
   .PARAMETER Credential
      Specifies the credential used to login:
      - local one, if the selected remote computers are in a workgroup
      - domain one, if the selected computers are joined to a domain
   .PARAMETER Force
      No questions are asked during function execution.
   .EXAMPLE
      Set-FtHostname -ComputerIP $all -Credential $Cred
    #>
   Param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] [switch]$DontWaitForHostsAfterTriggeringRestart,
      [Parameter(Mandatory = $false)] [switch]$DontCheck,
      [Parameter(Mandatory = $false)] [switch]$Force
   )

   $IP = (Get-NetIPConfiguration -Detailed | Where-Object { ($_.IPv4Address.IPAddress -In $ComputerIP) }).IPv4Address.IPAddress
   $ComputerIPWithLocalComputerIPCutOff = $ComputerIP | Where-Object { $_ -notin $IP }


   if (($null -eq $ComputerIPWithLocalComputerIPCutOff) -or ($null -ne (Compare-Object $ComputerIPWithLocalComputerIPCutOff $ComputerIP))) {
      Write-Warning "As you are running this function from a computer included in the -ComputerIP parameter, this computer will be excluded from the hostname change operation. Please change the hostname of this computer manually."
   }
   if ($null -eq $ComputerIPWithLocalComputerIPCutOff){
      Return
   }

   if (!$Force) {
      Write-Warning "An automatic immediate restart of all remote hosts is needed after this operation."
      $Continue = Read-Host 'Do you want to continue? Only yes will be accepted as confirmation. Anything else will abort the hostname change operation.'
      if ($Continue -ne 'yes') {
         Return
      }
   }

   $ftc = $global:FtConfig | ConvertFrom-Json

   Write-Host -ForegroundColor Cyan "Changing remote hosts Hostnames... " -NoNewline
   if ($Credential.UserName -like "*\*") {
      $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
      foreach ($item in $ComputerIPWithLocalComputerIPCutOff) {
         $NCN = ($ftc.hosts | Where-object { $_.IP -eq $item }).hostname
         Rename-Computer -ComputerName $item -NewName $NCN -DomainCredential $Credential -Restart -Force -WarningAction SilentlyContinue
      }
   }
   else {
      $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
      foreach ($item in $ComputerIPWithLocalComputerIPCutOff) {
         $NCN = ($ftc.hosts | Where-object { $_.IP -eq $item }).hostname
         Rename-Computer -ComputerName $item -NewName $NCN -LocalCredential $Credential -Restart -Force -WarningAction SilentlyContinue
      }

   }
   $StopWatch.Stop()
   $ElapsedSeconds = $StopWatch.Elapsed.TotalSeconds 
   Write-Host -ForegroundColor Green "DONE " -NoNewline
   Write-Host -ForegroundColor Cyan "in $ElapsedSeconds sec."
   Write-Host -ForegroundColor Cyan "Restart of the selected remote hosts triggered."
}

##############
### DOMAIN ###
##############
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
      Specifies the Domain Administrator credentials used to join (leave) the domain. Please use domainname\username syntax.
   .PARAMETER Join
      Specifies that the selected computers should join the domain specified in $DomainName parameter.
   .PARAMETER Leave
      Specifies that the selected computers should leave the domain specified in $DomainName parameter.
   .PARAMETER Force
      No questions are asked during function execution.
   .EXAMPLE
      Set-FtDomain -ComputerIP $all -Credential $cred -DomainName lop.pri -DomainAdminUsername administrator -Join
   .EXAMPLE
      Set-FtDomain -ComputerIP $all -Credential $cred -DomainName lop.pri -DomainAdminUsername administrator -Leave
   #>
   Param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] $DomainName,
      [Parameter(Mandatory = $false)] $DomainAdminUsername,
      [Parameter(Mandatory = $false)] [switch]$Join,
      [Parameter(Mandatory = $false)] [switch]$Leave,
      [Parameter(Mandatory = $false)] [switch]$Force
   )

   $ActionIndex = Confirm-FtSwitchParameters $Join $Leave

   if ($ActionIndex -ne -1) {

      $IP = (Get-NetIPConfiguration -Detailed | Where-Object { ($_.IPv4Address.IPAddress -In $ComputerIP) }).IPv4Address.IPAddress
      $ComputerIPWithLocalComputerIPCutOff = $ComputerIP | Where-Object { $_ -notin $IP }

      if (($null -eq $ComputerIPWithLocalComputerIPCutOff) -or ($null -ne (Compare-Object $ComputerIPWithLocalComputerIPCutOff $ComputerIP))) {
         Write-Warning "As you are running this function from a computer included in the -ComputerIP parameter, this computer will be excluded from the domain membership change operation. Please change the domain membership of this computer manually."
      }
      if ($null -eq $ComputerIPWithLocalComputerIPCutOff){
         Return
      }

      if (!$Force) {
         Write-Warning "An automatic immediate restart of all remote hosts is needed after this operation."
         $Continue = Read-Host 'Do you want to continue? Only yes will be accepted as confirmation. Anything else will abort the domain membership change operation.'
         if ($Continue -ne 'yes') {
            Return
         }
      }
      
      Write-Host -ForegroundColor Cyan "Changing remote hosts Domain Membership... " -NoNewline
      if ($ActionIndex -eq 0) {
         $ScriptBlock = [ScriptBlock]::create("Add-Computer -DomainName $DomainName -Credential $DomainAdminUsername -Restart -Force -WarningAction SilentlyContinue")
         $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
         Invoke-Command -ComputerName $ComputerIPWithLocalComputerIPCutOff -Credential $Credential -ScriptBlock $ScriptBlock | Out-Null
         $StopWatch.Stop()
      }
      elseif ($ActionIndex -eq 1) {
         $ScriptBlock = [ScriptBlock]::create("Remove-Computer -UnjoinDomaincredential $DomainAdminUsername -Restart -Force -WarningAction SilentlyContinue")
         $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
         Invoke-Command -ComputerName $ComputerIPWithLocalComputerIPCutOff -Credential $Credential -ScriptBlock $ScriptBlock | Out-Null
         $StopWatch.Stop()
      }
      $ElapsedSeconds = $StopWatch.Elapsed.TotalSeconds 
      Write-Host -ForegroundColor Green "DONE " -NoNewline
      Write-Host -ForegroundColor Cyan "in $ElapsedSeconds sec."
      Write-Host -ForegroundColor Cyan "Restart of the selected remote hosts triggered."
   } 
}