####################
##### EVENTLOG #####
####################
function Get-AvEventLogErrors{
   ### Get Error events from servers' EventLog
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
Param(
       [Parameter(Mandatory = $true)] $ComputerName,
       [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
       [Parameter(Mandatory = $false)] $After,
       [Parameter(Mandatory = $false)] $Before
   )


   if ($After) {$EventLogAfter = Get-Date $After}
   if ($Before) {$EventLogBefore = Get-Date $Before}
   if ($After){
       if ($Before){
           $FullEventLogList = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-EventLog -LogName System -EntryType Error -After $using:EventLogAfter -Before $using:EventLogBefore}
       }
       else {
           $FullEventLogList = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-EventLog -LogName System -EntryType Error -After $using:EventLogAfter}
       }
   }
   elseif ($Before){
       $FullEventLogList = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-EventLog -LogName System -EntryType Error -Before $using:EventLogBefore}
   }
   else {
      $FullEventLogList = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-EventLog -LogName System -EntryType Error} 
   }
   
   Write-Host -ForegroundColor Cyan "`nNumber of Error type EventLog entries "

   for ($i=0; $i -lt $ComputerName.Count; $i++){
       $ServerEventLogList = $FullEventLogList | Where-Object PSComputerName -eq $ComputerName[$i]
       $message = "`nSummary of Error type EventLog entries for " + $ComputerName[$i]
       Write-Host -ForegroundColor Cyan $message
       $ServerEventLogListSummary = $ServerEventLogList | Group-Object Source | Sort-Object Count -Descending | Select-Object Name, Count
       $EventLogSummaryList = @()
  
       for ($j=0; $j -lt $ServerEventLogListSummary.Count; $j++){
           $FirstEvent = ($ServerEventLogList | Where-Object Source -eq $ServerEventLogListSummary.Name[$j] | Sort-Object TimeGenerated)[0]
           $LastEvent = ($ServerEventLogList | Where-Object Source -eq $ServerEventLogListSummary.Name[$j] | Sort-Object TimeGenerated -Descending)[0]
           $OccurenceCount = ($ServerEventLogListSummary | Select-object Count)[$j]

           $EventLogSummary = New-Object -TypeName PSObject
           $EventLogSummary| Add-Member -MemberType NoteProperty -Name Count -Value $OccurenceCount.Count
           $EventLogSummary| Add-Member -MemberType NoteProperty -Name FirstOccurrenceTime -Value $FirstEvent.TimeGenerated
           $EventLogSummary| Add-Member -MemberType NoteProperty -Name LastOccurrenceTime -Value $LastEvent.TimeGenerated
           $EventLogSummary| Add-Member -MemberType NoteProperty -Name PSComputerName -Value $LastEvent.PSComputerName
           $EventLogSummary| Add-Member -MemberType NoteProperty -Name EntryType -Value $LastEvent.EntryType
           $EventLogSummary| Add-Member -MemberType NoteProperty -Name Source -Value $LastEvent.Source
           $EventLogSummary| Add-Member -MemberType NoteProperty -Name EventID -Value $LastEvent.EventID
           $EventLogSummary| Add-Member -MemberType NoteProperty -Name Message -Value $LastEvent.Message

           $EventLogSummaryList += $EventLogSummary
       }
       
       Write-Output $EventLogSummaryList | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
   }
}
function Invoke-AvCollectInSilentMode{
}
function New-AvSystemCheck{
}

######################
##### OS VERSION #####
######################
function Get-AvOSVersion{
<#
.SYNOPSIS
   Gets detailed OS Version for a server.
.DESCRIPTION
   The Get-AvOSVersion function gets the detailed information about OS Version of a server.

   The function reads specific values from "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion" registry key. The read values are: 
   ProductName, BuildBranch, CurrentMajorVersionNumber, CurrentMinorVersionNumber, ReleaseID, CurrentBuildNumber, UBR and InstallDate.
.PARAMETER ComputerName
   Specifies the computer name.
.PARAMETER Credentials
   Specifies the credentials used to login.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )

    $OSVersion = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {(Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName, BuildBranch, CurrentMajorVersionNumber, CurrentMinorVersionNumber, ReleaseID, CurrentBuildNumber, UBR, InstallDate)}
    Write-Host -ForegroundColor Cyan "`nOS Version `n"
    $OSVersion | Select-Object PSComputerName, ProductName, BuildBranch, CurrentMajorVersionNumber, CurrentMinorVersionNumber, ReleaseID, CurrentBuildNumber, UBR, InstallDate | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize

}
function Get-AvHWSpecification{
   <#
   .SYNOPSIS
   Outputs a table smamrizing CPU, RAM and C: drive size for a list of computers.
   .DESCRIPTION
   The Get-AvHWSpecification function uses:
   - Get-WmiObject -Class Win32_Processor
   - Get-WmiObject -Class Win32_physicalmemory
   - Get-Partition -DriveLetter C
   - Get-Partition -DriveLetter D
   .PARAMETER ComputerIP
   Specifies the computer name.
   .PARAMETER Credentials
   Specifies the credentials used to login.
   .EXAMPLE
   #>
   Param(
      [Parameter(Mandatory = $true)] $ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
   )

   $HWSpecification = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
      [pscustomobject]@{HostnameSetOnHost = $env:computername
         NumberOfCores = (Get-WmiObject -Class Win32_Processor | Select-Object -Property NumberOfCores).NumberOfCores
         NumberOfLogicalProcessors = (Get-WmiObject -Class Win32_Processor | Select-Object -Property NumberOfLogicalProcessors).NumberOfLogicalProcessors
                              RAM = (Get-WmiObject -Class Win32_physicalmemory | Measure-Object -Property Capacity -Sum).Sum
                              C_PartitionSize = (Get-Partition -DriveLetter C | Select-Object -Property Size).Size
                              D_PartitionSize = (Get-Partition -DriveLetter D -ErrorAction SilentlyContinue | Select-Object -Property Size).Size}
   }

   $HWSpecification | Select-Object -Property @{Name = "ComputerIP" ; Expression = {$_.PSComputerName} },
                                                                     HostnameSetOnHost,
                                                                     NumberOfCores,
                                                                     NumberOfLogicalProcessors,
                                                                     @{Name = "RAM(GB)" ; Expression = {$_.RAM/1GB} },
                                                                     @{Name = "C_PartitionSize(GB)" ; Expression = {[Math]::Round(($_.C_PartitionSize / 1GB),2)} }, 
                                                                     @{Name = "D_PartitionSize(GB)" ; Expression = {
                                                                        if ($null -eq $_.D_PartitionSize) {$result = "N/A"}
                                                                        else {$result = [Math]::Round(($_.D_PartitionSize / 1GB),2)}
                                                                        $result}} `
                                                                     | Sort-Object -Property ComputerIP | Format-Table -Wrap -AutoSize
}
function Install-AvBGInfo{
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
   .PARAMETER ComputerName
      Specifies the computer name.
   .PARAMETER Credentials
      Specifies the credentials used to login.
   .PARAMETER PathToBGInfoExecutable
      Specifies the LOCAL path to the BGInfo executable.
   .PARAMETER PathToBGInfoTemplate
      Specifies the LOCAL path to the BGInfo template.
   .EXAMPLE
      Install-BGInfo -ComputerName $all_hosts -Credential $Cred -PathToBGInfoExecutable 'C:\AvidInstallers\BGInfo\BGInfo.exe' -PathToBGInfoTemplate 'C:\AvidInstallers\BGInfo\x64Client.bgi'
   #>
   
   Param(
       [Parameter(Mandatory = $true)] $ComputerName,
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
   Write-Host -ForegroundColor Cyan "`nChecking if the path to BGInfo executable and template are valid ones. Please wait... "
   if (-not (Test-Path -Path $PathToBGInfoExecutable -PathType leaf)){
      if (-not (Test-Path -Path $PathToBGInfoTemplate -PathType leaf)){
         Write-Host -ForegroundColor Red "`nPaths to BGInfo executable and BGInfo tempate are not valid. Exiting... "
         return
      }
      Write-Host -ForegroundColor Red "`nPath to BGInfo executable is not valid. Exiting... "
      return
   }
   elseif (Test-Path -Path $PathToBGInfoExecutable -PathType leaf){
      if (-not (Test-Path -Path $PathToBGInfoTemplate -PathType leaf)){
         Write-Host -ForegroundColor Red "`nPath to BGInfo tempate is not valid. Exiting... "
         return
      }
   }
   else {
       Write-Host -ForegroundColor Green "`nPaths are valid. Let's continue... "
   }
   
   #2. Create the C:\BGInfo folders on remote hosts
   Write-Host -ForegroundColor Cyan "`nCreating folder C:\BGInfo on remote hosts. Please wait... "
   Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {New-Item -ItemType 'directory' -Path 'C:\BGInfo' | Out-Null}
   Write-Host -ForegroundColor Green "`nFolder C:\BGInfo SUCCESSFULLY created on all remote hosts. "
   
   #3. Copy the BGInfo executable and template to the local drive of remote hosts
   Write-Host -ForegroundColor Cyan "`nCopying the BGInfo executable and template to remote hosts. Please wait... "
   $ComputerName | ForEach-Object -Process {
       $Session = New-PSSession -ComputerName $_ -Credential $Credential
       Copy-Item -LiteralPath $PathToBGInfoExecutable -Destination "C:\BGInfo\" -ToSession $Session
       Copy-Item -LiteralPath $PathToBGInfoTemplate -Destination "C:\BGInfo\" -ToSession $Session
   }
   Write-Host -ForegroundColor Green "`nBGInfo Executable and template SUCCESSFULLY copied to all remote hosts. "
   
   #4. Unblock the copied installer (so no "Do you want to run this file?" pop-out hangs the installation in the next step)
   #Write-Host -ForegroundColor Cyan "`nUnblocking copied files. Please wait... "
   #Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Unblock-File -Path $using:PathToInstallerRemote}
   #Write-Host -ForegroundColor Green "`nall files SUCCESSFULLY unblocked. "
   
   #5. Create the GBInfo shortcut in common startup folder
   Write-Host -ForegroundColor Cyan "`nCreating BGInfo autostart and desktop shortcuts on remote hosts. Please wait... "
   Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
      $WshShell = New-Object -comObject WScript.Shell
      $Shortcut = $WshShell.CreateShortcut($using:PathToShortcut)
      $Shortcut.TargetPath = $using:PathToBGInfoExecutableRemote
      $Shortcut.Arguments = $using:BGInfoArguments
      $Shortcut.Save()
      Copy-Item $using:PathToShortcut -Destination "C:\Users\Public\Desktop"
   }
   Write-Host -ForegroundColor Green "`nBGInfo autostart and desktop shortcuts SUCCESFULY created on all remote hosts. "

   #5. Run BGInfo on remote hosts
   Write-Host -ForegroundColor Red "`nPlease use the desktop shortcut on remote hosts to run BGInfo for the first time. "
   Write-Host -ForegroundColor Red "Also, remember to add the right BGInfo fields on appropriate hosts. "
}
function Get-AvUptime{
<#
.SYNOPSIS
Outputs ptime for a list of computers.
.DESCRIPTION
The Get-AvUptime function uses:
- Get-WmiObject -Class Win32_Processor
- Get-WmiObject -Class Win32_physicalmemory
- Get-Partition -DriveLetter C
- Get-Partition -DriveLetter D
.PARAMETER ComputerIP
Specifies the computer name.
.PARAMETER Credentials
Specifies the credentials used to login.
.EXAMPLE
#>
Param(
   [Parameter(Mandatory = $true)] $ComputerIP,
   [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
)

$Uptime = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
   $LastBootUptime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
   [pscustomobject]@{HostnameSetOnHost = $env:computername
      LastBootUpTime = $LastBootUptime
   }
}
$Uptime | Select-Object -Property @{Name = "ComputerIP" ; Expression = {$_.PSComputerName} },
                                                                  HostnameSetOnHost,
                                                                  @{Name = "LastBootUpTimeInYourComputerTimezone" ; Expression = {$_.LastBootUpTime} },
                                                                  @{Name = "Uptime" ; Expression = {(get-date) - $_.LastBootUpTime} } `
                                                                  | Sort-Object -Property ComputerIP | Format-Table -Wrap -AutoSize
}