#################################################
##### SHOW HIDDEN FILES, FOLDERS AND DRIVES #####
#################################################
# This is the equivalent of Folder Menu -> Tools -> Folder Options -> View -> Advanced settings -> Show hidden files, folders and drives

function Get-HiddenFilesAndFoldersStatus($ComputerName,[System.Management.Automation.PSCredential] $Credential){
    ### Get "Show hidden files, folders and drives" option status
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
    $HiddenFilesAndFoldersStatus = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden"}
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue " `n SHOW HIDDEN FILES, FOLDERS AND DRIVES STATUS"
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue " 1 - Hidden files, folders and drives SHOWN  "
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue " 2 - Hidden files, folders and drives HIDDEN "
    $HiddenFilesAndFoldersStatus | Select-Object PSComputerName, Hidden | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}
function Set-HiddenFilesAndFolders($ComputerName,[System.Management.Automation.PSCredential] $Credential, [switch]$Show, [switch]$Hide){
    <#
    .SYNOPSIS
        Shows or hides hidden files and folders.
    .DESCRIPTION
        The Set-HiddenFilesAndFolders function shows or hides hidden files and folders.

        The function sets the value of "Hidden" value in "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" key.
        NOTE: This function restarts Explorer process if it is running (server has a GUI and somebody is logged on). This is necessary for this registry settings change to work.
    .PARAMETER ComputerName
        Specifies the computer name.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .EXAMPLE
        TODO
    #>
    
    Write-Host -BackgroundColor White -ForegroundColor Red "`n WARNING: This will restart the explorer.exe process on all hosts after changing the parameter. "
    Write-Host -BackgroundColor White -ForegroundColor Red "This means ALL your opened folders will be closed and ongoing copy processes will also be stopped. Press Enter to continue or Ctrl+C to quit. "
    [void](Read-Host)

    if ($Show) {
        if ($Hide) {
            Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONLY ONE of the -Show/-Hide switch parameters. "
        Return
        }
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
            Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value "1"
            if (Get-Process explorer -ErrorAction SilentlyContinue){
                Stop-Process -ProcessName explorer -Force
            }
        }
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Hidden files and folders SHOWN. "
    }
    elseif ($Hide) {
        if ($Show) {
            Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONLY ONE of the -Show/-Hide switch parameters. "
            Return
        }
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
            Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value "2"
            if (Get-Process explorer -ErrorAction SilentlyContinue){
                Stop-Process -ProcessName explorer -Force
            }
        }
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Hidden files and folders HIDDEN. "
    }
    else {
        Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONE of the -Show/-Hide switch parameters. "
        Return
    }

    Get-HiddenFilesAndFoldersStatus $ComputerName $Credential
}

#############################################
### DISABLE SERVER MANAGER START AT LOGON ###
#############################################
function Get-ServerManagerAtLogonStatus($ComputerName,[System.Management.Automation.PSCredential] $Credential){
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
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue " `n Server Manager Start At Logon Status"
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-ScheduledTask -TaskName ServerManager}
    #To disable use
    #Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose
    
}


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
function Get-UACLevel($ComputerName,[System.Management.Automation.PSCredential] $Credential){
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
function Disable-UAC($ComputerName,[System.Management.Automation.PSCredential] $Credential){
### Set UAC level to "Never notify me"
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value "0"}
}


################################
##### PROCESSOR SCHEDULING #####
################################


function Get-ProcessorScheduling($ComputerName,[System.Management.Automation.PSCredential] $Credential){
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
    $ProcesorSchedulingStatus = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
        Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation
    }
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Processor scheduling status: 38 - programs; 0(default) or 24 - background services "
    $ProcesorSchedulingStatus | Select-Object PSComputerName, Win32PrioritySeparation | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}

function Set-ProcessorScheduling($ComputerName,[System.Management.Automation.PSCredential] $Credential, [switch]$Programs, [switch]$BackgroundServices){
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
    if ($Programs) {
        if ($BackgroundServices) {
            Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONLY ONE of the -Programs/-BackgroundServices switch parameters. "
        Return
        }
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
            Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation -Value 38
        }
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Processor scheduling set to PROGRAMS. "
    }
    elseif ($BackgroundServices) {
        if ($Programs) {
            Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONLY ONE of the -Programs/-BackgroundServices switch parameters. "
            Return
        }
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
            Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl -Name Win32PrioritySeparation -Value 24
        }
        Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Processor scheduling set to BACKGROUND SERVICES. "
    }
    else {
        Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONE of the -Programs/-BackgroundServices switch parameters. "
        Return
    }

    Get-ProcessorScheduling $ComputerName $Credential
}


#####################
##### AUTOLOGON #####
#####################

function Get-AutologonStatus($ComputerName,[System.Management.Automation.PSCredential] $Credential){
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
    
    function Set-Autologon($ComputerName,[System.Management.Automation.PSCredential] $Credential, [switch]$Enable, [switch]$Disable){
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
function Get-KeyboardLayout($ComputerName,[System.Management.Automation.PSCredential] $Credential){
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
function Set-KeyboardLayout($ComputerName,[System.Management.Automation.PSCredential] $Credential){
    ### Set keyboard layout to en-US
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-WinDefaultInputMethodOverride -InputTip "0409:00000409"}
}


######################
##### POWER PLAN #####
######################

function Get-PowerPlan($ComputerName,[System.Management.Automation.PSCredential] $Credential){
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
    $PowerPlan = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-CimInstance -Namespace root\cimv2\power -ClassName win32_PowerPlan}
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Active Power Plan "
    $PowerPlan | Where-Object {$_.IsActive -eq $True} | Select-Object PSComputerName, ElementName | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}

function Set-PowerPlanToHighPerformance($ComputerName,[System.Management.Automation.PSCredential] $Credential){
    <#
    .SYNOPSIS
       Sets the ACTIVE Power Plan of the server to HIGH PERFORMANCE.
    .DESCRIPTION
       The Set-PowerPlan function sets the ACTIVE Power Plan of the server to HIGH PERFORMANCE.

       The function uses Get-CimInstance and Invoke-CimMethod cmdlets.
    .PARAMETER ComputerName
       Specifies the computer name.
    .PARAMETER Credentials
       Specifies the credentials used to login.
    .EXAMPLE
       TODO
    #>
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
        $HighPerformancePowerPlan = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'High Performance'"
        Invoke-CimMethod -InputObject $HighPerformancePowerPlan -MethodName Activate | Out-Null
    }
    Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Power Plan SET to HIGH PERFORMANCE. "
    Get-PowerPlan $ComputerName $Credential
}

    
    
    





