# Copyright (C) 2018  Karol Flont
# Full license notice can be found in FastTrack.psd1 file.

#############################################
### DISABLE SERVER MANAGER START AT LOGON ###
#############################################
function Get-FtServerManagerBehaviorAtLogon {
    <#
.SYNOPSIS
   Checks if Server Manager starts automatically on system startup.
.DESCRIPTION
   The Get-FtServerManagerBehaviorAtLogon function uses "Get-ScheduledTask -TaskName ServerManager" to check if Server Manager starts automatically on system startup.
.PARAMETER ComputerIP
   Specifies the computer IP.
.PARAMETER Credential
   Specifies the credentials used to login.
.PARAMETER RawOutput
   Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
.EXAMPLE
   Get-FtServerManagerBehaviorAtLogon -ComputerIP $all -Credential $cred
#>
    param(
        [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    $HeaderMessage = "Server Manager behavior at logon"

    $ScriptBlock = {
        $SMBehavior = Get-ScheduledTask -TaskName ServerManager

        [pscustomobject]@{
            Name    = $SMBehavior.TaskName
            OpenAtLogon = if ($SMBehavior.State -ne "Disabled") { "True" } else { "False" }
        }
    }
   
    $ActionIndex = 0
   
    $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

    $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'Name', 'OpenAtLogon') 

    if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
    else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}
function Set-FtServerManagerBehaviorAtLogon {
    <#
.SYNOPSIS
    Enables or disables Server Manager start at logon.
.DESCRIPTION
    Set-FtServerManagerBehaviorAtLogon function enables or disables a scheduled task of starting Server Manager at user logon.
.PARAMETER ComputerIP
    Specifies the computer IP.
.PARAMETER Credential
    Specifies the credentials used to login.
.PARAMETER Enable
    A switch enabling Server Manager start at logon.
.PARAMETER Disable
    A switch disabling Server Manager start at logon.
.PARAMETER DontCheck
    A switch disabling checking the set configuration with a correstponding 'get' function.
.EXAMPLE
    Set-FtServerManagerBehaviorAtLogon -ComputerIP $all -Credential $cred -Disable
#>
    param(
        [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $false)] [switch] $Enable,
        [Parameter(Mandatory = $false)] [switch] $Disable,
        [Parameter(Mandatory = $false)] [switch] $DontCheck
    )

    $HeaderMessage = "Server Manager behavior at logon"

    $ActionIndex = Confirm-FtSwitchParameters $Enable $Disable

    if ($ActionIndex -eq 0) {
        #If Enable switch was selected
        $ScriptBlock = { Get-ScheduledTask -TaskName ServerManager | Enable-ScheduledTask }
    }
    elseif ($ActionIndex -eq 1) {
        #If Disable switch was selected
        $ScriptBlock = { Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask }
    }

    Invoke-FtSetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

    if (!$DontCheck -and ($ActionIndex -ne -1)) {
        Write-Host -ForegroundColor Cyan "Let's check the configuration with Get-FtServerManagerBehaviorAtLogon."
        Get-FtServerManagerBehaviorAtLogon -ComputerIP $ComputerIP -Credential $cred
    }
}
###############
##### UAC #####
###############
function Get-FtUACLevelForAdmins {
    <#
.SYNOPSIS
   Checks the User Access Control behavior for administrators on selected remote hosts.
.DESCRIPTION
   The Get-FtUACLevelForAdmins function checks the "ConsentPromptBehaviorAdmin" value of the "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" key.
   Specific ConsentPromptBehaviorAdmin values represents the following UAC Levels:
   - ConsentPromptBehaviorAdmin = 0 - Never notify me
   - ConsentPromptBehaviorAdmin = 1 - Always prompt for credentials (in secure desktop mode)
   - ConsentPromptBehaviorAdmin = 2 - Always prompt for Permit/Deny (in secure desktop mode)
   - ConsentPromptBehaviorAdmin = 3 - Always prompt for credentials
   - ConsentPromptBehaviorAdmin = 4 - Always prompt for Permit/Deny
   - ConsentPromptBehaviorAdmin = 5 - Prompt for Permit/Deny only when apps try to make changes to my computer (in secure desktop mode)
   
   For more information visit https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-gpsb/341747f5-6b5d-4d30-85fc-fa1cc04038d4.
.PARAMETER ComputerIP
   Specifies the computer IP.
.PARAMETER Credential
   Specifies the credentials used to login.
.PARAMETER RawOutput
   Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
.EXAMPLE
   Get-FtUACLevelForAdmins -ComputerIP $all -Credential $cred
#>
    param(
        [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    ### Windows Server 2016 only!!!
    
    $HeaderMessage = "UAC Level for admins"

    $ScriptBlock = {
        $ConsentPromptBehaviorAdmin = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin").ConsentPromptBehaviorAdmin
        
        if ($ConsentPromptBehaviorAdmin -eq 0) { $UACLevel = "Never notify me" }
        elseif ($ConsentPromptBehaviorAdmin -eq 1) { $UACLevel = "Always prompt for credentials (in secure desktop mode)" }
        elseif ($ConsentPromptBehaviorAdmin -eq 2) { $UACLevel = "Always prompt for Permit/Deny (in secure desktop mode)" }
        elseif ($ConsentPromptBehaviorAdmin -eq 3) { $UACLevel = "Always prompt for credentials" }
        elseif ($ConsentPromptBehaviorAdmin -eq 4) { $UACLevel = "Always prompt for Permit/Deny" }
        elseif ($ConsentPromptBehaviorAdmin -eq 5) { $UACLevel = "Prompt for Permit/Deny only when apps try to make changes to my computer (in secure desktop mode)" }
        else { $UACLevel = "UNKNOWN" }

        [pscustomobject]@{
            UACLevel = $UACLevel
        }

    }
   
    $ActionIndex = 0
   
    $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

    $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'UACLevel') 

    if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
    else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}

function Set-FtUACLevelForAdmins {
    <#
.SYNOPSIS
   Sets the User Access Control behavior for administrators on selected remote hosts.
.DESCRIPTION
   The Get-FtUACLevelForAdmins function sets the "ConsentPromptBehaviorAdmin" value of the "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" key.
   Specific ConsentPromptBehaviorAdmin values represents the following UAC Levels:
   - ConsentPromptBehaviorAdmin = 0 - Never notify me
   - ConsentPromptBehaviorAdmin = 1 - Always prompt for credentials (in secure desktop mode)
   - ConsentPromptBehaviorAdmin = 2 - Always prompt for Permit/Deny (in secure desktop mode)
   - ConsentPromptBehaviorAdmin = 3 - Always prompt for credentials
   - ConsentPromptBehaviorAdmin = 4 - Always prompt for Permit/Deny
   - ConsentPromptBehaviorAdmin = 5 - Prompt for Permit/Deny only when apps try to make changes to my computer (in secure desktop mode)
   
   For more information visit https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-gpsb/341747f5-6b5d-4d30-85fc-fa1cc04038d4.
.PARAMETER ComputerIP
   Specifies the computer IP.
.PARAMETER Credential
   Specifies the credentials used to login.
.PARAMETER DontCheck
    A switch disabling checking the set configuration with a correstponding 'get' function.
.EXAMPLE
   Set-FtUACLevelForAdmins -ComputerIP $all -Credential $cred -NeverNotify
#>
    param(
        [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $false)] [switch] $NeverNotify,
        [Parameter(Mandatory = $false)] [switch] $AlwaysPromptForCredInSecureDesktopMode,
        [Parameter(Mandatory = $false)] [switch] $AlwaysPromptForPermitDenyInSecureDesktopMode,
        [Parameter(Mandatory = $false)] [switch] $AlwaysPromptForCred,
        [Parameter(Mandatory = $false)] [switch] $AlwaysPromptForPermitDeny,
        [Parameter(Mandatory = $false)] [switch] $PromptForPermitDenyOnlyWnenAppsTryToMakeChangesToMyComputer,
        [Parameter(Mandatory = $false)] [switch] $DontCheck
    )

    $HeaderMessage = "UAC Level for admins"

    $ActionIndex = Confirm-FtSwitchParameters $NeverNotify $AlwaysPromptForCredInSecureDesktopMode $AlwaysPromptForPermitDenyInSecureDesktopMode $AlwaysPromptForCred $AlwaysPromptForPermitDeny $PromptForPermitDenyOnlyWnenAppsTryToMakeChangesToMyComputer

    if ($ActionIndex -eq 0) {
        #If AlwaysNotify switch was selected
        $ScriptBlock = { Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "0" }
    }
    elseif ($ActionIndex -eq 1) {
        #If NotifyWhenAppsMakeChangesToComputer switch was selected
        $ScriptBlock = { Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "1" }
    }
    elseif ($ActionIndex -eq 2) {
        #If NeverNotify switch was selected
        $ScriptBlock = { Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "2" }
    }
    elseif ($ActionIndex -eq 3) {
        #If NotifyWhenAppsMakeChangesToComputer switch was selected
        $ScriptBlock = { Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "3" }
    }
    elseif ($ActionIndex -eq 4) {
        #If NeverNotify switch was selected
        $ScriptBlock = { Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "4" }
    }
    elseif ($ActionIndex -eq 5) {
        #If NeverNotify switch was selected
        $ScriptBlock = { Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "5" }
    }
    
    Invoke-FtSetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

    if (!$DontCheck -and ($ActionIndex -ne -1)) {
        Write-Host -ForegroundColor Cyan "Let's check the configuration with Get-FtUACLevelForAdmins."
        Get-FtUACLevelForAdmins -ComputerIP $ComputerIP -Credential $cred
    }
}
################################
##### PROCESSOR SCHEDULING #####
################################
function Get-FtProcessorScheduling {
    <#
    .SYNOPSIS
        Gets the Processor Scheduling setting: programs or background services
    .DESCRIPTION
        The Get-FtProcessorScheduling function:
        - retrieves the Win32PrioritySeparation value of HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl key,
        - checks the edition of the OS
        Based on these two factors if evaluates the Processor Scheduling setting.
        For more information visit https://docs.microsoft.com/en-us/previous-versions//cc976120(v=technet.10)?redirectedfrom=MSDN.
    .PARAMETER ComputerIP
        Specifies the computer IP.
    .PARAMETER Credential
        Specifies the credentials used to login.
    .PARAMETER RawOutput
        Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
    .EXAMPLE
        Get-FtProcessorScheduling -ComputerIP $all -Credential $cred
    #>
    param(
        [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    $HeaderMessage = "Processor scheduling"

    $ScriptBlock = {
        $ProcessorSchedulingRaw = (Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation).Win32PrioritySeparation
        $WindowsEdition = Get-WindowsEdition -Online
        if ($ProcessorSchedulingRaw -eq 2) {
            if ($WindowsEdition.Edition -like "*Server*") { $ProcessorScheduling = "Optimized for background services" }
            else { $ProcessorScheduling = "Optimized for programs" }
            
        }
        elseif ($ProcessorSchedulingRaw -eq 24) { $ProcessorScheduling = "Optimized for background services" }
        elseif ($ProcessorSchedulingRaw -eq 38) { $ProcessorScheduling = "Optimized for programs" }
        else { $ProcessorScheduling = "UNKNOWN" }

        [pscustomobject]@{
            ProcessorScheduling = $ProcessorScheduling
        }
    }
   
    $ActionIndex = 0
   
    $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

    $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'ProcessorScheduling') 

    if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
    else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}

function Set-FtProcessorScheduling {
    <#
    .SYNOPSIS
        Sets processor schedulling to Programs or Background Services.
    .DESCRIPTION
        The Set-ProcessorScheduling function sets processor scheduling to Programs or Background Services.
        If default is choosen the Win32PrioritySeparation value of HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl key is set to 2.
        This means Programs for Windows Workstation and Background Services for Windows Server.
        For more informatino visit https://docs.microsoft.com/en-us/previous-versions//cc976120(v=technet.10)?redirectedfrom=MSDN.
    .PARAMETER ComputerIP
        Specifies the computer IP.
    .PARAMETER Credential
        Specifies the credentials used to login.
    .PARAMETER DontCheck
        A switch disabling checking the set configuration with a correstponding 'get' function.
    .EXAMPLE
        Set-FtProcessorScheduling -ComputerIP $all -Credential $cred -BackgroundServices
    #>
    param(
        [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $false)] [switch]$Programs,
        [Parameter(Mandatory = $false)] [switch]$BackgroundServices,
        [Parameter(Mandatory = $false)] [switch]$Default,
        [Parameter(Mandatory = $false)] [switch]$DontCheck
    )

    $HeaderMessage = "Processor scheduling"

    $ActionIndex = Confirm-FtSwitchParameters $Programs $BackgroundServices $Default
    
    if ($ActionIndex -eq 0) {
        #If Programs switch was selected
        $ScriptBlock = { Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation -Value 38 }
    }
    elseif ($ActionIndex -eq 1) {
        #If BackgroundServices switch was selected
        $ScriptBlock = { Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation -Value 24 }
    }
    elseif ($ActionIndex -eq 2) {
        #If Default switch was selected
        $ScriptBlock = { Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation -Value 2 }
    }

    Invoke-FtSetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

    if (!$DontCheck -and ($ActionIndex -ne -1)) {
        Write-Host -ForegroundColor Cyan "Let's check the configuration with Get-FtProcessorScheduling."
        Get-FtProcessorScheduling -ComputerIP $ComputerIP -Credential $cred
    }
}

######################
##### POWER PLAN #####
######################
function Get-FtPowerPlan {
    <#
    .SYNOPSIS
       Gets the ACTIVE Power Plan of the server.
    .DESCRIPTION
       The Get-FtPowerPlan function checks the ACTIVE Power Plan of the server.
       The function uses "Get-CimInstance -Namespace root\cimv2\power -ClassName win32_PowerPlan" command.
    .PARAMETER ComputerIP
       Specifies the computer IP.
    .PARAMETER Credential
       Specifies the credentials used to login.
    .PARAMETER RawOutput
        Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
    .EXAMPLE
       Get-FtPowerPlan -ComputerIP $all -Credential $cred
    #>
    param(
        [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    $HeaderMessage = "Active power plans"

    $ScriptBlock = {
        $PowerPlans = Get-CimInstance -Namespace root\cimv2\power -ClassName win32_PowerPlan

        [pscustomobject]@{
            PowerPlan = ($PowerPlans | Where-Object { $_.IsActive -eq $true }).ElementName
        }
    }
   
    $ActionIndex = 0
    
    $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

    $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'PowerPlan') 

    if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
    else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}
function Set-FtPowerPlan {
    <#
.SYNOPSIS
    Sets the ACTIVE Power Plan of the server.
.DESCRIPTION
    The Set-PowerPlan function sets the ACTIVE Power Plan of the server to one of the:
    - High performance,
    - Balanced,
    - Power saver,
    The function uses Get-CimInstance and Invoke-CimMethod cmdlets.
.PARAMETER ComputerIP
    Specifies the computer IP.
.PARAMETER Credential
    Specifies the credentials used to login.
.PARAMETER DontCheck
    A switch disabling checking the set configuration with a correstponding 'get' function.
.EXAMPLE
    Set-FtPowerPlan -ComputerIP $all -credential $cred -HighPerformance
#>
    param(
        [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $false)] [switch] $HighPerformance,
        [Parameter(Mandatory = $false)] [switch] $Balanced,
        [Parameter(Mandatory = $false)] [switch] $PowerSaver,
        [Parameter(Mandatory = $false)] [switch] $AvidOptimized,
        [Parameter(Mandatory = $false)] [switch] $DontCheck
    )

    $HeaderMessage = "Active power plans"

    $ActionIndex = Confirm-FtSwitchParameters $HighPerformance $Balanced $PowerSaver
    
    if ($ActionIndex -eq 0) {
        #If HighPerformance switch was selected
        $ScriptBlock = {
            $HighPerformancePowerPlan = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'High performance'"
            Invoke-CimMethod -InputObject $HighPerformancePowerPlan -MethodName Activate | Out-Null
        }
    }
    elseif ($ActionIndex -eq 1) {
        #If Balanced switch was selected
        $ScriptBlock = {
            $BalancedPowerPlan = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'Balanced'"
            Invoke-CimMethod -InputObject $BalancedPowerPlan -MethodName Activate | Out-Null
        }
    }
    elseif ($ActionIndex -eq 2) {
        #If PowerSaver switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
            $PowerSaverPowerPlan = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'Power saver'"
            Invoke-CimMethod -InputObject $PowerSaverPowerPlan -MethodName Activate | Out-Null
        }
    }

    Invoke-FtSetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

    if (!$DontCheck -and ($ActionIndex -ne -1)) {
        Write-Host -ForegroundColor Cyan "Let's check the configuration with Get-FtPowerPlan."
        Get-FtPowerPlan -ComputerIP $ComputerIP -Credential $cred
    }
}



    
    
    





