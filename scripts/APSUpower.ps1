######################
##### POWER PLAN #####
######################

function Get-APSUPowerPlan($ComputerName,[System.Management.Automation.PSCredential] $Credential){
    <#
    .SYNOPSIS
       Gets the ACTIVE Power Plan of the server.
    .DESCRIPTION
       The Get-APSUPowerPlan function gets the ACTIVE Power Plan of the server.

       The function uses Get-CimInstance cmdlet.
    .PARAMETER ComputerName
       Specifies the computer name.
    .PARAMETER Credentials
       Specifies the credentials used to login.
    .EXAMPLE
       TODO
    #>
    $PowerPlan = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Get-CimInstance -Namespace root\cimv2\power -ClassName win32_PowerPlan}
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Active Power Plan "
    $PowerPlan | Where-Object {$_.IsActive -eq $True} | Select-Object PSComputerName, ElementName | Sort-Object -Property PScomputerName | Format-Table -Wrap -AutoSize
}

function Set-APSUPowerPlanToHighPerformance($ComputerName,[System.Management.Automation.PSCredential] $Credential){
    <#
    .SYNOPSIS
       Sets the ACTIVE Power Plan of the server to HIGH PERFORMANCE.
    .DESCRIPTION
       The Set-APSUPowerPlan function sets the ACTIVE Power Plan of the server to HIGH PERFORMANCE.

       The function uses Get-CimInstance and Invoke-CimMethod cmdlets.
    .PARAMETER ComputerName
       Specifies the computer name.
    .PARAMETER Credentials
       Specifies the credentials used to login.
    .EXAMPLE
       TODO
    #>
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock{
        $HighPerformancePowerPlan = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'High Performance'"
        Invoke-CimMethod -InputObject $HighPerformancePowerPlan -MethodName Activate | Out-Null
    }
    Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Power Plan SET to HIGH PERFORMANCE. "
    Get-APSUPowerPlan $ComputerName $Credential
}