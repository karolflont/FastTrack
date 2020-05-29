####################
##### EVENTLOG #####
####################
function Get-AvEventLogErrors {
   ### Get Error events from servers' EventLog
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
   Param(
      [Parameter(Mandatory = $true)] $ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
      [Parameter(Mandatory = $false)] $After,
      [Parameter(Mandatory = $false)] $Before,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )


   if ($After) { $EventLogAfter = Get-Date $After }
   if ($Before) { $EventLogBefore = Get-Date $Before }
   if ($After) {
      if ($Before) {
         $FullEventLogList = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Get-EventLog -LogName System -EntryType Error -After $using:EventLogAfter -Before $using:EventLogBefore }
      }
      else {
         $FullEventLogList = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Get-EventLog -LogName System -EntryType Error -After $using:EventLogAfter }
      }
   }
   elseif ($Before) {
      $FullEventLogList = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Get-EventLog -LogName System -EntryType Error -Before $using:EventLogBefore }
   }
   else {
      $FullEventLogList = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Get-EventLog -LogName System -EntryType Error } 
   }
   
   Write-Host -ForegroundColor Cyan "`nNumber of Error type EventLog entries "

   for ($i = 0; $i -lt $ComputerIP.Count; $i++) {
      $ServerEventLogList = $FullEventLogList | Where-Object PSComputerName -eq $ComputerIP[$i]
      $message = "`nSummary of Error type EventLog entries for " + $ComputerIP[$i]
      Write-Host -ForegroundColor Cyan $message
      $ServerEventLogListSummary = $ServerEventLogList | Group-Object Source | Sort-Object Count -Descending | Select-Object Name, Count
      $EventLogSummaryList = @()
  
      for ($j = 0; $j -lt $ServerEventLogListSummary.Count; $j++) {
         $FirstEvent = ($ServerEventLogList | Where-Object Source -eq $ServerEventLogListSummary.Name[$j] | Sort-Object TimeGenerated)[0]
         $LastEvent = ($ServerEventLogList | Where-Object Source -eq $ServerEventLogListSummary.Name[$j] | Sort-Object TimeGenerated -Descending)[0]
         $OccurenceCount = ($ServerEventLogListSummary | Select-object Count)[$j]

         $EventLogSummary = New-Object -TypeName PSObject
         $EventLogSummary | Add-Member -MemberType NoteProperty -Name Count -Value $OccurenceCount.Count
         $EventLogSummary | Add-Member -MemberType NoteProperty -Name FirstOccurrenceTime -Value $FirstEvent.TimeGenerated
         $EventLogSummary | Add-Member -MemberType NoteProperty -Name LastOccurrenceTime -Value $LastEvent.TimeGenerated
         $EventLogSummary | Add-Member -MemberType NoteProperty -Name PSComputerName -Value $LastEvent.PSComputerName
         $EventLogSummary | Add-Member -MemberType NoteProperty -Name EntryType -Value $LastEvent.EntryType
         $EventLogSummary | Add-Member -MemberType NoteProperty -Name Source -Value $LastEvent.Source
         $EventLogSummary | Add-Member -MemberType NoteProperty -Name EventID -Value $LastEvent.EventID
         $EventLogSummary | Add-Member -MemberType NoteProperty -Name Message -Value $LastEvent.Message

         $EventLogSummaryList += $EventLogSummary
      }
       
      Write-Output $EventLogSummaryList | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
   }
}

######################
##### SW/HW SPEC #####
######################
function Get-AvOSVersion {
   <#
.SYNOPSIS
   Gets detailed OS Version for a server.
.DESCRIPTION
   The Get-AvOSVersion function gets the detailed information about OS Version of a server.
   The function reads specific values from "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion" registry key. The read values are: 
   ProductName, BuildBranch, CurrentMajorVersionNumber, CurrentMinorVersionNumber, ReleaseID, CurrentBuildNumber, UBR and InstallDate.
   Results are sorted by Alias, unless one of the 'SortBy' switches is selected.
.PARAMETER ComputerIP
   Specifies computer IP.
.PARAMETER Credentials
   Specifies credentials used to login.
.PARAMETER Credentials
   Allows sorting by Release ID.
.PARAMETER Credentials
   Allows sorting by Install Date.
.EXAMPLE
   Get-AvOSVersion -ComputerIP $all -Credential $cred
   Get-AvOSVersion -ComputerIP $all -Credential $cred -SortByInstallDate
#>
   param(
      [Parameter(Mandatory = $true)] $ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
      [Parameter(Mandatory = $false)] [switch]$SortByReleaseID,
      [Parameter(Mandatory = $false)] [switch]$SortByInstallDate,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )

   $HeaderMessage = "----- Operating System Version -----"

   $ScriptBlock = { Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName, BuildBranch, CurrentMajorVersionNumber, CurrentMinorVersionNumber, ReleaseID, CurrentBuildNumber, UBR, InstallDate }

   $NullMessage = "Something went wrong retrieving OS Versions from selected remote hosts"
   
   $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'ProductName', 'BuildBranch', 'CurrentMajorVersionNumber', 'CurrentMinorVersionNumber', 'ReleaseId', 'CurrentBuildNumber', 'UBR', 'InstallDate') 

   $ActionIndex = Test-AvIfExactlyOneSwitchParameterIsTrue $SortByAlias $SortByHostnameInConfig $SortByReleaseID $SortByInstallDate
   
   if ($RawOutput) {
        Invoke-AvScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput
    }
    else {
        Invoke-AvScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex
    }
}
function Get-AvHWSpecification {
   <#
   .SYNOPSIS
   Outputs a table summarizing CPU, RAM, C: drive and D: drive (if exists) sizes for a selected hosts.
   .DESCRIPTION
   The Get-AvHWSpecification function uses:
   - Get-WmiObject -Class Win32_Processor
   - Get-WmiObject -Class Win32_physicalmemory
   - Get-Partition -DriveLetter C
   - Get-Partition -DriveLetter D
   .PARAMETER ComputerIP
   Specifies the computer IP.
   .PARAMETER Credentials
   Specifies the credentials used to login.
   .EXAMPLE
   Get-AVHWSpecification -ComputerIP $All -Credential $cred
   #>
   Param(
      [Parameter(Mandatory = $true)] $ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )

   $HeaderMessage = "----- Hardware Specification -----"

   $ScriptBlock = {
      #D partition might not exist, so we have to take it into consideration
      $D_PartitionSize = (Get-Partition -DriveLetter D -ErrorAction SilentlyContinue | Select-Object -Property Size).Size
      if ($null -eq $D_PartitionSize) { $D_PartitionSize = "N/A" }
      else { $D_PartitionSize = [Math]::Round(($D_PartitionSize) / 1GB, 2) }

      [pscustomobject]@{
         NumberOfCores                    = (Get-WmiObject -Class Win32_Processor | Select-Object -Property NumberOfCores).NumberOfCores
         NumberOfLogicalProcessors        = (Get-WmiObject -Class Win32_Processor | Select-Object -Property NumberOfLogicalProcessors).NumberOfLogicalProcessors
         RAM_GB                           = (Get-WmiObject -Class Win32_physicalmemory | Measure-Object -Property Capacity -Sum).Sum/1GB
         C_PartitionSize_GB               = [Math]::Round(((Get-Partition -DriveLetter C | Select-Object -Property Size).Size / 1GB), 2)
         D_PartitionSize_GB               = $D_PartitionSize
      }
   }

   $NullMessage = "Something went wrong retrieving Hardware Specification from selected remote hosts"
   
   $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'NumberOfCores', 'NumberOfLogicalProcessors', 'RAM_GB', 'C_PartitionSize_GB', 'D_PartitionSize_GB') 

   $ActionIndex = 0
   
   if ($RawOutput) {
        Invoke-AvScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput
    }
    else {
        Invoke-AvScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex
    }
}
function Install-AvBGInfo {
   <#
   .SYNOPSIS
      Installs and configures BGInfo on remote hosts.
   .DESCRIPTION
      The Install-BGInfo consists of five steps:
      1) Check if the PathToBGInfoExecutable and PathToBGInfoTemplate are valid
      2) Create the C:\BGInfo folder on remote hosts
      3) Copy the BGInfo executable and template to the C:\BGInfo folder on remote hosts
      4) Create a BGInfo shortcut in C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp folder
      5) Run BGInfo
   .PARAMETER ComputerIP
      Specifies the computer IP.
   .PARAMETER Credentials
      Specifies the credentials used to login.
   .PARAMETER PathToBGInfoExecutable
      Specifies the LOCAL path to the BGInfo executable.
   .PARAMETER PathToBGInfoTemplate
      Specifies the LOCAL path to the BGInfo template.
   .EXAMPLE
      Install-BGInfo -ComputerIP $all_hosts -Credential $Cred -PathToBGInfoExecutable 'C:\AvidInstallers\BGInfo\BGInfo.exe' -PathToBGInfoTemplate 'C:\AvidInstallers\BGInfo\x64Client.bgi'
   #>
   
   Param(
      [Parameter(Mandatory = $true)] $ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
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
   
   #1. Check if the PathToBGInfoExecutable and PathToBGInfoTemplate are valid - cancel installation if not.
   Write-Host -ForegroundColor Cyan "`nChecking if the path to BGInfo executable and template are valid ones. Please wait..."
   if (-not (Test-Path -Path $PathToBGInfoExecutable -PathType leaf)) {
      if (-not (Test-Path -Path $PathToBGInfoTemplate -PathType leaf)) {
         Write-Host -ForegroundColor Red "`nPaths to BGInfo executable and BGInfo tempate are not valid. Exiting..."
         return
      }
      Write-Host -ForegroundColor Red "`nPath to BGInfo executable is not valid. Exiting..."
      return
   }
   elseif (Test-Path -Path $PathToBGInfoExecutable -PathType leaf) {
      if (-not (Test-Path -Path $PathToBGInfoTemplate -PathType leaf)) {
         Write-Host -ForegroundColor Red "`nPath to BGInfo tempate is not valid. Exiting..."
         return
      }
   }
   else {
      Write-Host -ForegroundColor Green "`nPaths are valid. Let's continue..."
   }
   
   #2. Create the C:\BGInfo folders on remote hosts
   Write-Host -ForegroundColor Cyan "`nCreating folder C:\BGInfo on remote hosts. Please wait..."
   Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { New-Item -ItemType 'directory' -Path 'C:\BGInfo' | Out-Null }
   Write-Host -ForegroundColor Green "`nFolder C:\BGInfo SUCCESSFULLY created on selected remote hosts."
   
   #3. Copy the BGInfo executable and template to the local drive of remote hosts
   Write-Host -ForegroundColor Cyan "`nCopying the BGInfo executable and template to remote hosts. Please wait..."
   $ComputerIP | ForEach-Object -Process {
      $Session = New-PSSession -ComputerName $_ -Credential $Credential
      Copy-Item -LiteralPath $PathToBGInfoExecutable -Destination "C:\BGInfo\" -ToSession $Session
      Copy-Item -LiteralPath $PathToBGInfoTemplate -Destination "C:\BGInfo\" -ToSession $Session
   }
   Write-Host -ForegroundColor Green "`nBGInfo Executable and template SUCCESSFULLY copied to selected remote hosts."
   
   #4. Unblock the copied installer (so no "Do you want to run this file?" pop-out hangs the installation in the next step)
   #Write-Host -ForegroundColor Cyan "`nUnblocking copied files. Please wait..."
   #Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {Unblock-File -Path $using:PathToInstallerRemote}
   #Write-Host -ForegroundColor Green "`nall files SUCCESSFULLY unblocked."
   
   #5. Create the GBInfo shortcut in common startup folder
   Write-Host -ForegroundColor Cyan "`nCreating BGInfo autostart and desktop shortcuts on remote hosts. Please wait..."
   Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
      $WshShell = New-Object -comObject WScript.Shell
      $Shortcut = $WshShell.CreateShortcut($using:PathToShortcut)
      $Shortcut.TargetPath = $using:PathToBGInfoExecutableRemote
      $Shortcut.Arguments = $using:BGInfoArguments
      $Shortcut.Save()
      Copy-Item $using:PathToShortcut -Destination "C:\Users\Public\Desktop"
   }
   Write-Host -ForegroundColor Green "`nBGInfo autostart and desktop shortcuts SUCCESFULY created on selected remote hosts."

   #5. Run BGInfo on remote hosts
   Write-Host -ForegroundColor Red "`nPlease use the desktop shortcut on remote hosts to run BGInfo for the first time."
   Write-Host -ForegroundColor Red "Also, remember to add the right BGInfo fields on appropriate hosts."
}
function Get-AvUptime {
   <#
.SYNOPSIS
Outputs uptime for a list of computers.
.DESCRIPTION
The Get-AvUptime function uses "(get-date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime" expression to retrieve uptime of selected hosts.
Timezone set on remote host is irrelevant to uptime calculation.
LastBootUpTime is ALWAYS displayed in the timezone of the machine which is runs Get-AvUptime function.
.PARAMETER ComputerIP
Specifies the computer IP.
.PARAMETER Credentials
Specifies the credentials used to login.
.EXAMPLE
Get-AvUptime -ComputerIP $All -Credential $cred
#>
   Param(
      [Parameter(Mandatory = $true)] $ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )

   $HeaderMessage = "----- Uptime -----"

   $ScriptBlock = {
      $LastBootUpTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
      [pscustomobject]@{
         UpTime_ = ((get-date) - $LastBootUpTime)
         LastBootUpTime = $LastBootUpTime
      }
   }

   $NullMessage = "Something went wrong retrieving Uptime from selected remote hosts"
   
   $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'Uptime', 'LastBootUpTime') 

   $ActionIndex = 0
   
   if ($RawOutput) {
        Invoke-AvScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput
    }
    else {
        Invoke-AvScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -NullMessage $NullMessage -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex
    }
}