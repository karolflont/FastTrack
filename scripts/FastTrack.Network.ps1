###############
### NETWORK ###
###############
function Get-FtNetworkConfiguration {
   <#
   .SYNOPSIS
   Gets important Network Configuration for active NICs of remote servers.
   .DESCRIPTION
   The Get-FtNetworkConfiguration function uses Get-NetIPConfiguration and Get-NetAdapterBinding cmdlets to retrieve important Network Configuration for active NICs of remote servers.
   .PARAMETER ComputerIP
   Specifies the computer IP.
   .PARAMETER Credential
   Specifies the credentials used to login.
   .PARAMETER RawOutput
   Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
   .EXAMPLE
      Get-FtNetworkConfiguration -ComputerIP $all -Credential $cred
   #>
   param (
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )

   $HeaderMessage = "Network configuration"

   $ScriptBlock = {
      $ComputerIP = $using:ComputerIP
      $NetworkConfiguration = Get-NetIPConfiguration -Detailed | Where-Object { ($_.IPv4Address.IPAddress -In $ComputerIP) }
      $IsIPv6EnabledOnAdapter = (Get-NetAdapterBinding -Name $NetworkConfiguration.InterfaceAlias  -ComponentID ms_tcpip6).Enabled

      [pscustomobject]@{
         InterfaceAlias         = $NetworkConfiguration.InterfaceAlias
         InterfaceDescription   = $NetworkConfiguration.InterfaceDescription
         ProfileName            = $NetworkConfiguration.NetProfile.Name
         NetworkCategory        = $NetworkConfiguration.NetProfile.NetworkCategory
         LinkSpeed              = $NetworkConfiguration.NetAdapter.LinkSpeed
         IsIPv6EnabledOnAdapter = $IsIPv6EnabledOnAdapter
         IPv4Address            = $NetworkConfiguration.IPv4Address.IPAddress
         Netmask                = $NetworkConfiguration.IPv4Address.PrefixLength
         IPv4DefaultGateway     = $NetworkConfiguration.IPv4DefaultGateway.NextHop
         DNSServer              = $NetworkConfiguration.DNSServer.ServerAddresses
      }
   
   }
  
   $ActionIndex = 0
  
   $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

   $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'InterfaceAlias', 'ProfileName', 'NetworkCategory', 'LinkSpeed', 'IsIPv6EnabledOnAdapter', 'IPv4Address', 'Netmask', 'IPv4DefaultGateway', 'DNSServer' ) 

   if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
   else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}

########################
### WINDOWS FIREWALL ###
########################
function Get-FtFirewallService {
   <#
   .SYNOPSIS
       Retrieves the status and start type of Windows Firewall service.
   .DESCRIPTION
       The Get-FtFirewallService function retrieves the Status and StartType properties of Windows Firewall service using "Get-Service -Name MpsSvc" cmdlet.
   .PARAMETER ComputerIP
       Specifies the computer IP.
   .PARAMETER Credential
       Specifies the credentials used to login.
   .PARAMETER RawOutput
       Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
   .EXAMPLE
       Get-FtFirewallService -ComputerIP $all -Credential $cred 
   #>

   param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )

   $HeaderMessage = "Windows Defender Firewall service status"

   $ScriptBlock = { Get-Service -Name "MpsSvc" }
  
   $ActionIndex = 0
  
   $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

   $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'DisplayName', 'Status', 'StartType') 

   if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
   else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}

function Start-FtFirewallService {
   <#
   .SYNOPSIS
      Starts Windows Firewall service and sets its startup type to Automatic.
   .DESCRIPTION
      The Start-FtFirewallService function uses 'Set-Service -Name MpsSvc -StartupType Automatic -Status Running' cmdlet.
   .PARAMETER ComputerIP
      Specifies the computer IP.
   .PARAMETER Credential
      Specifies the credentials used to login.
   .PARAMETER DontCheck
      A switch disabling checking the set configuration with a correstponding 'get' function.
   .EXAMPLE
      Start-FtFirewallService -ComputerIP $all -Credential $cred
   #>

   param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] [switch]$DontCheck
   )

   $ScriptBlock = @()
   $ScriptBlock = { Set-Service -Name MpsSvc -StartupType Automatic -Status Running -PassThru }

   $ActionIndex = 0
 
   Invoke-FtSetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

   if (!$DontCheck) {
      Write-Host -ForegroundColor Cyan "Let's check the configuration with Get-FtFirewallService."
      Get-FtFirewallService -ComputerIP $ComputerIP -Credential $cred
   }
}

function Get-FtFirewallState {
   <#
   .SYNOPSIS
      Retrieves the firewall state for all profiles: Public, Private and Domain.
   .DESCRIPTION
      The Get-FtFirewallState function uses Get-NetFirewallProfile cmdlet.
   .PARAMETER ComputerIP
      Specifies the computer IP.
   .PARAMETER Credential
      Specifies the credentials used to login.
   .PARAMETER RawOutput
      Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
   .EXAMPLE
      Get-FtFirewallState -ComputerIP $all -Credential $cred
   #>

   param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )

   $HeaderMessage = "Windows Defender Firewall state"

   $ScriptBlock = {
      $FirewallStateAll = Get-NetFirewallProfile
      $FirewallStateDomain = $FirewallStateAll | Where-Object { $_.Name -eq 'Domain' }
      $FirewallStatePrivate = $FirewallStateAll | Where-Object { $_.Name -eq 'Private' }
      $FirewallStatePublic = $FirewallStateAll | Where-Object { $_.Name -eq 'Public' }

      [pscustomobject]@{
         DomainProfile  = if ($FirewallStateDomain.Enabled) { "On" } else { "Off" }
         PrivateProfile = if ($FirewallStatePrivate.Enabled) { "On" } else { "Off" }
         PublicProfile  = if ($FirewallStatePublic.Enabled) { "On" } else { "Off" }
      }
   }
 
   $ActionIndex = 0
 
   $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

   $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'DomainProfile', 'PrivateProfile', 'PublicProfile') 

   if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
   else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}


function Set-FtFirewallState {
   <#
   .SYNOPSIS
      Sets the firewall state On or Off for a selected profile: Public, Private and Domain or all profiles at once.
   .DESCRIPTION
      The Set-FtFirewallState function uses Set-NetFirewallProfile cmdlet for profiles state manipulation.
   .PARAMETER ComputerIP
      Specifies the computer IP.
   .PARAMETER Credential
      Specifies the credentials used to login.
   .PARAMETER AllOn
      Turns all profiles On.
   .PARAMETER AllOff
      Turns all profiles Off.
   .PARAMETER DomainOn
      Turns the Domain profile On.
   .PARAMETER DomainOff
      Turns the Domain profile Off.
   .PARAMETER PrivateOn
      Turns the Private profile On.
   .PARAMETER PrivateOff
      Turns the Private profile Off.
   .PARAMETER PublicOn
      Turns the Public profile On.
   .PARAMETER PublicOff
      Turns the Public profile Off.   
   .PARAMETER DontCheck
      A switch disabling checking the set configuration with a correstponding 'get' function.
   .EXAMPLE
      Set-FtFirewallState -ComputerIP $all -Credential $cred -AllOn
    #>
   param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] [switch]$AllOn,
      [Parameter(Mandatory = $false)] [switch]$AllOff,
      [Parameter(Mandatory = $false)] [switch]$DomainOn,
      [Parameter(Mandatory = $false)] [switch]$DomainOff,
      [Parameter(Mandatory = $false)] [switch]$PrivateOn,
      [Parameter(Mandatory = $false)] [switch]$PrivateOff,
      [Parameter(Mandatory = $false)] [switch]$PublicOn,
      [Parameter(Mandatory = $false)] [switch]$PublicOff,
      [Parameter(Mandatory = $false)] [switch]$DontCheck
   )

   $ActionIndex = Confirm-FtSwitchParameters $AllOn $AllOff $DomainOn $DomainOff $PrivateOn $PrivateOff $PublicOn $PublicOff
    
   $ScriptBlock = @()

   if ($ActionIndex -eq 0) {
      #If AllOn switch was selected
      $ScriptBlock = { Set-NetFirewallProfile -Profile Domain, Private, Public -Enabled True }
   }
   elseif ($ActionIndex -eq 1) {
      #If AllOff switch was selected
      $ScriptBlock = { Set-NetFirewallProfile -Profile Domain, Private, Public -Enabled False }
   }
   elseif ($ActionIndex -eq 2) {
      #If DomainOn switch was selected
      $ScriptBlock = { Set-NetFirewallProfile -Profile Domain -Enabled True }
   }
   elseif ($ActionIndex -eq 3) {
      #If DomainOff switch was selected
      $ScriptBlock = { Set-NetFirewallProfile -Profile Domain -Enabled False }
   }
   elseif ($ActionIndex -eq 4) {
      #If PrivateOn switch was selected
      $ScriptBlock = { Set-NetFirewallProfile -Profile Private -Enabled True }
   }
   elseif ($ActionIndex -eq 5) {
      #If PrivateOff switch was selected
      $ScriptBlock = { Set-NetFirewallProfile -Profile Private -Enabled False }
   }
   elseif ($ActionIndex -eq 6) {
      #If PublicOn switch was selected
      $ScriptBlock = { Set-NetFirewallProfile -Profile Public -Enabled True }
   }
   elseif ($ActionIndex -eq 7) {
      #If PublicOff switch was selected
      $ScriptBlock = { Set-NetFirewallProfile -Profile Public -Enabled False }
   }

   Invoke-FtSetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

   if (!$DontCheck -and ($ActionIndex -ne -1)) {
      Write-Host -ForegroundColor Cyan "Let's check the configuration with Get-FtFirewallState."
      Get-FtFirewallState -ComputerIP $ComputerIP -Credential $cred
   }
}