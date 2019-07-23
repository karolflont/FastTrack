#####################
### AVIDPSG USER #####
######################

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
function Get-APSUAvidPSGUserAccount($ComputerName,[System.Management.Automation.PSCredential] $Credential){
    ### Check AvidPSG User account
    $AvidPSGUserStatus = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-LocalUser}
    $AvidPSGUserGroupStatus = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-LocalGroupMember -Group "Administrators"}
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n AvidPSG User Status "
    $AvidPSGUserStatus | Select-Object PSComputerName, Name, Enabled, Description, UserMayChangePassword, AccountExpires, PasswordExpires | Where-Object {$_.Name -eq "AvidPSG"} | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Administrators Group Members "
    $AvidPSGUserGroupStatus | Select-Object PSComputerName, Name, PrincipalSource, ObjectClass | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize # Where-Object {$_.Name -like "*AvidPSG*"} | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}

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
function Set-APSUAvidPSGUserAccount($ComputerName,[System.Management.Automation.PSCredential] $Credential){
    ### Add AvidPSG User account
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
    $SecureStringPassword = Get-Credential -credential "AvidPSG"
    New-LocalUser -Name "AvidPSG" -Password $SecureStringPassword -PasswordNeverExpires -UserMayNotChangePassword -Description "Avid PSG Maintenace User - DO NOT DELETE"
    Add-LocalGroupMember -Group "Administrators" -Member "AvidPSG"
    }
}
