#############################################
### DISABLE SERVER MANAGER START AT LOGON ###
#############################################
function Get-ServerManagerBehaviorAtLogon{
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
param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )

    Write-Host -BackgroundColor White -ForegroundColor DarkBlue " `n Server Manager Behavior At Logon"
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-ScheduledTask -TaskName ServerManager}
}
function Set-ServerManagerBehaviorAtLogon{
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
param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch] $Enable,
        [Parameter(Mandatory = $false)] [switch] $Disable
    )

    $ActionIndex = Test-IfExactlyOneSwitchParameterIsTrue $Enable $Disable

    if ($ActionIndex -eq 0){
        #If Enable switch was selected
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-ScheduledTask -TaskName ServerManager | Enable-ScheduledTask}
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen " `n Server Manager Start At Logon ENABLED for all remote hosts."
    }
    elseif ($ActionIndex -eq 1){
        #If Disable switch was selected
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask}
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen " `n Server Manager Start At Logon DISABLED for all remote hosts."
    } 
}

###############
##### UAC #####
###############
function Get-UACLevel{
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
param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )

    ### Check UAC level - Windows Server 2016 only!!!
    # https://gallery.technet.microsoft.com/scriptcenter/Disable-UAC-using-730b6ecd#content
    $UACLevel = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin"}
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n UAC Level                                                       "
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue " 2 - Always notify me                                            "
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue " 5 - Notify me only when apps try to make changes to my computer "
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue " 0 - Never notify me                                             "
    $UACLevel | Select-Object PSComputerName, ConsentPromptBehaviorAdmin | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}
function Set-UACLevel{
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
param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch] $AlwaysNotify,
        [Parameter(Mandatory = $false)] [switch] $NotifyWhenAppsMakeChangesToComputer,
        [Parameter(Mandatory = $false)] [switch] $NeverNotify
    )

    $ActionIndex = Test-IfExactlyOneSwitchParameterIsTrue $AlwaysNotify $NotifyWhenAppsMakeChangesToComputer $NeverNotify
    
    if ($ActionIndex -eq 0){
        #If AlwaysNotify switch was selected
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "2"}
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n UAC Level changed to `"Always notify me`" for all hosts. "
        Get-UACLevel $ComputerName $Credential
    }
    elseif ($ActionIndex -eq 1){
        #If NotifyWhenAppsMakeChangesToComputer switch was selected
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "5"}
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n UAC Level changed to `"Notify me only when apps try to make changes to my computer`" for all hosts. "
        Get-UACLevel $ComputerName $Credential
    }
    elseif ($ActionIndex -eq 2){
        #If NeverNotify switch was selected
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "0"}
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n UAC Level changed to `"Never notify me`" for all hosts. "
        Get-UACLevel $ComputerName $Credential
    }
}
################################
##### PROCESSOR SCHEDULING #####
################################
function Get-ProcessorScheduling{
    <#
    .SYNOPSIS
        Gets the Processor Scheduling setting: programs or background services
    .DESCRIPTION
        TODO
    .PARAMETER ComputerName
        Specifies the computer name.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )

    $ProcesorSchedulingStatus = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
        Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation
    }
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Processor scheduling status: 38 - programs; 0(default) or 24 - background services "
    $ProcesorSchedulingStatus | Select-Object PSComputerName, Win32PrioritySeparation | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}
function Set-ProcessorScheduling{
    <#
    .SYNOPSIS
        Sets processor schedulling to Programs or Background Services.
    .DESCRIPTION
        The Set-ProcessorScheduling function sets processor scheduling to Programs or Background Services. 
    .PARAMETER ComputerName
        Specifies the computer name.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch]$Programs,
        [Parameter(Mandatory = $false)] [switch]$BackgroundServices
    )

    $ActionIndex = Test-IfExactlyOneSwitchParameterIsTrue $Programs $BackgroundService
    
    if ($ActionIndex -eq 0){
        #If Programs switch was selected
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
            Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation -Value 38
        }
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Processor scheduling set to PROGRAMS. "
        Get-ProcessorScheduling $ComputerName $Credential
    }
    elseif ($ActionIndex -eq 1){
        #If BackgroundService switch was selected
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
            Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation -Value 24
        }
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Processor scheduling set to BACKGROUND SERVICES. "
        Get-ProcessorScheduling $ComputerName $Credential
    }
}
################################
### ADJUSTING VISUAL EFFECTS ###
################################
function Set-VisualEffects{
}
#####################
##### AUTOLOGON #####
#####################
function Get-AutologonStatus{
    <#
    .SYNOPSIS
        Gets Windows Autologon status.
    .DESCRIPTION
        The Get-Autologon function gets Windows Autologon status. 
    .PARAMETER ComputerName
        Specifies the computer name.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )
    <#
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
        Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "ShutdownWithoutLogon"}
    
    $AutologonStatus = $AutologonStatusAutoAdminLogon | Add-Member -MemberType NoteProperty -Name Username -Value $AutologonStatusDefaultUsername
    $AutologonStatus = $AutologonStatus | Add-Member -MemberType NoteProperty -Name Domain -Value $AutologonStatusDefaultDomain
    $AutologonStatus = $AutologonStatus | Add-Member -MemberType NoteProperty -Name Password -Value $AutologonStatusDefaultPassword
    #>
        
    
    ### Set autologon
    # https://www.powershellgallery.com/packages/DSCR_AutoLogon/2.1.0
    # http://easyadminscripts.blogspot.com/2013/01/enabledisable-autoadminlogon-with.html
    # http://andyarismendi.blogspot.com/2011/10/powershell-set-secureautologon.html - tu ejst wersja z LSA Secretem
    # https://github.com/chocolatey/boxstarter/blob/master/Boxstarter.Bootstrapper/Set-SecureAutoLogon.ps1
    #$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    #$DefaultUsername = "your username"
    #$DefaultPassword = "your password"
    
    #Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String 
    #Set-ItemProperty $RegPath "DefaultUsername" -Value "$DefaultUsername" -type String 
    #Set-ItemProperty $RegPath "DefaultPassword" -Value "$DefaultPassword" -type String
    
    }
function Set-Autologon{
    <#
    .SYNOPSIS
        Enables or disables Windows Autologon.
    .DESCRIPTION
        The Set-Autologon function enables or disables Windows Autologon. 
    .PARAMETER ComputerName
        Specifies the computer name.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch]$Enable,
        [Parameter(Mandatory = $false)] [switch]$Disable
    )

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

    Get-WindowsDefenderRealtimeMonitoringStatus $ComputerName $Credential
}
####################
##### KEYBOARD #####
####################
#https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-input-locales-for-windows-language-packs
function Get-KeyboardLayout{
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
param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )

    ### Get keyboard layout - to nie do konca tak jest, bo co jak sa dwa jezyki??? - dostajemy liste i nie wiadomo ktory jest aktualnie wlaczony
    $InputMethodTips = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
        $LanguageList = Get-WinUserLanguageList
        $LanguageList.InputMethodTips}
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Default keyboard layout (0409:0000000409 - en-US) `n"
    for ($i=0; $i -le $ComputerName.Count; $i++) {
        Write-Host -NoNewline $ComputerName[$i], " "
        Write-Host $InputMethodTips[$i]
    }
}
function Set-KeyboardLayout{
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
param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )

    ### Set keyboard layout to en-US
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-WinDefaultInputMethodOverride -InputTip "0409:00000409"}
}
######################
##### POWER PLAN #####
######################
function Get-PowerPlan{
    <#
    .SYNOPSIS
       Gets the ACTIVE Power Plan of the server.
    .DESCRIPTION
       The Get-PowerPlan function gets the ACTIVE Power Plan of the server.

       The function uses Get-CimInstance cmdlet.
    .PARAMETER ComputerName
       Specifies the computer name.
    .PARAMETER Credentials
       Specifies the credentials used to login.
    .EXAMPLE
       TODO
    #>
    param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )

    $PowerPlan = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-CimInstance -Namespace root\cimv2\power -ClassName win32_PowerPlan}
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Active Power Plan "
    $PowerPlan | Where-Object {$_.IsActive -eq $True} | Select-Object PSComputerName, ElementName | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}
function Set-PowerPlan{
<#
.SYNOPSIS
    Sets the ACTIVE Power Plan of the server.
.DESCRIPTION
    The Set-PowerPlan function sets the ACTIVE Power Plan of the server to one of the:
    - High performance,
    - Balanced,
    - Power saver,
    - Avid optimized - NOT YET IMPLEMENTED
    The function uses Get-CimInstance and Invoke-CimMethod cmdlets.
.PARAMETER ComputerName
    Specifies the computer name.
.PARAMETER Credentials
    Specifies the credentials used to login.
.EXAMPLE
    Set-PowerPlan -ComputerName $srv -credential $cred -HighPerformance
#>
    param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch] $HighPerformance,
        [Parameter(Mandatory = $false)] [switch] $Balanced,
        [Parameter(Mandatory = $false)] [switch] $PowerSaver,
        [Parameter(Mandatory = $false)] [switch] $AvidOptimized
    )
    $ActionIndex = Test-IfExactlyOneSwitchParameterIsTrue $HighPerformance $Balanced $PowerSaver $AvidOptimized 
    
    if ($ActionIndex -eq 0){
        #If HighPerformance switch was selected
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
            $HighPerformancePowerPlan = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'High performance'"
            Invoke-CimMethod -InputObject $HighPerformancePowerPlan -MethodName Activate | Out-Null
        }
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Power Plan SET to HIGH PERFORMANCE. "
        Get-PowerPlan $ComputerName $Credential
    }
    elseif ($ActionIndex -eq 1){
        #If Balanced switch was selected
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
            $BalancedPowerPlan = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'Balanced'"
            Invoke-CimMethod -InputObject $BalancedPowerPlan -MethodName Activate | Out-Null
        }
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Power Plan SET to BALANCED. "
        Get-PowerPlan $ComputerName $Credential
    }
    elseif ($ActionIndex -eq 2){
        #If PowerSaver switch was selected
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
            $PowerSaverPowerPlan = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'Power saver'"
            Invoke-CimMethod -InputObject $PowerSaverPowerPlan -MethodName Activate | Out-Null
        }
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Power Plan SET to POWER SAVER. "
        Get-PowerPlan $ComputerName $Credential
    }
    elseif ($ActionIndex -eq 3){
        #If AvidOptimized switch was selected
        Write-Host -BackgroundColor White -ForegroundColor Red "`n AvidOptimized power plan is not yet implemented. "
        Return
    }

    
}



    
    
    





