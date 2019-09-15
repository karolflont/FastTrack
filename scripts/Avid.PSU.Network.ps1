############################
### NETWORK RELATED INFO ###
############################

function Get-NetworkInfo($ComputerName,[System.Management.Automation.PSCredential] $Credential, [switch]$SortByPSComputerName, [switch]$SortByName, [switch]$SortByInterfaceAlias, [switch]$SortByInterfaceIndex, [switch]$SortByIPv4Connectivity, [switch]$SortByNetworkCategory){
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
    
        #Default sort property
        $DefaultSortProperty = "PSComputerName"
        $PropertiesToDisplay = ('PSComputerName','Name','InterfaceAlias','InterfaceIndex','IPv4Connectivity','NetworkCategory') 
    
        $SortProperty = Test-SelectedProperties $DefaultSortProperty $PropertiesToDisplay $SortByPSComputerName $SortByName $SortByInterfaceAlias $SortByInterfaceIndex $SortByIPv4Connectivity $SortByNetworkCategory
    
    
        if (!$SortProperty) 
        {
            Return
        }
        else {
            $NetworkInfo = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-NetConnectionProfile}
            $NetworkInfo | Select-Object $PropertiesToDisplay | Sort-Object -Property $SortProperty | Format-Table -Wrap -AutoSize
        }
    }


    #IN PROGRESS
###############
##### RDP #####
###############
#IN PROGRESS

function Get-RemoteDesktopStatus($ComputerName,[System.Management.Automation.PSCredential] $Credential){
   <#
   .SYNOPSIS
      Checks if Remote Desktop connection to a specific computer is possible.
   .DESCRIPTION
      The Get-RemoteDesktopStatus function checks three parameters determining if Remote Desktop to a computer is possible. These are:
      1) "fDenyTSConnections" value of "HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server" registry key.
      2) "Remote Desktop Services" service status
      3) "Windows Firewall" service status
      4) "Remote Desktop" DisplayGroup firewall rule existance (if firewall is running)
   .PARAMETER ComputerName
      Specifies the computer name.
   .PARAMETER Credentials
      Specifies the credentials used to login.
   .EXAMPLE
      TODO
   #>
       ### Check if RDP is enabled - IN PROGRESS!!! - see help above for more info
       $RDPStatus = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections}
       Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n RDP Status "
       $RDPStatus | Select-Object PSComputerName, fDenyTSConnections | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
   }
   
   
   function Enable-RemoteDesktop($ComputerName,[System.Management.Automation.PSCredential] $Credential){
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
       Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0}
       Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Enable-NetFirewallRule -DisplayGroup "Remote Desktop"}
   }
   
   function Disable-RemoteDesktop($ComputerName,[System.Management.Automation.PSCredential] $Credential){
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
   Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 1}
   Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Disable-NetFirewallRule -DisplayGroup "Remote Desktop"}
   }