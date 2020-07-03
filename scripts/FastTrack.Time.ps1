#########################
##### TIME SETTINGS #####
#########################
function Get-FtTimeAndTimeZone {
   <#
.SYNOPSIS
   Gets current date, time, time zone and DST information from selected hosts.
.DESCRIPTION
   The Get-FtTime function retrieves current Date, Time, Time Zone and Daylight Saving Time information from selected servers using:
    - Date - (Get-Date).ToLongDateString()
    - Time - (Get-Date).ToLongTimeString() 
    - TimeZone - Get-TimeZone
    - DST - (Get-Date).IsDaylightSavingTime()
   
   The function uses Get-Date and Get-TimeZone cmdlet.
.PARAMETER ComputerIP
   Specifies the computer IP.
.PARAMETER Credential
   Specifies the credentials used to login.
.PARAMETER RawOutput
   Specifies if the output should be formatted (human friendly output) or not (Powershell pipeline friendly output)
.EXAMPLE
   Get-FtTimeAndTimeZone -ComputerIP $all -Credential $cred
#>
   param(
      [Parameter(Mandatory = $true)] $ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
      [Parameter(Mandatory = $false)] [switch]$RawOutput
   )

   $HeaderMessage = "Current time and timezone"

   $ScriptBlock = {
      $DateTime = Get-Date

      [pscustomobject]@{
         Date     = $DateTime.ToLongDateString() 
         Time     = $DateTime.ToLongTimeString() 
         TimeZone = Get-TimeZone
         IsDST    = $DateTime.IsDaylightSavingTime()
      }
   }
  
   $ActionIndex = 0
  
   $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

   $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'Date', 'Time', 'TimeZone', 'IsDST') 

   if ($RawOutput) { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput }
   else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}