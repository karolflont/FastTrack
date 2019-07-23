####################
##### KEYBOARD #####
####################
#https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-input-locales-for-windows-language-packs

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
function Get-APSUKeyboardLayout($ComputerName,[System.Management.Automation.PSCredential] $Credential){
    ### Get keyboard layout - to nie do konca tak jest, bo co jak sa dwa jezyki??? - dostajemy liste i nie wiadomo ktory jest aktualnie wlaczony
    $InputMethodTips = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
        $LanguageList = Get-WinUserLanguageList
        $LanguageList.InputMethodTips}
    Write-Host -BackgroundColor White -ForegroundColor DarkBlue "`n Default keyboard layout (0409:0000000409 - en-US) `n"
    for ($i=0; $i -le $ComputerName.Count; $i++) {
        Write-Host -NoNewline $ComputerName[$i], " "
        Write-Host $InputMethodTips[$i]
    }
}

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
function Set-APSUKeyboardLayout($ComputerName,[System.Management.Automation.PSCredential] $Credential){
    ### Set keyboard layout to en-US
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {Set-WinDefaultInputMethodOverride -InputTip "0409:00000409"}
}
