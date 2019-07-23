function Get-APSUAutologonStatus($ComputerName,[System.Management.Automation.PSCredential] $Credential){
<#
.SYNOPSIS
    Gets Windows Autologon status.
.DESCRIPTION
    The Get-APSUAutologon function gets Windows Autologon status. 
.PARAMETER ComputerName
    Specifies the computer name.
.PARAMETER Credentials
    Specifies the credentials used to login.
.EXAMPLE
    TODO
#>
$WinlogonKey = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
    (Get-Item -LiteralPath $path -ErrorAction SilentlyContinue).GetValue("AutoAdminLogon")
}
$AutologonStatusDefaultUsername = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
    Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUsername"
}
$AutologonStatusDefaultDomain = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
    Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultDomainName"
}
$AutologonStatusDefaultPassword = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
    Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "ShutdownWithoutLogon"

$AutologonStatus = $AutologonStatusAutoAdminLogon | Add-Member -MemberType NoteProperty -Name Username -Value $AutologonStatusDefaultUsername
$AutologonStatus = $AutologonStatus | Add-Member -MemberType NoteProperty -Name Username -Value $AutologonStatusDefaultPassword

}



### Set autologon
# https://www.powershellgallery.com/packages/DSCR_AutoLogon/2.1.0
# http://easyadminscripts.blogspot.com/2013/01/enabledisable-autoadminlogon-with.html
# http://andyarismendi.blogspot.com/2011/10/powershell-set-secureautologon.html - tu ejst wersja z LSA Secretem
# https://github.com/chocolatey/boxstarter/blob/master/Boxstarter.Bootstrapper/Set-SecureAutoLogon.ps1
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$DefaultUsername = "your username"
$DefaultPassword = "your password"

Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String 
Set-ItemProperty $RegPath "DefaultUsername" -Value "$DefaultUsername" -type String 
Set-ItemProperty $RegPath "DefaultPassword" -Value "$DefaultPassword" -type String

}

function Set-APSUAutologon($ComputerName,[System.Management.Automation.PSCredential] $Credential, [switch]$Enable, [switch]$Disable){
    <#
    .SYNOPSIS
        Enables or disables Windows Autologon.
    .DESCRIPTION
        The Set-APSUAutologon function enables or disables Windows Autologon. 
    .PARAMETER ComputerName
        Specifies the computer name.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    if ($Enable) {
        if ($Disable) {
            Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONLY ONE of the -Enable/-Disable switch parameters. "
        Return
        }
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-MpPreference -DisableRealtimeMonitoring $false}
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Windows Defender Realtime Monitoring ENABLED. "
    }
    elseif ($Disable) {
        if ($Enable) {
            Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONLY ONE of the -Enable/-Disable switch parameters. "
            Return
        }
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-MpPreference -DisableRealtimeMonitoring $true}
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Windows Defender Realtime Monitoring DISABLED. "
    }
    else {
        Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONE of the -Enable/-Disable switch parameters. "
        Return
    }

    Get-APSUWindowsDefenderRealtimeMonitoringStatus $ComputerName $Credential
}

#####################
##### AUTOLOGON #####
#####################

