####################
##### HOSTNAME #####
####################

function Get-APSUHostname($ComputerName,[System.Management.Automation.PSCredential] $Credential){
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
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {hostname}
}

function Get-APSUNetworkInfo($ComputerName,[System.Management.Automation.PSCredential] $Credential, [switch]$SortByPSComputerName, [switch]$SortByName, [switch]$SortByInterfaceAlias, [switch]$SortByInterfaceIndex, [switch]$SortByIPv4Connectivity, [switch]$SortByNetworkCategory){
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
