function Invoke-FtCMDExpression {
    <#
   .SYNOPSIS
   Outputs the results of any given Windows Commandline (CMD) expression for a list of computers.
   .DESCRIPTION
   The Invoke-FtCMDExpression function uses:
   - Invoke-Expression cmdlet
   .PARAMETER ComputerIP
   Specifies computer IP.
   .PARAMETER Credentials
   Specifies credentials used to login.
   .PARAMETER CMDExpression
   Specifies the CMD expression to run on remote computers.
   .EXAMPLE
   Invoke-FtCMDExpression -ComputerIP $all -Credential $cred -CMDExpression 'w32tm /query /status'
   #>

    Param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $true)] $CMDExpression
    )

    # Run command
    $Result = Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock {
        $result = Invoke-Expression $using:CMDExpression
        [pscustomobject]@{CMDExpressionValue = $result }
    }

    # Import configuration variable
    $sc = $global:SysConfig | ConvertFrom-Json

    # Format and print results for each computer
    foreach ($ResultLine in $Result) {
        Write-Host -ForegroundColor Green "`n-----------------------------------------------------------"
        $CurrentIP = [string]$ResultLine.PSComputerName
        $RemoteHostName = ($sc.hosts | Where-object { $_.IP -eq $CurrentIP }).hostname
        $RemoteHostAlias = ($sc.hosts | Where-object { $_.IP -eq $CurrentIP }).alias
        Write-Host "Alias / Hostname: $RemoteHostAlias / $RemoteHostName"
        Write-Host "CMD Expression: $CMDExpression"
        Write-Host -ForegroundColor Green "-----------------------------------------------------------"
        $ResultLine.CMDExpressionValue
        Write-Host -ForegroundColor Green "-----------------------------------------------------------"
    }
}
