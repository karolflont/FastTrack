function Install-AvPDFReader{
}

function Invoke-AvPowershellCommand{

}

function Invoke-AvPowershellScript {
    -ScriptBlock
    -FilePath

    Write-Output 'Use Invoke-Command cmdlet with -FilePath parameter, e.g. Invoke-Command -FilePath c:\scripts\test.ps1 -ComputerName Server01'
}


function Invoke-AvCMDExpression{

    Param(
        [Parameter(Mandatory = $true)] $ComputerName,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $true)] $ScriptBlock
    )

    $result = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Invoke-Expression $using:ScriptBlock}
    
    $result | gm

    $result | Select-Object PSComputerName, Date | Format-Table -Wrap -AutoSize

}

function Invoke-AvCMDScript{
    -ScriptBlock

}