function Test-SelectedProperties($DefaultProperty, $PropertiesList, $Param1, $Param2, $Param3, $Param4, $Param5, $Param6, $Param7, $Param8, $Param9, $Param10){
        <#
    .SYNOPSIS
        Sorts the object by a selected property.
    .DESCRIPTION
        The Test-SelectedProperties function does two things:
        1) Checks if only one sort parameter is passed to the parent function
        2) Returns this sort parameter.
    .PARAMETER DefaultProperty
        Specifies the default property to sort. Defined by parent function.
    .PARAMETER ParametersList
        Specifies the properties list.
    .EXAMPLE
        TODO
    #>

    #Default sort property
    $SortProperty = $DefaultProperty

    #Definig switch count to check if no more than 1 switch parameter is defined
    $SwitchCount = 0


    if ($Param1)  {
        $SwitchCount = $SwitchCount + 1
        $SortProperty = $PropertiesList[0]
    }
    if ($Param2)  {
        $SwitchCount = $SwitchCount + 1
        $SortProperty = $PropertiesList[1]
    }
    if ($Param3)  {
        $SwitchCount = $SwitchCount + 1
        $SortProperty = $PropertiesList[2]
    }
    if ($Param4)  {
        $SwitchCount = $SwitchCount + 1
        $SortProperty = $PropertiesList[3]
    }
    if ($Param5)  {
        $SwitchCount = $SwitchCount + 1
        $SortProperty = $PropertiesList[4]
    }
    if ($Param6)  {
        $SwitchCount = $SwitchCount + 1
        $SortProperty = $PropertiesList[5]
    }
    if ($Param7)  {
        $SwitchCount = $SwitchCount + 1
        $SortProperty = $PropertiesList[6]
    }
    if ($Param8)  {
        $SwitchCount = $SwitchCount + 1
        $SortProperty = $PropertiesList[7]
    }
    if ($Param9)  {
        $SwitchCount = $SwitchCount + 1
        $SortProperty = $PropertiesList[8]
    }
    if ($Param10)  {
        $SwitchCount = $SwitchCount + 1
        $SortProperty = $PropertiesList[9]
    }

    $InfoString = $null
    if ($SwitchCount -gt 1){
        for ($i = 0; $i -lt $PropertiesList.Count; $i++)
        { 
           $InfoString = $InfoString + "-" + $PropertiesList[$i] + "/" 
        }
        Write-Host -BackgroundColor White -ForegroundColor Red "`n Please specify ONLY ONE of the $InfoString switch parameters. "
        Return
    }
    else{
        Return $SortProperty
    }
}
