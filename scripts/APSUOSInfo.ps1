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
