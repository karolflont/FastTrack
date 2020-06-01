#############################################
### DISABLE SERVER MANAGER START AT LOGON ###
#############################################
function Get-CbServerManagerBehaviorAtLogon {
    <#
.SYNOPSIS
   Checks if Server Manager starts automatically on system startup.
.DESCRIPTION
   The Get-CbServerManagerBehaviorAtLogon function uses "Get-ScheduledTask -TaskName ServerManager" to check if Server Manager starts automatically on system startup.
.PARAMETER ComputerIP
   Specifies the computer IP.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   Get-CbServerManagerBehaviorAtLogon -ComputerIP $all -Credential $cred
#>
    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    $HeaderMessage = "----- Server Manager behavior at logon -----"

    $ScriptBlock = { Get-ScheduledTask -TaskName ServerManager }

    $NullMessage = "Something went wrong retrieving Server Manager behavior at logon status from selected remote hosts"
   
    $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'TaskName', 'State') 

    $ActionIndex = 0
   
    if ($RawOutput) {
        Invoke-CbScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput
    }
    else {
        Invoke-CbScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex
    }
}
function Set-CbServerManagerBehaviorAtLogon {
    <#
.SYNOPSIS
    Enables or disables Server Manager start at logon.
.DESCRIPTION
    Set-CbServerManagerBehaviorAtLogon function enables or disables a scheduled task of starting Server Manager at user logon.
.PARAMETER ComputerIP
    Specifies the computer IP.
.PARAMETER Credentials
    Specifies the credentials used to login.
.PARAMETER Enable
    A switch enabling Server Manager start at logon.
.PARAMETER Disable
    A switch disabling Server Manager start at logon.
.EXAMPLE
    Set-CbServerManagerBehaviorAtLogon -ComputerName $all -Credential $cred -Disable
#>
    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch] $Enable,
        [Parameter(Mandatory = $false)] [switch] $Disable
    )

    $ActionIndex = Test-CbIfExactlyOneSwitchParameterIsTrue $Enable $Disable

    if ($ActionIndex -eq 0) {
        #If Enable switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Get-ScheduledTask -TaskName ServerManager | Enable-ScheduledTask } | Out-Null
        Write-Host -ForegroundColor Green "Server Manager start at Logon ENABLED for selected remote hosts."
    }
    elseif ($ActionIndex -eq 1) {
        #If Disable switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask } | Out-Null
        Write-Host -ForegroundColor Green "Server Manager start at Logon DISABLED for selected remote hosts."
    }
    Write-Host -ForegroundColor Cyan "Checking the status with Get-CbServerManagerBehaviorAtLogon."

    Get-CbServerManagerBehaviorAtLogon -ComputerIP $ComputerIP -Credential $Credential
}

###############
##### UAC #####
###############
function Get-CbUACLevel {
    <#
.SYNOPSIS
   Checks the User Access Control level on selected remote hosts.
.DESCRIPTION
   The Get-CbUACLevel function checks the "ConsentPromptBehaviorAdmin" value of the "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" key.
   Specific ConsentPromptBehaviorAdmin values represents the following UAC Levels:
   - ConsentPromptBehaviorAdmin = 2 - Always notify me
   - ConsentPromptBehaviorAdmin = 5 - Notify me only when apps try to make changes to my computer
   - ConsentPromptBehaviorAdmin = 0 - Never notify me
.PARAMETER ComputerIP
   Specifies the computer IP.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   Get-CbUACLevel -ComputerIP $all -Credential $cred
#>
    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    ### Check UAC level - Windows Server 2016 only!!!
    # https://gallery.technet.microsoft.com/scriptcenter/Disable-UAC-using-730b6ecd#content
    $HeaderMessage = "----- UAC Level -----`nConsentPromptBehaviorAdmin = 2 - Always notify me`nConsentPromptBehaviorAdmin = 5 - Notify me only when apps try to make changes to my computer`nConsentPromptBehaviorAdmin = 0 - Never notify me"

    $ScriptBlock = { Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" }

    $NullMessage = "Something went wrong retrieving UAC level from selected remote hosts"
   
    $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'ConsentPromptBehaviorAdmin') 

    $ActionIndex = 0
   
    if ($RawOutput) {
        Invoke-CbScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput
    }
    else {
        Invoke-CbScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex
    }
}

function Set-CbUACLevel {
    <#
.SYNOPSIS
   TODO
.DESCRIPTION
   TODO
.PARAMETER ComputerIP
   Specifies the computer IP.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   TODO
#>
    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch] $AlwaysNotify,
        [Parameter(Mandatory = $false)] [switch] $NotifyWhenAppsMakeChangesToComputer,
        [Parameter(Mandatory = $false)] [switch] $NeverNotify
    )

    $ActionIndex = Test-CbIfExactlyOneSwitchParameterIsTrue $AlwaysNotify $NotifyWhenAppsMakeChangesToComputer $NeverNotify
    
    if ($ActionIndex -eq 0) {
        #If AlwaysNotify switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "2" }
        Write-Host -ForegroundColor Green "`nUAC Level changed to `"Always notify me`" for all hosts."
        Get-CbUACLevel $ComputerIP $Credential
    }
    elseif ($ActionIndex -eq 1) {
        #If NotifyWhenAppsMakeChangesToComputer switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "5" }
        Write-Host -ForegroundColor Green "`nUAC Level changed to `"Notify me only when apps try to make changes to my computer`" for all hosts."
        Get-CbUACLevel $ComputerIP $Credential
    }
    elseif ($ActionIndex -eq 2) {
        #If NeverNotify switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "0" }
        Write-Host -ForegroundColor Green "`nUAC Level changed to `"Never notify me`" for all hosts."
        Get-CbUACLevel $ComputerIP $Credential
    }
}
################################
##### PROCESSOR SCHEDULING #####
################################
function Get-CbProcessorScheduling {
    <#
    .SYNOPSIS
        Gets the Processor Scheduling setting: programs or background services
    .DESCRIPTION
        TODO
    .PARAMETER ComputerIP
        Specifies the computer IP.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    $ProcesorSchedulingStatus = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
        Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation
    }
    Write-Host -ForegroundColor Cyan "`nProcessor scheduling status:"
    Write-Host -ForegroundColor Cyan "2 - Default value. Optimized for background services on Windows Server and for programs on Windows Workstation (e.g. Win10)"
    Write-Host -ForegroundColor Cyan "24 - Optimized for background services (longer, fixed-length processor intervals in which foreground processes and background processes get equal processor priority)"
    Write-Host -ForegroundColor Cyan "38 - Optimized for programs (short, variable length processor intervals in which foreground processes get three times as much processor time as do background processes)"
    Write-Host -ForegroundColor Cyan "https://docs.microsoft.com/en-us/previous-versions//cc976120(v=technet.10)?redirectedfrom=MSDN"

    $ProcesorSchedulingStatus | Select-Object PSComputerName, Win32PrioritySeparation | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}
function Set-CbProcessorScheduling {
    <#
    .SYNOPSIS
        Sets processor schedulling to Programs or Background Services.
    .DESCRIPTION
        The Set-ProcessorScheduling function sets processor scheduling to Programs or Background Services. 
    .PARAMETER ComputerIP
        Specifies the computer IP.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch]$Programs,
        [Parameter(Mandatory = $false)] [switch]$BackgroundServices
    )

    $ActionIndex = Test-CbIfExactlyOneSwitchParameterIsTrue $Programs $BackgroundService
    
    if ($ActionIndex -eq 0) {
        #If Programs switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
            Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation -Value 38
        }
        Write-Host -ForegroundColor Green "`nProcessor scheduling set to PROGRAMS."
        Get-CbProcessorScheduling $ComputerIP $Credential
    }
    elseif ($ActionIndex -eq 1) {
        #If BackgroundService switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
            Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation -Value 24
        }
        Write-Host -ForegroundColor Green "`nProcessor scheduling set to BACKGROUND SERVICES."
        Get-CbProcessorScheduling $ComputerIP $Credential
    }
}

######################
##### POWER PLAN #####
######################
function Get-CbPowerPlan {
    <#
    .SYNOPSIS
       Gets the ACTIVE Power Plan of the server.
    .DESCRIPTION
       The Get-CbPowerPlan function checks the ACTIVE Power Plan of the server.
       The function uses "Get-CimInstance -Namespace root\cimv2\power -ClassName win32_PowerPlan" command.
    .PARAMETER ComputerIP
       Specifies the computer IP.
    .PARAMETER Credentials
       Specifies the credentials used to login.
    .EXAMPLE
       Get-CbPowerPlan -ComputerIP $all -Credential $cred
    #>
    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    $HeaderMessage = "----- Active power plans -----"

    $ScriptBlock = {
        $PowerPlans = Get-CimInstance -Namespace root\cimv2\power -ClassName win32_PowerPlan

        [pscustomobject]@{
            PowerPlan = ($PowerPlans | Where-Object { $_.IsActive -eq $true}).ElementName
        }
    }

    $NullMessage = "Something went wrong retrieving active Power Plans from selected remote hosts"
   
    $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'PowerPlan') 

    $ActionIndex = 0
    
    if ($RawOutput) {
        Invoke-CbScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput
    }
    else {
        Invoke-CbScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex
    }
}
function Set-CbPowerPlan {
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
.PARAMETER ComputerIP
    Specifies the computer IP.
.PARAMETER Credentials
    Specifies the credentials used to login.
.EXAMPLE
    Set-PowerPlan -ComputerIP $all -credential $cred -HighPerformance
#>
    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch] $HighPerformance,
        [Parameter(Mandatory = $false)] [switch] $Balanced,
        [Parameter(Mandatory = $false)] [switch] $PowerSaver,
        [Parameter(Mandatory = $false)] [switch] $AvidOptimized
    )
    $ActionIndex = Test-CbIfExactlyOneSwitchParameterIsTrue $HighPerformance $Balanced $PowerSaver $AvidOptimized 
    
    if ($ActionIndex -eq 0) {
        #If HighPerformance switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
            $HighPerformancePowerPlan = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'High performance'"
            Invoke-CimMethod -InputObject $HighPerformancePowerPlan -MethodName Activate | Out-Null
        }
        Write-Host -ForegroundColor Green "`nPower Plan SET to HIGH PERFORMANCE."
        Get-CbPowerPlan $ComputerIP $Credential
    }
    elseif ($ActionIndex -eq 1) {
        #If Balanced switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
            $BalancedPowerPlan = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'Balanced'"
            Invoke-CimMethod -InputObject $BalancedPowerPlan -MethodName Activate | Out-Null
        }
        Write-Host -ForegroundColor Green "`nPower Plan SET to BALANCED."
        Get-CbPowerPlan $ComputerIP $Credential
    }
    elseif ($ActionIndex -eq 2) {
        #If PowerSaver switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
            $PowerSaverPowerPlan = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'Power saver'"
            Invoke-CimMethod -InputObject $PowerSaverPowerPlan -MethodName Activate | Out-Null
        }
        Write-Host -ForegroundColor Green "`nPower Plan SET to POWER SAVER."
        Get-CbPowerPlan $ComputerIP $Credential
    }
    elseif ($ActionIndex -eq 3) {
        #If AvidOptimized switch was selected
        Write-Host -ForegroundColor Red "`nAvidOptimized power plan is not yet implemented."
        Return
    }

    
}



    
    
    




