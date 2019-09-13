######################
##### OS VERSION #####
######################

function Get-APSUOSVersion($ComputerName,[System.Management.Automation.PSCredential] $Credential){
<#
.SYNOPSIS
   Gets detailed OS Version for a server.
.DESCRIPTION
   The Get-APSUOSVersion function gets the detailed information about OS Version of a server.

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

    $OSVersion = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {(Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName, BuildBranch, CurrentMajorVersionNumber, CurrentMinorVersionNumber, ReleaseID, CurrentBuildNumber, UBR, InstallDate)}
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n OS Version `n"
    $OSVersion | Select-Object PSComputerName, ProductName, BuildBranch, CurrentMajorVersionNumber, CurrentMinorVersionNumber, ReleaseID, CurrentBuildNumber, UBR, InstallDate | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize

}


function Push-APSUBGInfo(){
   <#
   .SYNOPSIS
      Pushes and configures BGInfo on remote hosts.
   .DESCRIPTION
      The Push-APSUBGInfo consists of five steps:
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
      Push-APSUBGInfo -ComputerName $all_hosts -Credential $Cred -PathToBGInfoExecutable 'C:\AvidInstallers\BGInfo\BGInfo.exe' -PathToBGInfoTemplate 'C:\AvidInstallers\BGInfo\x64Client.bgi'
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
   Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Checking if the path to BGInfo executable and template are valid ones. Please wait... "
   if (-not (Test-Path -Path $PathToBGInfoExecutable -PathType leaf)){
      if (-not (Test-Path -Path $PathToBGInfoTemplate -PathType leaf)){
         Write-Host -BackgroundColor White -ForegroundColor Red "`n Paths to BGInfo executable and BGInfo tempate are not valid. Exiting... "
         return
      }
      Write-Host -BackgroundColor White -ForegroundColor Red "`n Path to BGInfo executable is not valid. Exiting... "
      return
   }
   elseif (Test-Path -Path $PathToBGInfoExecutable -PathType leaf){
      if (-not (Test-Path -Path $PathToBGInfoTemplate -PathType leaf)){
         Write-Host -BackgroundColor White -ForegroundColor Red "`n Path to BGInfo tempate is not valid. Exiting... "
         return
      }
   }
   else {
       Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Paths are valid. Let's continue... "
   }
   
   #2. Create the C:\BGInfo folders on remote hosts
   Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Creating folder C:\BGInfo on remote hosts. Please wait... "
   Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {New-Item -ItemType 'directory' -Path 'C:\BGInfo' | Out-Null}
   Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Folder C:\BGInfo SUCCESSFULLY created on all remote hosts. "
   
   #3. Copy the BGInfo executable and template to the local drive of remote hosts
   Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Copying the BGInfo executable and template to remote hosts. Please wait... "
   $ComputerName | ForEach-Object -Process {
       $Session = New-PSSession -ComputerName $_ -Credential $Credential
       Copy-Item -LiteralPath $PathToBGInfoExecutable -Destination "C:\BGInfo\" -ToSession $Session
       Copy-Item -LiteralPath $PathToBGInfoTemplate -Destination "C:\BGInfo\" -ToSession $Session
   }
   Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n BGInfo Executable and template SUCCESSFULLY copied to all remote hosts. "
   
   #4. Unblock the copied installer (so no "Do you want to run this file?" pop-out hangs the installation in the next step)
   #Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Unblocking copied files. Please wait... "
   #Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Unblock-File -Path $using:PathToInstallerRemote}
   #Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n All files SUCCESSFULLY unblocked. "
   
   #5. Create the GBInfo shortcut in common startup folder
   Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Creating BGInfo autostart and desktop shortcuts on remote hosts. Please wait... "
   Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
      $WshShell = New-Object -comObject WScript.Shell
      $Shortcut = $WshShell.CreateShortcut($using:PathToShortcut)
      $Shortcut.TargetPath = $using:PathToBGInfoExecutableRemote
      $Shortcut.Arguments = $using:BGInfoArguments
      $Shortcut.Save()
      Copy-Item $using:PathToShortcut -Destination "C:\Users\Public\Desktop"
   }
   Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n BGInfo autostart and desktop shortcuts SUCCESFULY created on all remote hosts. "

   #5. Run BGInfo on remote hosts
   Write-Host -BackgroundColor White -ForegroundColor Red "`n Please use the desktop shortcut on remote hosts to run BGInfo for the first time. "
   Write-Host -BackgroundColor White -ForegroundColor Red " Also, remember to add the right BGInfo fields on appropriate hosts. "
}