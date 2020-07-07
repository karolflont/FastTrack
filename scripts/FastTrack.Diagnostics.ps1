####################
##### EVENTLOG #####
####################
function Get-FtEventLogErrors {
   <#
.SYNOPSIS
    Retrieves the Errors (including Critical Errors) from the remote computers System Event Logs and groups them by EventID.
.DESCRIPTION
   The Get-FtEventLogErrors function:
      - retrieves System Event Logs using Get-EventLog cmdlet
      - groups retrieved logs by EventID, adding information for:
         - the number of occurences of a particular event
         - time of the first occurence of a particular event
         - time of the last occurence of a particular event
      NOTE: Get-FtEventLogErrors function retrieves EventLog System Log ERRORS and CRITICAL ERRORS. None of other levels are retrieved.
.PARAMETER ComputerIP
   Specifies the computer IP.
.PARAMETER Credential
   Specifies the credentials used to login.
.PARAMETER After
   Specifies the start date of System Logs search.
.PARAMETER Before
   Specifies the end date of System Logs search.
.PARAMETER SortByAlias
   Allows sorting by Alias. This is the default sort property, if none of the sort parameters are selected.
.PARAMETER SortByHostnameInConfig
   Allows sorting by Hostname in $SysConfig variable.
.PARAMETER SortByNumberOfOccurences
   Allows sorting by number of occurences of a particular event.
.PARAMETER SortByEventID
   Allows sorting by Event ID.
.PARAMETER RawOutput
   Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
.EXAMPLE
   Get-FtEventLogErrors -ComputerIP $all -Credential $cred
.EXAMPLE
   Get-FtEventLogErrors -ComputerIP $all -Credential $cred -After '23 December 2019 13:53:45'
.EXAMPLE
   Get-FtEventLogErrors -ComputerIP $all -Credential $cred -After '23 December 2019 13:53:45' -Before '4 July 2020 7:10:17' -SortByNumberOfOccurences
#>
   Param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] $After,
      [Parameter(Mandatory = $false)] $Before,
      [Parameter(Mandatory = $false)] [switch]$SortByAlias,
      [Parameter(Mandatory = $false)] [switch]$SortByHostnameInConfig,
      [Parameter(Mandatory = $false)] [switch]$SortByNumberOfOccurences,
      [Parameter(Mandatory = $false)] [switch]$SortByEventID,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )

   $HeaderMessage = "Summary of ERROR type EventLog entries"

   $ScriptBlock = {
      $After = if ($using:After) {Get-Date $using:After}
      $Before = if ($using:Before) {Get-Date $using:Before}
      if ($After -and $Before) {$ServerEventLogList = Get-EventLog -LogName System -EntryType Error -After $After -Before $Before}
      if ($After -and !$Before) {$ServerEventLogList = Get-EventLog -LogName System -EntryType Error -After $After}
      if (!$After -and $Before) {$ServerEventLogList = Get-EventLog -LogName System -EntryType Error -Before $Before}
      if (!$After -and !$Before) {$ServerEventLogList = Get-EventLog -LogName System -EntryType Error}

      $EventLogSummaryList = @()

      if ($null -ne $ServerEventLogList) {
         $ServerEventLogListSummary = @()
         $ServerEventLogListSummary += ($ServerEventLogList | Group-Object Source | Sort-Object Count -Descending | Select-Object Name, Count)
         $ServerEventLogListSummary | Add-Member -MemberType AliasProperty -Name OccurenceCount -Value Count
         
         for ($j = 0; $j -lt $ServerEventLogListSummary.Length; $j++) {
            if ($ServerEventLogListSummary.Length -eq 1) {
               $FirstEvent = ($ServerEventLogList | Where-Object Source -eq $ServerEventLogListSummary.Name | Sort-Object TimeGenerated)[0]
               $LastEvent = ($ServerEventLogList | Where-Object Source -eq $ServerEventLogListSummary.Name | Sort-Object TimeGenerated -Descending)[0]
               $OccurenceCount = ($ServerEventLogListSummary | Select-object OccurenceCount)
            }
            else {
               $FirstEvent = ($ServerEventLogList | Where-Object Source -eq $ServerEventLogListSummary.Name[$j] | Sort-Object TimeGenerated)[0]
               $LastEvent = ($ServerEventLogList | Where-Object Source -eq $ServerEventLogListSummary.Name[$j] | Sort-Object TimeGenerated -Descending)[0]
               $OccurenceCount = ($ServerEventLogListSummary | Select-object OccurenceCount)[$j]
            }

            $EventLogSummary = New-Object -TypeName PSObject
            $EventLogSummary | Add-Member -MemberType NoteProperty -Name NumberOfOccurences -Value $OccurenceCount.OccurenceCount
            $EventLogSummary | Add-Member -MemberType NoteProperty -Name FirstOccurrenceTime -Value $FirstEvent.TimeGenerated
            $EventLogSummary | Add-Member -MemberType NoteProperty -Name LastOccurrenceTime -Value $LastEvent.TimeGenerated
            $EventLogSummary | Add-Member -MemberType NoteProperty -Name Source -Value $LastEvent.Source
            $EventLogSummary | Add-Member -MemberType NoteProperty -Name EventID -Value $LastEvent.EventID
            $EventLogSummary | Add-Member -MemberType NoteProperty -Name Message -Value $LastEvent.Message

            $EventLogSummaryList += $EventLogSummary
         }
      }
      Return $EventLogSummaryList
   }
 
   $ActionIndex = Confirm-FtSwitchParameters $SortByAlias $SortByHostnameInConfig $SortByNumberOfOccurences $false $false $false $SortByEventID -DefaultSwitch 0
 
   $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

   $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'NumberOfOccurences', 'FirstOccurrenceTime', 'LastOccurrenceTime', 'Source', 'EventID', 'Message') 

   if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
   else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}

######################
##### SW/HW SPEC #####
######################
function Get-FtOSVersion {
   <#
.SYNOPSIS
   Gets detailed OS Version for a server.
.DESCRIPTION
   The Get-FtOSVersion function gets the detailed information about OS Version of a server.
   The function reads specific values from "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion" registry key. The read values are: 
   ProductName, BuildBranch, CurrentMajorVersionNumber, CurrentMinorVersionNumber, ReleaseID, CurrentBuildNumber, UBR and InstallDate.
   Results are sorted by Alias, unless one of the 'SortBy' switches is selected.
.PARAMETER ComputerIP
   Specifies computer IP.
.PARAMETER Credential
   Specifies credentials used to login.
.PARAMETER Credential
   Allows sorting by Release ID.
.PARAMETER Credential
   Allows sorting by Install Date.
.PARAMETER RawOutput
   Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
.EXAMPLE
   Get-FtOSVersion -ComputerIP $all -Credential $cred
   Get-FtOSVersion -ComputerIP $all -Credential $cred -SortByInstallDate
#>
   param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] [switch]$SortByReleaseID,
      [Parameter(Mandatory = $false)] [switch]$SortByInstallDate,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )

   $HeaderMessage = "Operating System Version"

   $ScriptBlock = { Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName, BuildBranch, CurrentMajorVersionNumber, CurrentMinorVersionNumber, ReleaseID, CurrentBuildNumber, UBR, InstallDate }
   
   $ActionIndex = Confirm-FtSwitchParameters $SortByAlias $SortByHostnameInConfig $SortByReleaseID $SortByInstallDate -DefaultSwitch 0

   if ($ActionIndex -ne -1) {
      $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

      $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'ProductName', 'BuildBranch', 'CurrentMajorVersionNumber', 'CurrentMinorVersionNumber', 'ReleaseId', 'CurrentBuildNumber', 'UBR', 'InstallDate') 

      if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
      else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
   }
}
function Get-FtHWSpecification {
   <#
   .SYNOPSIS
   Outputs a table summarizing CPU, RAM, C: drive and D: drive (if exists) sizes for a selected hosts.
   .DESCRIPTION
   The Get-FtHWSpecification function uses:
   - Get-WmiObject -Class Win32_Processor
   - Get-WmiObject -Class Win32_physicalmemory
   - Get-Partition -DriveLetter C
   - Get-Partition -DriveLetter D
   .PARAMETER ComputerIP
   Specifies the computer IP.
   .PARAMETER Credential
   Specifies the credentials used to login.
   .PARAMETER RawOutput
   Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
   .EXAMPLE
   Get-FtHWSpecification -ComputerIP $All -Credential $cred
   #>
   Param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )

   $HeaderMessage = "Hardware Specification"

   $ScriptBlock = {
      #D partition might not exist, so we have to take it into consideration
      $D_PartitionSize = (Get-Partition -DriveLetter D -ErrorAction SilentlyContinue | Select-Object -Property Size).Size
      if ($null -eq $D_PartitionSize) { $D_PartitionSize = "N/A" }
      else { $D_PartitionSize = [Math]::Round(($D_PartitionSize) / 1GB, 2) }

      [pscustomobject]@{
         NumberOfCores             = (Get-WmiObject -Class Win32_Processor | Select-Object -Property NumberOfCores).NumberOfCores
         NumberOfLogicalProcessors = (Get-WmiObject -Class Win32_Processor | Select-Object -Property NumberOfLogicalProcessors).NumberOfLogicalProcessors
         RAM_GB                    = (Get-WmiObject -Class Win32_physicalmemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
         C_PartitionSize_GB        = [Math]::Round(((Get-Partition -DriveLetter C | Select-Object -Property Size).Size / 1GB), 2)
         D_PartitionSize_GB        = $D_PartitionSize
      }
   }

   $ActionIndex = 0
   
   $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

   $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'NumberOfCores', 'NumberOfLogicalProcessors', 'RAM_GB', 'C_PartitionSize_GB', 'D_PartitionSize_GB') 
   
   if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
   else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}
function Install-FtBGInfo {
   <#
   .SYNOPSIS
      Installs and configures BGInfo on remote hosts.
   .DESCRIPTION
      The Install-BGInfo consists of five steps:
      1) Check if the PathToBGInfoExecutable and PathToBGInfoTemplate are valid
      2) Create the C:\BGInfo folder on remote hosts
      3) Copy the BGInfo executable and template to the C:\BGInfo folder on remote hosts
      4) Create a BGInfo shortcut in C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp folder and on the desktop
      5) Print next steps information
   .PARAMETER ComputerIP
      Specifies the computer IP.
   .PARAMETER Credential
      Specifies the credentials used to login.
   .PARAMETER PathToBGInfoExecutable
      Specifies the LOCAL path to the BGInfo executable.
   .PARAMETER PathToBGInfoTemplate
      Specifies the LOCAL path to the BGInfo template.
   .EXAMPLE
      Install-FtBGInfo -ComputerIP $ie -Credential $cred -PathToBGInfoExecutable 'C:\AvidInstallers\BGInfo\BGInfo.exe' -PathToBGInfoTemplate 'C:\AvidInstallers\BGInfo\x64Client.bgi'
   #>
   
   Param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $true)] $PathToBGInfoExecutable,
      [Parameter(Mandatory = $true)] $PathToBGInfoTemplate
   )

   $BGInfoExecutableFileName = Split-Path $PathToBGInfoExecutable -leaf
   $BGInfoTemplateFilename = Split-Path $PathToBGInfoTemplate -leaf

   $DestinationFolder = "C:\BGInfo\"
   $PathToBGInfoExecutableRemote = $DestinationFolder + $BGInfoExecutableFileName
   $PathToBGInfoTemplateRemote = $DestinationFolder + $BGInfoTemplateFilename
   $PathToShortcut = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\BGInfo.lnk"
   $BGInfoArguments = $PathToBGInfoTemplateRemote + " /NOLICPROMPT /TIMER:0"
   
   #1a. Check if the $PathToBGInfoExecutable is valid - cancel installation if not.
   Write-Host -ForegroundColor Cyan "`Checking the path to BGInfo executable..." -NoNewline
   if (-not (Test-Path -Path $PathToBGInfoExecutable -PathType leaf)) {
      Write-Host -ForegroundColor Red "NOT VALID"
      Write-Host -ForegroundColor Red "Please check the path to BGInfo executable on your local computer."
      Return
   }
   else {
      Write-Host -ForegroundColor Green "VALID"
   }

   #1b. Check if the $PathToBGInfoETemplate is valid - cancel installation if not.
   Write-Host -ForegroundColor Cyan "`Checking the path to BGInfo template..." -NoNewline
   if (-not (Test-Path -Path $PathToBGInfoTemplate -PathType leaf)) {
      Write-Host -ForegroundColor Red "NOT VALID"
      Write-Host -ForegroundColor Red "Please check the path to BGInfo template on your local computer."
      Return
   }
   else {
      Write-Host -ForegroundColor Green "VALID"
   }
   
   #2. Create the C:\BGInfo on remote hosts
   Write-Host -ForegroundColor Cyan "Creating folder C:\BGInfo on remote hosts... " -NoNewline
   Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { New-Item -ItemType 'directory' -Path 'C:\BGInfo' | Out-Null }
   Write-Host -ForegroundColor Green "DONE"

   #3a. Copy BGInfo executable and template to the local drive of the remote hosts
   Write-Host -ForegroundColor Cyan "Copying BGInfo executable and template to remote hosts... " -NoNewline
   $ComputerIP | ForEach-Object -Process {
      $Session = New-PSSession -ComputerName $_ -Credential $Credential
      Copy-Item -LiteralPath $PathToBGInfoExecutable -Destination "C:\BGInfo" -ToSession $Session
      Copy-Item -LiteralPath $PathToBGInfoTemplate -Destination "C:\BGInfo" -ToSession $Session
   }
   Write-Host -ForegroundColor Green "DONE"
   
   #4. Create BGInfo shortcut in common startup folder
   Write-Host -ForegroundColor Cyan "Creating BGInfo autostart and desktop shortcuts on remote hosts..." -NoNewline
   Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
      $WshShell = New-Object -comObject WScript.Shell
      $Shortcut = $WshShell.CreateShortcut($using:PathToShortcut)
      $Shortcut.TargetPath = $using:PathToBGInfoExecutableRemote
      $Shortcut.Arguments = $using:BGInfoArguments
      $Shortcut.Save()
      Copy-Item $using:PathToShortcut -Destination "C:\Users\Public\Desktop"
   }
   Write-Host -ForegroundColor Green "DONE"

   #5. Run BGInfo on remote hosts
   Write-Warning "Please use the desktop shortcut on remote hosts to run BGInfo for the first time. Also, modify the used template appropriately."
}

function Get-FtUptime {
   <#
.SYNOPSIS
Outputs uptime for a list of computers.
.DESCRIPTION
The Get-FtUptime function uses "(get-date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime" expression to retrieve uptime of selected hosts.
Timezone set on remote host is irrelevant to uptime calculation.
LastBootUpTime is ALWAYS displayed in the timezone of the machine which is runs Get-FtUptime function.
.PARAMETER ComputerIP
Specifies the computer IP.
.PARAMETER Credential
Specifies the credentials used to login.
.PARAMETER RawOutput
Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
.EXAMPLE
Get-FtUptime -ComputerIP $All -Credential $cred
#>
   Param(
      [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )
   
   $HeaderMessage = "Uptime"

   $ScriptBlock = {
      $LastBootUpTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
      $UpTime = ((get-date) - $LastBootUpTime)
      [pscustomobject]@{
         UpTimeTotalDays  = [math]::Round($Uptime.TotalDays, 2)
         UpTimeTotalHours = [math]::Round($UpTime.TotalHours, 2)
         UpTimeTotalMin   = [math]::Round($UpTime.TotalMinutes, 2)
         LastBootUpTime   = $LastBootUpTime
      }
   }
   
   $ActionIndex = 0
   
   $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

   $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'UpTimeTotalDays', 'UpTimeTotalHours', 'UpTimeTotalMin', 'LastBootUpTime') 

   if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
   else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}