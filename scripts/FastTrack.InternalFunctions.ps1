function Confirm-FtSwitchParameters {
    <#
    .SYNOPSIS
        Tests if exactly one switch parameter from a given set is true and returns it's index in the input array.
    .DESCRIPTION
        The Confirm-FtSwitchParameters function returns:
        - the index of a parameter in the input array (Remember it's 0 based!) if only one switch parameter from a given set is $true
        - -1 if more than one or none of the switch parameters is $true
        NOTE 1: If $DefaultSwitch parammeter is selected, the function returns the value of #DefaultSwitch parameter 
        NOTE 2: Confirm-FtSwitchParameters handles up to 10 parameters
    .PARAMETER DefaultSwitch
        Specifies which switch parameter index should be returned as default, in case none of the switch parameters is $true.
    .EXAMPLE
        Confirm-FtSwitchParameters $Enable $Disable
        Confirm-FtSwitchParameters $SortByAlias $SortByHostnameInConfig $SortByDisplayName $SortByStatus $SortByStartType -DefaultSwitch 0
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
        [Parameter(Mandatory = $false)] $Param9,
        [Parameter(Mandatory = $false)] [int]$DefaultSwitch
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
        Write-Host -ForegroundColor Red "ERROR: Contradicting switch parameters selected.`n"
        Return -1
    }
    elseif ($SwitchCount -eq 1) {
        #If exactly one switch was selected, return the index of selected switch (Remember, it's 0 based!)
        Return $index
    }
    else {
        if ($null -ne $DefaultSwitch){
            Return $DefaultSwitch
        }
        else {
            #If none switch was selected and thre's no default one defined, print error and return -2
            Write-Host -ForegroundColor Red "ERROR: None of needed switch parameters selected.`n"
            Return -1
        }
    }
}

function Add-FtAliasAndHostnameProperties {
    <#
    .SYNOPSIS
    Adds Alias and Hostname properties to the given object.
    .DESCRIPTION
    The Add-FtAliasAndHostnameProperties function adds two properites to a given object:
    - Alias
    - HostnameInConfig
    These properties are derived from the $SysConfig global variable based on the IPs from PSCopmuterName property of the object
    .EXAMPLE
    $AvidSoftwareVersionsLabeled = Add-FtAliasAndHostnameProperties $AvidSoftwareVersionsRaw
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

function Invoke-FtGetScriptBlock {
    <#
    .SYNOPSIS
        Runs a "get" script block on remote computers, formats the returned object and prints the output. A "get" script block is a script block that fetches some data from a host.
    .DESCRIPTION
        The Invoke-FtGetScriptBlock function:
        - invokes a script block on remote computers
        - calls Add-FtAliasAndHostnameProperties to properly label the returned object
        - formats and prints the object
    .PARAMETER ComputerIP
        Specifies the computer IP.
    .PARAMETER Credential
        Specifies the credentials used to login.
    .PARAMETER HeaderMessage 
        Specifies a message displayed as a header in the output.
    .PARAMETER ScriptBlock
        Specifies the script block to invoke on the remote computers.
    .PARAMETER ActionIndex
        Specifies which property of the objects, returned from the remote computers, should be used to sort the object on output. (Also -1 and -2 values indicate an issue with the switch parameters)
    .EXAMPLE
        Invoke-FtGetScriptBlock -ScriptBlock $ScriptBlock -ActionIndex $ActionIndex -PropertiesToDisplay $PropertiesToDisplay -ComputerIP $ComputerIP -Credential $Credential
    #>
    Param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $true)] $HeaderMessage,
        [Parameter(Mandatory = $true)] $ScriptBlock,
        [Parameter(Mandatory = $true)] $ActionIndex
    )

    #Run Script Block on remote computers
    $ReturnedObjectRaw = @()
    Write-Host -ForegroundColor Cyan "Retrieving $HeaderMessage... " -NoNewline
    $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    $ReturnedObjectRaw += Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock $ScriptBlock
    $StopWatch.Stop()
    $ElapsedSeconds = $StopWatch.Elapsed.TotalSeconds 
    Write-Host -ForegroundColor Green "DONE " -NoNewline
    Write-Host -ForegroundColor Cyan "in $ElapsedSeconds sec."

    # Add rows for remote computers that returned $null
    if ($null -eq $ReturnedObjectRaw.PSComputerName) {
        $ReturnedComputerIPsUnique = @()
    }
    else {
        $ReturnedComputerIPsUnique = $ReturnedObjectRaw.PSComputerName | Get-Unique
    }
    $ComputersThatReturnedNothing = [string[]](Compare-Object -ReferenceObject $ComputerIP -DifferenceObject $ReturnedComputerIPsUnique).InputObject
    if ($ComputersThatReturnedNothing) {
        for ($i = 0; $i -lt $ComputersThatReturnedNothing.Length; $i++) {
            $ReturnedObjectRaw += @{ PSComputerName = $ComputersThatReturnedNothing[$i] }
        }
        Write-Warning "Some remote computers returned empty value for the query."
    }

    #Label returned object with Alias and HostnameInConfig properties
    $ReturnedObjectLabeled = Add-FtAliasAndHostnameProperties -InputObject $ReturnedObjectRaw

    Return $ReturnedObjectLabeled
}

function Format-FtOutput {
    <#
    .SYNOPSIS
        Formats the given Powershell object and outputs it to stdout.
    .DESCRIPTION
        The Format-FtOutput either outputs the given object unchanged ($RawOutput = $true), either formats the output using Select-Object and Format-Table cmdlets.
    .PARAMETER InputObject
        Specifies the object to format and output.
    .PARAMETER PropertiesToDisplay
        Specifies the properties of the objects, returned from the remote computers, to display.
    .PARAMETER ActionIndex
        Specifies which property of the objects, returned from the remote computers, should be used to sort the object on output.
    .PARAMETER RawOutput
        Specifies if the output should be formatted (human friendly output) or not (Powershell pipeline friendly output)
    .EXAMPLE

    #>
    Param(
        [Parameter(Mandatory = $true)] $InputObject,
        [Parameter(Mandatory = $true)] $PropertiesToDisplay,
        [Parameter(Mandatory = $true)] $ActionIndex,
        [Parameter(Mandatory = $false)][switch]$RawOutput
    )

    #Format output
    if ($RawOutput) {
        $InputObject | Select-Object $PropertiesToDisplay
    }
    else {
        Write-Output "`n----- $HeaderMessage -----"
        $InputObject | Select-Object $PropertiesToDisplay | Sort-Object -Property $PropertiesToDisplay[$ActionIndex] | Format-Table -Wrap -AutoSize -Property $PropertiesToDisplay 
    }

}

function Invoke-FtSetScriptBlock {
    <#
    .SYNOPSIS
        Runs a "set" script block on remote computers. A "set" script block is a script block that makes some configuration chnges on host.
    .DESCRIPTION
        The Invoke-FtSetScriptBlock function:
        - invokes a script block on remote computers
        - suppresses all possible standard output
    .PARAMETER ComputerIP
        Specifies the computer IP.
    .PARAMETER Credential
        Specifies the credentials used to login.
    .PARAMETER ScriptBlock
        Specifies the script block to invoke on the remote computers.
    .PARAMETER ActionIndex
        Specifies which 'set' switch parameter should be used. (Also -1 and -2 values indicate an issue with the switch parameters)
    .EXAMPLE
    
    #>
    Param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $true)] $ScriptBlock,
        [Parameter(Mandatory = $true)] $ActionIndex
    )

    #Run Script Block on remote computers
    Write-Host -ForegroundColor Cyan "Changing remote hosts configuration... " -NoNewline
    $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock $ScriptBlock | Out-Null
    $StopWatch.Stop()
    $ElapsedSeconds = $StopWatch.Elapsed.TotalSeconds 
    Write-Host -ForegroundColor Green "DONE " -NoNewline
    Write-Host -ForegroundColor Cyan "in $ElapsedSeconds sec."
}

function Install-FtApplication {
    <#
    .SYNOPSIS
        Runs a given installer on the selected remote hosts.
    .DESCRIPTION
        The Install-FtApplication function:
            - Checks if the PathToInstaller is valid
            - Creates the C:\FastTrackTempDir on remote hosts
            - Copies the installer to the C:\FastTrackTempDir on remote hosts
            - Unblocks the copied installer file (so no "Do you want to run this file?" pop-out appears resulting in instalation hang in the next step)
            - Run the installer on remote hosts with aapropriate parameters
            - Remove folder C:\FastTrackTempDir from remote hosts
    .PARAMETER ComputerIP
        Specifies the computer IP.
    .PARAMETER Credential
        Specifies the credentials used to login.
    .PARAMETER PathToInstaller
        Specifies the path to installer file.
    .PARAMETER ArgumentList
        Specifies the argument list to pass to the installer when running on remote hosts.
    .EXAMPLE
        Install-FtApplication -ComputerIP $ComputerIP -Credential $Credential -PathToInstaller $PathToInstaller -ArgumentList $ArgumentList
    #>

    Param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $true)] $PathToInstaller,
        [Parameter(Mandatory = $true)] $ArgumentList
    )

    $InstallerFileName = Split-Path $PathToInstaller -leaf
    $PathToInstallerRemote = 'C:\FastTrackTempDir\' + $InstallerFileName

    #1. Check if the PathToInstaller is valid - cancel installation if not.
    Write-Host -ForegroundColor Cyan "`Checking the path to the installer..." -NoNewline
    if (-not (Test-Path -Path $PathToInstaller -PathType leaf)) {
        Write-Host -ForegroundColor Red "NOT VALID"
        Write-Host -ForegroundColor Red "Please check the path to the installer on your local computer."
        Return -1
    }
    else {
        Write-Host -ForegroundColor Green "VALID"
    }

    #2. Create the C:\FastTrackTempDir on remote hosts
    Write-Host -ForegroundColor Cyan "Creating folder C:\FastTrackTempDir on remote hosts... " -NoNewline
    Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { New-Item -ItemType 'directory' -Path 'C:\FastTrackTempDir' | Out-Null }
    Write-Host -ForegroundColor Green "DONE"

    #3. Copy the installer to the local drive of the remote hosts
    Write-Host -ForegroundColor Cyan "Copying the installer to the remote hosts... " -NoNewline
    $ComputerIP | ForEach-Object -Process {
        $Session = New-PSSession -ComputerName $_ -Credential $Credential
        Copy-Item -LiteralPath $PathToInstaller -Destination "C:\FastTrackTempDir" -ToSession $Session
    }
    Write-Host -ForegroundColor Green "DONE"

    #4. Unblock the copied installer (so no "Do you want to run this file?" pop-out hangs the installation in the next step)
    Write-Host -ForegroundColor Cyan "Unblocking copied files... " -NoNewline
    Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Unblock-File -Path $using:PathToInstallerRemote }
    Write-Host -ForegroundColor Green "DONE"

    #5. Run the installer on remote hosts
    Write-Host -ForegroundColor Cyan "Installation in progress... " -NoNewLine
    $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Start-Process -FilePath $using:PathToInstallerRemote -ArgumentList $using:ArgumentList -Wait }
    $StopWatch.Stop()
    $ElapsedSeconds = $StopWatch.Elapsed.TotalSeconds 
    Write-Host -ForegroundColor Green "DONE " -NoNewline
    Write-Host -ForegroundColor Cyan "in $ElapsedSeconds sec."

    #6. Remove folder C:\FastTrackTempDir from remote hosts
    Write-Host -ForegroundColor Cyan "Cleaning up..." -NoNewLine
    Invoke-Command -ComputerName $ComputerIP -Credential $Credential -ScriptBlock { Remove-Item -Path "C:\FastTrackTempDir\" -Recurse }
    Write-Host -ForegroundColor Green "DONE"
}

function Uninstall-FtApplication {
    <#
    .SYNOPSIS
        Uninstalls a given application from the selected remote hosts.
    .DESCRIPTION
        The Uninstall-FtApplication function:
         - retrieves the correct Uninstall String from the registry
         - runs it using Start-Process cmdlet
    .PARAMETER ComputerIP
        Specifies the computer IP.
    .PARAMETER Credential
        Specifies the credentials used to login.
    .PARAMETER ApplicationNameToMatch
        Specifies the path to installer file.
    .EXAMPLE
        Uninstall-FtApplication -ComputerIP $ComputerIP -Credential $Credential -ApplicationNameToMatch $ApplicationNameToMatch
    #>

    Param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $true)] $ApplicationNameToMatch
    )

    Write-Host -ForegroundColor Cyan "Uninstallation in progress... " -NoNewLine
    $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    Invoke-Command -ComputerName $ComputerIP -Credential $Cred -ScriptBlock {
        $RegKeys = @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'
            'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'
        )

        $App = $RegKeys | Get-ChildItem | Get-ItemProperty | Where-Object { $_.DisplayName -match $using:ApplicationNameToMatch }

        $UninstallString = if ( $App.Uninstallstring -match '^msiexec' ) { "$( $App.UninstallString -replace '/I', '/X' ) /qn /norestart" }
        else { $App.UninstallString }

        Start-Process -FilePath cmd -ArgumentList '/c', $UninstallString -NoNewWindow -Wait
    }
    $StopWatch.Stop()
    $ElapsedSeconds = $StopWatch.Elapsed.TotalSeconds 
    Write-Host -ForegroundColor Green "DONE " -NoNewline
    Write-Host -ForegroundColor Cyan "in $ElapsedSeconds sec."
}

function Restart-FtRemoteComputer {
    <#
    .SYNOPSIS
        Controls a reboot operation on remote computers.
    .DESCRIPTION
        The Restart-FtRemoteComputer function invokes a reboot on remote computers or prints a reboot request message.        
    .PARAMETER ComputerIP
        Specifies the computer IP.
    .PARAMETER Credential
        Specifies the credentials used to login.
    .PARAMETER Reboot
        Specifies if the remote computers should be rebooted or just a reboot request message should be printed.
    .PARAMETER DontWaitForHostsAfterReboot
        Specifies if Powershell should wait for the remote hosts to be available for PowerShell Remoting again.
    .EXAMPLE
        Restart-FtRemoteComputer -ComputerIP $ComputerIP -Credential $Credential -Reboot $Reboot -DontWaitForHostsAfterReboot
    #>
    Param(
        [Parameter(Mandatory = $true)] $ComputerIP,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory = $true)] $Reboot,
        [Parameter(Mandatory = $false)] [switch]$DontWaitForHostsAfterReboot
    )

    if ($Reboot) {
        if ($DontWaitForHostsAfterReboot) {
            Restart-Computer -ComputerName $ComputerIP -Credential $Credential -Force
            Write-Host -ForegroundColor Cyan "A reboot was triggered on the selected remote hosts."
        }
        else {
            Write-Host -ForegroundColor Cyan "Waiting for selected remote hosts to reboot (no more than 5 minutes)..." -NoNewLine
            try {
                Restart-Computer -ComputerName $ComputerIP -Credential $Credential -Wait -For PowerShell -Timeout 300 -WsmanAuthentication Default -Force -ErrorAction Stop
            }
            catch {
                Write-Host -ForegroundColor Yellow "DONE"
                Write-Error "One or more computers did not finish restarting within 5 minutes. Use Test-FtPowershellRemoting for troubleshooting."
                Return
            }
            Write-Host -ForegroundColor Green "DONE"
            Write-Host -ForegroundColor Cyan "Selected remote hosts rebooted and available for PowerShell Remoting again."
        }
    }
    else {
        Write-Warning "Remote hosts were NOT REBOOTED after the operation. Please REBOOT manually later as this is required."
    }
}

function Confirm-FtRestart {
    <#
    .SYNOPSIS
        Confirms a reboot operation on remote computers.
    .DESCRIPTION
        The Confirm-FtRestart function asks a user for confirmation of the remote hosts reboot.        
    .EXAMPLE
        Confirm-FtRestart
    #>

    Write-Warning "Running this command will reboot the remote hosts after the operation. Only yes will be accepted as confirmation."
    $Continue = Read-Host 'Do you really want to reboot the hosts?'
    if ($Continue -eq 'yes') { $Reboot = $true }
    else { $Reboot = $false }
    Return $Reboot
}


