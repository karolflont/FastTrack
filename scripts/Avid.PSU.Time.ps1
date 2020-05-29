#########################
##### TIME SETTINGS #####
#########################
function Get-AvTimeAndTimeZone {
   <#
.SYNOPSIS
   Gets current time and time zone from servers.
.DESCRIPTION
   The Get-AvTime function gets current Date, Time, Time Zone and Daylight Saving Time information from a server.
   
   The function uses Get-Date and Get-TimeZone cmdlet.
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

   Write-Host "This funciton does not work when the computer from which you run the function has a different timezone set than"
   Write-Host "the computers you provide in the -ComputerIP parameter. It displays time in your computer timezone and not the remote hosts one."
   Write-Host "This needs to be corrected."

   $TimeZone = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Get-TimeZone }
   Write-Host -ForegroundColor Cyan "`nCurrent TIMEZONE on servers "
   $TimeZone | Select-Object PSComputerName, StandardName, BaseUtcOffset, SupportsDaylightSavingTime | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize

   #$Time = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock{Get-Date | Out-String}
   #Write-Host -ForegroundColor Cyan "`nCurrent TIME on servers "
   #$Time | Select-Object PSComputerName, DateTime | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}