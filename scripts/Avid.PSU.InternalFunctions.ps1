function Test-AvIfExactlyOneSwitchParameterIsTrue{
        <#
    .SYNOPSIS
        Tests if exactly one switch parameter from a given set is true.
    .DESCRIPTION
        The Test-AvIfExactlyOneSwitchParameterIsTrue function does two things:
        1) Checks if exactly one parameter is passed to the parent function
        2) Returns:
        - the index of this parameter in the input array (Remember it's 0 based!) if exactly one switch is selcted
        - $null if none of the switches is $true
        - -1 if both switches are $true
    .EXAMPLE
        Test-AvIfExactlyOneSwitchParameterIsTrue $Enable $Disable
        Test-AvIfExactlyOneSwitchParameterIsTrue $SortByPSComputerName $SortByName $SortByInterfaceAlias $SortByInterfaceIndex
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

    if ($Param0)  {
        $SwitchCount = $SwitchCount + 1
        $index = 0
    }
    if ($Param1)  {
        $SwitchCount = $SwitchCount + 1
        $index = 1
    }
    if ($Param2)  {
        $SwitchCount = $SwitchCount + 1
        $index = 2
    }
    if ($Param3)  {
        $SwitchCount = $SwitchCount + 1
        $index = 3
    }
    if ($Param4)  {
        $SwitchCount = $SwitchCount + 1
        $index = 4
    }
    if ($Param5)  {
        $SwitchCount = $SwitchCount + 1
        $index = 5
    }
    if ($Param6)  {
        $SwitchCount = $SwitchCount + 1
        $index = 6
    }
    if ($Param7)  {
        $SwitchCount = $SwitchCount + 1
        $index = 7
    }
    if ($Param8)  {
        $SwitchCount = $SwitchCount + 1
        $index = 8
    }
    if ($Param9)  {
        $SwitchCount = $SwitchCount + 1
        $index = 9
    }

    if ($SwitchCount -gt 1){
        #If more than one switch was selected, write info message and return -1
        Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONE switch parameter. "
        Return -1
    }
    elseif ($SwitchCount -eq 1){
        #If exactly one switch was selected, return the index of selected switch (Remember, it's 0 based!)
        Return $index
    }
    else {
        #If none switch was selected, write info message and return $null
        Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONE switch parameter. "
        Return
    }
}



