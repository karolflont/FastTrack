###############
### NETWORK ###
###############
function Get-AvNetworkInfo {
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
   param (
      [Parameter(Mandatory = $true)] $ComputerIP,
      [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
      [Parameter(Mandatory = $false)] [switch]$SortByPSComputerName,
      [Parameter(Mandatory = $false)] [switch]$SortByName,
      [Parameter(Mandatory = $false)] [switch]$SortByInterfaceAlias,
      [Parameter(Mandatory = $false)] [switch]$SortByInterfaceIndex,
      [Parameter(Mandatory = $false)] [switch]$SortByIPv4Connectivity,
      [Parameter(Mandatory = $false)] [switch]$SortByNetworkCategory
   )
   
   #Default sort property
   $DefaultSortProperty = "PSComputerName"
   $PropertiesToDisplay = ('PSComputerName', 'Name', 'InterfaceAlias', 'InterfaceIndex', 'IPv4Connectivity', 'NetworkCategory') 
   
   $SortPropertyIndex = Test-AvIfExactlyOneSwitchParameterIsTrue $SortByPSComputerName $SortByName $SortByInterfaceAlias $SortByInterfaceIndex $SortByIPv4Connectivity $SortByNetworkCategory
   
   if ($null -eq $SortPropertyIndex) {
      #If none of the switches is selected, use the DafaultSortProperty
      $SortProperty = $DefaultSortProperty
   }
   elseif ($SortPropertyIndex -ge 0) {
      #If one switch is selected, use it as SortProperty
      $SortProperty = $PropertiesToDisplay[$SortPropertyIndex]
   }
   else {
      #If more than one switch is selected, return
      Return
   }
   
   $NetworkInfo = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Get-NetConnectionProfile }
   $NetworkInfo | Select-Object $PropertiesToDisplay | Sort-Object -Property $SortProperty | Format-Table -Wrap -AutoSize

   #Retrieving only IPv4 addresses
   #get-netipaddress | Where-Object -FilterScript {$_.AddressFamily -match “IPv4”} |Where-Object -FilterScript {$_.InterfaceAlias -notlike “Loopback*”}| Select-Object -ExpandProperty IPAddress | out-file C:\bginfo\MyIPv4Address.txt

   #GWMI Win32_NetworkAdapterConfiguration -Filter "IPEnabled = $true" |select @{N='IPv4'; E={($_."IPAddress").split(",")[0]}}
}
