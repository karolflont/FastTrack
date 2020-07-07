function Invoke-FtCMDExpression {
    <#
   .SYNOPSIS
        Outputs the results of any given Windows Commandline (CMD) expression for a list of computers.
   .DESCRIPTION
        The Invoke-FtCMDExpression function uses 'Invoke-Expression' cmdlet. The output of the CMD Expression is split into separate lines to enaable sorting the output by line number if needed.
   .PARAMETER ComputerIP
        Specifies computer IP.
   .PARAMETER Credential
        Specifies credentials used to login.
   .PARAMETER CMDExpression
        Specifies the CMD expression to run on remote computers.
   .PARAMETER SortByLineNumber
        Allows sorting by the line number of the CMD Expression Output
   .PARAMETER RawOutput
        Specifies that the output will NOT be sorted and formatted as a table (human friendly output). Instead, a raw Powershell object will be returned (Powershell pipeline friendly output).
   .EXAMPLE
    Invoke-FtCMDExpression -ComputerIP $all -Credential $cred -CMDExpression 'w32tm /query /status'
   #>

    Param(
        [Parameter(Mandatory = $true)] [string[]]$ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $true)] $CMDExpression,
        [Parameter(Mandatory = $false)] [switch]$SortByLineNumber,
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    $HeaderMessage = "CMD Expression `'$CMDExpression`' results"

    $ScriptBlock = {
        $result = Invoke-Expression $using:CMDExpression
        for ($i = 0; $i -lt $result.Count; $i++) {
            $line = $result[$i]
            [pscustomobject]@{
                LineNumber          = $i + 1
                CMDExpressionOutput = $line
            }
        }
    }

    $ActionIndex = Confirm-FtSwitchParameters $false $false $SortByLineNumber -DefaultSwitch 0
    
    $Result = Invoke-FtGetScriptBlock -ComputerIP $ComputerIP -Credential $Credential -HeaderMessage $HeaderMessage -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex

    $PropertiesToDisplay = ('Alias', 'HostnameInConfig', 'LineNumber', 'CMDExpressionOutput')

    # Always sort by LineNumber as second property
    $ActionIndex = ($ActionIndex, 2)

    if ($RawOutput) { 
        Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex -RawOutput 
    }
    else { Format-FtOutput -InputObject $Result -PropertiesToDisplay $PropertiesToDisplay -ActionIndex $ActionIndex }
}
