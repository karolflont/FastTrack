function Test-CbIfExactlyOneSwitchParameterIsTrue {
    <#
    .SYNOPSIS
        Tests if exactly one switch parameter from a given set is true.
    .DESCRIPTION
        The Test-CbIfExactlyOneSwitchParameterIsTrue function does two things:
        1) Checks if exactly one parameter is passed to the parent function
        2) Returns:
        - the index of this parameter in the input array (Remember it's 0 based!) if exactly one switch is selcted
        - -2 if none of the switches is $true
        - -1 if more than one switch is $true
        NOTE: Test-CbIfExactlyOneSwitchParameterIsTrue handles up to 10 parameters
    .EXAMPLE
        Test-CbIfExactlyOneSwitchParameterIsTrue $Enable $Disable
        Test-CbIfExactlyOneSwitchParameterIsTrue $SortByPSComputerName $SortByName $SortByInterfaceAlias $SortByInterfaceIndex
    #>
    param(
        [Parameter(Mandatory = $false)] $Param0,
        [Parameter(Mandatory = $false)] $Param1,
        [Parameter(Mandatory = $false)] $Param2,
        [Parameter(Mandatory = $false)] $Param3,
        [Parameter(Mandatory = $false)] $Param4,
        [Parameter(Mandatory = $false)] $Param5,
        [Parameter(Mandatory = $false)] $Param6,
        [Parameter(Mandatory = $false)] $Param7,
        [Parameter(Mandatory = $false)] $Param8,
        [Parameter(Mandatory = $false)] $Param9 
    )

    $index = $null

    #Defining switch count to check if no more than 1 switch parameter is defined
    $SwitchCount = 0

    if ($Param0) {
        $SwitchCount = $SwitchCount + 1
        $index = 0
    }
    if ($Param1) {
        $SwitchCount = $SwitchCount + 1
        $index = 1
    }
    if ($Param2) {
        $SwitchCount = $SwitchCount + 1
        $index = 2
    }
    if ($Param3) {
        $SwitchCount = $SwitchCount + 1
        $index = 3
    }
    if ($Param4) {
        $SwitchCount = $SwitchCount + 1
        $index = 4
    }
    if ($Param5) {
        $SwitchCount = $SwitchCount + 1
        $index = 5
    }
    if ($Param6) {
        $SwitchCount = $SwitchCount + 1
        $index = 6
    }
    if ($Param7) {
        $SwitchCount = $SwitchCount + 1
        $index = 7
    }
    if ($Param8) {
        $SwitchCount = $SwitchCount + 1
        $index = 8
    }
    if ($Param9) {
        $SwitchCount = $SwitchCount + 1
        $index = 9
    }

    if ($SwitchCount -gt 1) {
        #If more than one switch was selected, write info message and return -1
        Write-Host -ForegroundColor Red "`nPlease specify just ONE switch parameter."
        Return -1
    }
    elseif ($SwitchCount -eq 1) {
        #If exactly one switch was selected, return the index of selected switch (Remember, it's 0 based!)
        Return $index
    }
    else {
        #If none switch was selected, return -2
        Return -2
    }
}

function Add-CbAliasAndHostnameProperties {
    <#
    .SYNOPSIS
    Adds Alias and Hostname properties to the given object.
    .DESCRIPTION
    The Add-AliasAndHostnameProperties function adds two properites to a given object:
    - Alias
    - HostnameInConfig
    These properties are derived from the $SysConfig global variable based on the IPs from PSCopmuterName property of the object
    .EXAMPLE
    $AvidSoftwareVersionsLabeled = Add-AliasAndHostnameProperties $AvidSoftwareVersionsRaw
    #>

    param(
        [Parameter(Mandatory = $false)] $InputObject
    )

    # Import configuration variable
    $sc = $global:SysConfig | ConvertFrom-Json

    $OutputObject = @()
    # For every element in $InputObject...
    for ($i = 0; $i -lt $InputObject.length; $i++) {

        # Retrieve IP of the current element
        $LabeledElement = $InputObject[$i]
        $CurrentIP = $LabeledElement.PSComputerName

        # Add Alias property
        $AliasValue = ($sc.hosts | Where-object { $_.IP -eq $CurrentIP }).alias
        $LabeledElement | Add-Member -MemberType NoteProperty -Name "Alias" -Value $AliasValue

        # Add HostnameInConfig property
        $HostnameInConfigValue = ($sc.hosts | Where-object { $_.IP -eq $CurrentIP }).hostname
        $LabeledElement | Add-Member -MemberType NoteProperty -Name "HostnameInConfig" -Value $HostnameInConfigValue

        $OutputObject += $LabeledElement
    }
    Return $OutputObject
}

function Invoke-CbScriptBlock {
    <#
    .SYNOPSIS
        Runs a script block on remote computers, formats the returned object and prints the output.
    .DESCRIPTION
        The Invoke-CbScriptBlock function:
        - invokes a script block on remote computers
        - calls Add-CbAliasAndHostnameProperties to properly label the returned object
        - formats and prints the object
    .PARAMETER ComputerIP
        Specifies the computer IP.
    .PARAMETER Credentials
        Specifies the credentials used to login.
    .PARAMETER HeaderMessage 
        Specifies a message displayed as a header in the output.
    .PARAMETER ScriptBlock
        Specifies the script block to invoke on the remote computers.
    .PARAMETER NullMessage
        Specifies a message displayed in case empty objects are returned from all remote computers
    .PARAMETER PropertiesToDisplay
        Specifies the properties of the objects, returned from the remote computers, to display.
    .PARAMETER ActionIndex
        Specifies which property of the objects, returned from the remote computers, should be used to sort the object on output.
    .PARAMETER RawOutput
        Specifies if the output should be formatted (human friendly output) or not (Powershell pipeline friendly output)
    .EXAMPLE
        Invoke-CbScriptBlock -ScriptBlock $ScriptBlock -NullMessage $NullMessage -ActionIndex $ActionIndex -PropertiesToDisplay $PropertiesToDisplay -ComputerIP $ComputerIP -Credential $Credential
    #>
    Param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory = $true)] $HeaderMessage,
        [Parameter(Mandatory = $true)] $ScriptBlock,
        [Parameter(Mandatory = $true)] $NullMessage,
        [Parameter(Mandatory = $true)] $PropertiesToDisplay,
        [Parameter(Mandatory = $true)] $ActionIndex,
        [Parameter(Mandatory = $false)] [switch]$RawOutput
    )

    # If more than one 'SortBy' property is selected, return
    if ($ActionIndex -eq -1) {
        Return
    }
    else {
        # If no 'SortBy' property is selected, set Alias as the default sort property
        if ($ActionIndex -eq -2) {
            $ActionIndex = 0
        }

        #Run Script Block on remote computers
        $ReturnedObjectRaw = @()
        Write-Host -ForegroundColor Cyan "Retrieving data... " -NoNewline
        $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
        $ReturnedObjectRaw += Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock $ScriptBlock
        $StopWatch.Stop()
        $ElapsedSeconds = $StopWatch.Elapsed.TotalSeconds 
        Write-Host -ForegroundColor Cyan "Done in $ElapsedSeconds sec."

        # If empty objects are returned from all remote computers, display info and quit
        if ($null -eq $ReturnedObjectRaw) {
            Write-Host -ForegroundColor Cyan "$NullMessage`n"
            Return
        }
        # Label returned object with Alias and HostnameInConfig properties
        $ReturnedObjectLabeled = Add-CbAliasAndHostnameProperties $ReturnedObjectRaw

        #Format output
        if($RawOutput){
            $ReturnedObjectLabeled
        }
        else{
            Write-Output "`n$HeaderMessage"
            $ReturnedObjectLabeled | Select-Object $PropertiesToDisplay | Sort-Object -Property $PropertiesToDisplay[$ActionIndex] | Format-Table -Wrap -AutoSize
        }
    }
}


