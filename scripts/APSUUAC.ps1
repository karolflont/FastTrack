###############
##### UAC #####
###############

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
function Get-APSUUACLevel($ComputerName,[System.Management.Automation.PSCredential] $Credential){
    ### Check UAC level - Windows Server 2016 only!!!
    # https://gallery.technet.microsoft.com/scriptcenter/Disable-UAC-using-730b6ecd#content
    $UACLevel = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin"}
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n UAC Level                                                       "
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue " 2 - Always notify me                                            "
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue " 5 - Notify me only when apps try to make changes to my computer "
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue " 0 - Never notify me                                             "
    $UACLevel | Select-Object PSComputerName, ConsentPromptBehaviorAdmin | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
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
function Disable-APSUUAC($ComputerName,[System.Management.Automation.PSCredential] $Credential){
### Set UAC level to "Never notify me"
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "0"}
}
