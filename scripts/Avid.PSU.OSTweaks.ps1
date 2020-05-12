#############################################
### DISABLE SERVER MANAGER START AT LOGON ###
#############################################
function Get-AvServerManagerBehaviorAtLogon{
<#
.SYNOPSIS
   TODO
.DESCRIPTION
   TODO
.PARAMETER ComputerIP
   Specifies the computer name.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   TODO
#>
param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )

    Write-Host -ForegroundColor Cyan  " `n Server Manager Behavior At Logon"
    Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Get-ScheduledTask -TaskName ServerManager}
}
function Set-AvServerManagerBehaviorAtLogon{
<#
.SYNOPSIS
    TODO
.DESCRIPTION
    TODO
.PARAMETER ComputerIP
    Specifies the computer name.
.PARAMETER Credentials
    Specifies the credentials used to login.
.EXAMPLE
    TODO
#>
param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $false)] [switch] $Enable,
        [Parameter(Mandatory = $false)] [switch] $Disable
    )

    $ActionIndex = Test-AvIfExactlyOneSwitchParameterIsTrue $Enable $Disable

    if ($ActionIndex -eq 0){
        #If Enable switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Get-ScheduledTask -TaskName ServerManager | Enable-ScheduledTask}
        Write-Host -ForegroundColor Green "`n Server Manager Start At Logon ENABLED for all remote hosts."
    }
    elseif ($ActionIndex -eq 1){
        #If Disable switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask}
        Write-Host -ForegroundColor Green "`n Server Manager Start At Logon DISABLED for all remote hosts."
    } 
}

###############
##### UAC #####
###############
function Get-AvUACLevel{
<#
.SYNOPSIS
   TODO
.DESCRIPTION
   TODO
.PARAMETER ComputerIP
   Specifies the computer name.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   TODO
#>
param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )

    ### Check UAC level - Windows Server 2016 only!!!
    # https://gallery.technet.microsoft.com/scriptcenter/Disable-UAC-using-730b6ecd#content
    $UACLevel = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin"}
    Write-Host -ForegroundColor Cyan "`nUAC Level                                                       "
    Write-Host -ForegroundColor Cyan "2 - Always notify me                                            "
    Write-Host -ForegroundColor Cyan "5 - Notify me only when apps try to make changes to my computer "
    Write-Host -ForegroundColor Cyan "0 - Never notify me                                             "
    $UACLevel | Select-Object PSComputerName, ConsentPromptBehaviorAdmin | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}
function Set-AvUACLevel{
<#
.SYNOPSIS
   TODO
.DESCRIPTION
   TODO
.PARAMETER ComputerIP
   Specifies the computer name.
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

    $ActionIndex = Test-AvIfExactlyOneSwitchParameterIsTrue $AlwaysNotify $NotifyWhenAppsMakeChangesToComputer $NeverNotify
    
    if ($ActionIndex -eq 0){
        #If AlwaysNotify switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "2"}
        Write-Host -ForegroundColor Green "`nUAC Level changed to `"Always notify me`" for all hosts. "
        Get-AvUACLevel $ComputerIP $Credential
    }
    elseif ($ActionIndex -eq 1){
        #If NotifyWhenAppsMakeChangesToComputer switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "5"}
        Write-Host -ForegroundColor Green "`nUAC Level changed to `"Notify me only when apps try to make changes to my computer`" for all hosts. "
        Get-AvUACLevel $ComputerIP $Credential
    }
    elseif ($ActionIndex -eq 2){
        #If NeverNotify switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "0"}
        Write-Host -ForegroundColor Green "`nUAC Level changed to `"Never notify me`" for all hosts. "
        Get-AvUACLevel $ComputerIP $Credential
    }
}
################################
##### PROCESSOR SCHEDULING #####
################################
function Get-AvProcessorScheduling{
    <#
    .SYNOPSIS
        Gets the Processor Scheduling setting: programs or background services
    .DESCRIPTION
        TODO
    .PARAMETER ComputerIP
        Specifies the computer name.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )

    $ProcesorSchedulingStatus = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock{
        Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation
    }
    Write-Host -ForegroundColor Cyan "`nProcessor scheduling status:"
    Write-Host -ForegroundColor Cyan "2 - Default value. Optimized for background services on Windows Server and for programs on Windows Workstation (e.g. Win10)"
    Write-Host -ForegroundColor Cyan "24 - Optimized for background services (longer, fixed-length processor intervals in which foreground processes and background processes get equal processor priority)"
    Write-Host -ForegroundColor Cyan "38 - Optimized for programs (short, variable length processor intervals in which foreground processes get three times as much processor time as do background processes)"
    Write-Host -ForegroundColor Cyan "https://docs.microsoft.com/en-us/previous-versions//cc976120(v=technet.10)?redirectedfrom=MSDN"

    $ProcesorSchedulingStatus | Select-Object PSComputerName, Win32PrioritySeparation | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}
function Set-AvProcessorScheduling{
    <#
    .SYNOPSIS
        Sets processor schedulling to Programs or Background Services.
    .DESCRIPTION
        The Set-ProcessorScheduling function sets processor scheduling to Programs or Background Services. 
    .PARAMETER ComputerIP
        Specifies the computer name.
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

    $ActionIndex = Test-AvIfExactlyOneSwitchParameterIsTrue $Programs $BackgroundService
    
    if ($ActionIndex -eq 0){
        #If Programs switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock{
            Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation -Value 38
        }
        Write-Host -ForegroundColor Green "`nProcessor scheduling set to PROGRAMS. "
        Get-AvProcessorScheduling $ComputerIP $Credential
    }
    elseif ($ActionIndex -eq 1){
        #If BackgroundService switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock{
            Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation -Value 24
        }
        Write-Host -ForegroundColor Green "`nProcessor scheduling set to BACKGROUND SERVICES. "
        Get-AvProcessorScheduling $ComputerIP $Credential
    }
}

######################
##### POWER PLAN #####
######################
function Get-AvPowerPlan{
    <#
    .SYNOPSIS
       Gets the ACTIVE Power Plan of the server.
    .DESCRIPTION
       The Get-AvPowerPlan function gets the ACTIVE Power Plan of the server.

       The function uses Get-CimInstance cmdlet.
    .PARAMETER ComputerIP
       Specifies the computer name.
    .PARAMETER Credentials
       Specifies the credentials used to login.
    .EXAMPLE
       TODO
    #>
    param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )

    $PowerPlan = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Get-CimInstance -Namespace root\cimv2\power -ClassName win32_PowerPlan}
    Write-Host -ForegroundColor Cyan "`nActive Power Plan "
    $PowerPlan | Where-Object {$_.IsActive -eq $True} | Select-Object PSComputerName, ElementName | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}
function Set-AvPowerPlan{
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
    Specifies the computer name.
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
    $ActionIndex = Test-AvIfExactlyOneSwitchParameterIsTrue $HighPerformance $Balanced $PowerSaver $AvidOptimized 
    
    if ($ActionIndex -eq 0){
        #If HighPerformance switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock{
            $HighPerformancePowerPlan = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'High performance'"
            Invoke-CimMethod -InputObject $HighPerformancePowerPlan -MethodName Activate | Out-Null
        }
        Write-Host -ForegroundColor Green "`nPower Plan SET to HIGH PERFORMANCE. "
        Get-AvPowerPlan $ComputerIP $Credential
    }
    elseif ($ActionIndex -eq 1){
        #If Balanced switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock{
            $BalancedPowerPlan = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'Balanced'"
            Invoke-CimMethod -InputObject $BalancedPowerPlan -MethodName Activate | Out-Null
        }
        Write-Host -ForegroundColor Green "`nPower Plan SET to BALANCED. "
        Get-AvPowerPlan $ComputerIP $Credential
    }
    elseif ($ActionIndex -eq 2){
        #If PowerSaver switch was selected
        Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock{
            $PowerSaverPowerPlan = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'Power saver'"
            Invoke-CimMethod -InputObject $PowerSaverPowerPlan -MethodName Activate | Out-Null
        }
        Write-Host -ForegroundColor Green "`nPower Plan SET to POWER SAVER. "
        Get-AvPowerPlan $ComputerIP $Credential
    }
    elseif ($ActionIndex -eq 3){
        #If AvidOptimized switch was selected
        Write-Host -ForegroundColor Red "`nAvidOptimized power plan is not yet implemented. "
        Return
    }

    
}



    
    
    





