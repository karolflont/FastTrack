####################
##### HOSTNAME #####
####################
function Get-AvHostname{
   <#
   .SYNOPSIS
   Outputs a table comparing current hostnames and hostnames defined in $sysConfig variable for a list of computers.
   .DESCRIPTION
   The Get-AvHostname function uses:
   - $env:computername variable on remote hosts
   - "IP" and "hostname" fields from $sysConfig global variable
   .PARAMETER ComputerIP
   Specifies the computer IP.
   .PARAMETER Credentials
   Specifies the credentials used to login.
   .PARAMETER RawOutput
   Specifies if the output should be formatted or not.
   .EXAMPLE
   Get-AvHostname -ComputerIP $all -Credential $cred
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
      [pscustomobject]@{HostnameSetOnHost=$env:computername}
   }

   $sc = $global:SysConfig | ConvertFrom-Json

   $HostnamesRaw = $Hostnames | Select-Object -Property @{Name = "ComputerIP" ; Expression = {$_.PSComputerName} },
                                                        HostnameSetOnHost,
                                                        @{Name = "HostnameInConfigFile" ; Expression = {
                                                            $CurrentIP = $_.PSComputerName
                                                            ($sc.hosts | Where-object {$_.IP -eq $CurrentIP}).hostname
                                                            }
                                                        }

   $HostnamesRaw = $HostnamesRaw | Select-Object -Property ComputerIP, HostnameSetOnHost, HostnameInConfigFile,
                                                            @{Name = "HostnamesInSync" ; Expression = {
                                                               if ($_.HostnameSetOnHost -eq $_.HostnameInConfigFile){"YES"}
                                                               else {"NO"}
                                                            }
                                                            }

   if ($RawOutput){
      $HostnamesRaw
      }
   else {
      $HostnamesRaw | Sort-Object -Property ComputerIP | Format-Table -Wrap -AutoSize
   }
}
function Set-AvHostname{
   <#
   .SYNOPSIS
      Changes the hostnames of remote computers with values defined in $sysConfig variable.
   .DESCRIPTION
      The Set-AvHostname function uses:
      - Get-AvHostname
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
      Set-AvHostname -ComputerIP $all -Credential $Cred
   #>
   Param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
      [Parameter(Mandatory = $false)] [Switch] $RebootAfterHostnameChange,
      [Parameter(Mandatory = $false)] [Switch] $Force
   )

   if (-not $Force){
      $hostnames = Get-AvHostname -ComputerIP $ComputerIP -Credential $Credential -RawOutput
      Write-Host -ForegroundColor Yellow "`nWARNING: You're about to change the hostname(-s) of remote computer(-s) according to the below table. This can possibly be a harmful operation. Press Enter to continue or Ctrl+C to quit. "
      $Hostnames | Select-Object -Property ComputerIP,
                                    @{Name = "OldName"; Expression = {$_.HostnameSetOnHost}},
                                    @{Name = "NewName"; Expression = {$_.HostnameInConfigFile}} `
                                     | Sort-Object -Property ComputerIP | Format-Table -Wrap -AutoSize
      [void](Read-Host)
      if ($RebootAfterHostnameChange){
         Write-Host -ForegroundColor Yellow "`nWARNING: all remote hosts will be automatically rebooted after changing the hostnames. Press Enter to continue or Ctrl+C to quit. "
         [void](Read-Host)
      }
   }
   
   #get SysConfig into the game 
   $sc = $global:SysConfig | ConvertFrom-Json

   for ($i=0; $i -lt $ComputerIP.Length; $i++) {
      $IP = $ComputerIP[$i]
      $NCN = ($sc.hosts | Where-object {$_.IP -eq $IP}).hostname
      Invoke-Command -ComputerName $ComputerIP[$i] -Credential $Credential -ScriptBlock {Rename-Computer -ComputerName $using:IP -NewName $using:NCN}
      }
   
   Write-Host -ForegroundColor Cyan "`nall hostnames changed. "
   
   #6. Reboot remote hosts if $RebootAfterIHostnameChange switch present
   if ($RebootAfterHostnameChange) {
      Write-Host -ForegroundColor Cyan "`nWaiting for all remote hosts to reboot (We'll not wait more than 5 minutes though.)... "
      Restart-Computer -ComputerName $ComputerIP -Credential $Credential -Wait -For PowerShell -Timeout 300 -WsmanAuthentication Default -Force
      Write-Host -ForegroundColor Cyan "`nall remote hosts rebooted and available for PowerShell Remoting again. "
   }
   else{
      Write-Host -ForegroundColor Cyan "`nRemote hosts were NOT REBOOTED after the hostname change. "
      Write-Host -ForegroundColor Yellow "WARNING: Please reboot manually later as this is required for the hostname change to take effect. "
   }
}
##############
### DOMAIN ###
##############
function Get-AvDomain{
      <#
      .SYNOPSIS
         Checks the Active Directory Domain or Workgroup name for a Computer.
      .DESCRIPTION
         The Get-Domain checks the Active Directory Domain or Workgroup name for a Computer.
      .PARAMETER ComputerName
         Specifies the computer name or IP.
      .PARAMETER Credentials
         Specifies the credentials used to login.
      .EXAMPLE
         Get-AvDomain -ComputerName $all_hosts_IPs -Credential $Cred
      #>
      Param(
         [Parameter(Mandatory = $true)] $ComputerName,
         [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
      )
         $DomainMembership = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {(Get-WmiObject -Class Win32_ComputerSystem)}
         Write-Host -ForegroundColor Cyan "`nDOMAIN MEMBERSHIP "
         $DomainMembership | Select-Object PSComputerName, Name, PartOfDomain, Domain  | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
      }
function Join-AvDomain{
<#
.SYNOPSIS
   Joins computers to an Active Directory Domain.
.DESCRIPTION
   The Join-Domain joins computers to an Active Directory Domain.
.PARAMETER ComputerName
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
   Join-Domain -ComputerName $all_hosts -Credential $Cred -DomainName 'example.domain.com' -DomainAdminCredentials $AaminCred
#>
Param(
      [Parameter(Mandatory = $true)] $ComputerName,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
      [Parameter(Mandatory = $true)] $DomainName,
      [Parameter(Mandatory = $true)] $DomainAdminUsername
)

$DomainAdminUserNameFull = $DomainName + "\" + $DomainAdminUsername

#Joining the domain is interactive (will ask for domain admin password) as I did not figure out yet how to pass full credentials
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Add-Computer -DomainName $using:DomainName -Credential $using:DomainAdminUsernameFull  -Restart}
Write-Host -ForegroundColor Cyan "`n ALL COMPUTERS JOINED TO THE $DomainName DOMAIN. "
Write-Host -ForegroundColor Cyan "Reboot triggered for all remote hosts. "
}
#####################
### AVIDPSG USER #####
######################
function Get-AvPSGUserAccount{
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
Param(
      [Parameter(Mandatory = $true)] $ComputerName,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
)

    ### Check AvidPSG User account
    $AvidPSGUserStatus = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-LocalUser}
    $AvidPSGUserGroupStatus = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-LocalGroupMember -Group "Administrators"}
    Write-Host -ForegroundColor Cyan "`nAvidPSG User Status "
    $AvidPSGUserStatus | Select-Object PSComputerName, Name, Enabled, Description, UserMayChangePassword, AccountExpires, PasswordExpires | Where-Object {$_.Name -eq "AvidPSG"} | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
    Write-Host -ForegroundColor Cyan "`nAdministrators Group Members "
    $AvidPSGUserGroupStatus | Select-Object PSComputerName, Name, PrincipalSource, ObjectClass | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize # Where-Object {$_.Name -like "*AvidPSG*"} | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}
function Set-AvPSGUserAccount{
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
Param(
      [Parameter(Mandatory = $true)] $ComputerName,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
)
    ### Add AvidPSG User account
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
    $SecureStringPassword = Get-Credential -credential "AvidPSG"
    New-LocalUser -Name "AvidPSG" -Password $SecureStringPassword -PasswordNeverExpires -UserMayNotChangePassword -Description "Avid PSG Maintenace User - DO NOT DELETE"
    Add-LocalGroupMember -Group "Administrators" -Member "AvidPSG"
    }
}
function Get-AvDNSRecords{

}
