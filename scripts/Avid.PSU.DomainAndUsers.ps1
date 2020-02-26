####################
##### HOSTNAME #####
####################
function Get-AvHostname{
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
       Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {hostname}
}
function Set-AvHostname{
      <#
      .SYNOPSIS
         Changes the hostname of a remote computer.
      .DESCRIPTION
         The Set-Hostname changes the hostname of a remote computer.
      .PARAMETER ComputerName
         Specifies the computer name or IP.
      .PARAMETER Credentials
         Specifies the credentials used to login.
      .PARAMETER NewComputerName
         Specifies the new computer name to be used.
      .EXAMPLE
         Join-Domain -ComputerName $all_hosts -Credential $Cred -NewComputerName $all_hosts_new
      #>
      Param(
         [Parameter(Mandatory = $true)] $ComputerName,
         [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
         [Parameter(Mandatory = $true)] $NewComputerName,
         [Parameter(Mandatory = $false)] [Switch] $RebootAfterHostnameChange
      )
      if ($RebootAfterHostnameChange){
            Write-Host -BackgroundColor White -ForegroundColor Red "`n WARNING: All the remote hosts will be automatically rebooted after changing the hostnames. Press Enter to continue or Ctrl+C to quit. "
            [void](Read-Host)
         }

      for ($i=0; $i -lt $ComputerName.Length; $i++) {
         $CN = $ComputerName[$i]
         $NCN = $NewComputerName[$i]
         Invoke-Command -ComputerName $ComputerName[$i] -Credential $Credential -ScriptBlock {Rename-Computer -ComputerName $using:CN -NewName $using:NCN -Force}
         }
      
      Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n ALL COMPUTERS HOSTNAMES CHANGED. "
      
      #6. Reboot remote hosts if $RebootAfterIHostnameChange switch present
      if ($RebootAfterHostnameChange) {
         Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Restart-Computer -Force}
         Write-Host -BackgroundColor White -ForegroundColor Red "`n Reboot triggered for all remote hosts. "
      }
      else{
         Write-Host -BackgroundColor White -ForegroundColor Red "`n Remote hosts were NOT REBOOTED after the hostname change. "
         Write-Host -BackgroundColor White -ForegroundColor Red " Please REBOOT manually later as this is required for the hostname change to be effective. "
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
         Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n DOMAIN MEMBERSHIP "
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
Write-Host -BackgroundColor White -ForegroundColor DarkBlue " `n ALL COMPUTERS JOINED TO THE $DomainName DOMAIN. "
Write-Host -BackgroundColor White -ForegroundColor DarkBlue " Reboot triggered for all remote hosts. "
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
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n AvidPSG User Status "
    $AvidPSGUserStatus | Select-Object PSComputerName, Name, Enabled, Description, UserMayChangePassword, AccountExpires, PasswordExpires | Where-Object {$_.Name -eq "AvidPSG"} | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Administrators Group Members "
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
