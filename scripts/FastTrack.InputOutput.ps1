function Import-FtSystemConfiguration {
    <#
    .SYNOPSIS
        Imports the system configuration from a .json file and cretes the default groups of hosts IPs.
    .DESCRIPTION
        The Import-FtSystemConfiguration function:
            - imports the system configuration from a .json file to a $SysConfig global variable
            - creates $All global variable - an array of IPs of all hosts defined in config .json file
            - creates a set of $All[<roleName>] global variables, to enable addressing easily all servers of the same role
            - creates a set of $[<alias>] global variables, to enable addressing easily remote servers by their alias
    .PARAMETER Path
        Path to the system configuration file in .json format. Can be relative or absolute.
    .EXAMPLE
        Import-FtSystemConfiguration -Path 'FastTrack.SystemConfiguration.DevEnv.json'
    #>

    param(
        [Parameter(Mandatory = $true)] [string] $path
    )

    try {
        #import the System Configuration file and store it in a global variable for future reference from other functions
        $SysConfigVar = Get-Content -Raw -Path $path | ConvertFrom-Json
        $global:SysConfig = $SysConfigVar | ConvertTo-Json
    }
    catch {
        Write-Host -ForegroundColor Red "`n Import of JSON config file failed. Plese validate it's syntax, e.g. using https://jsonlint.com/ "
        Return
    }

    Write-Host -ForegroundColor Cyan "Variables created based on the system configuration file: "

    #set all variable including all the servers, no matter if a server has any roles defined
    $global:all = $SysConfigVar.hosts.IP
    Write-Host "`$all = $global:all"

    #define a list of unique roles
    $roles = $SysConfigVar.hosts.role | Sort-Object | Get-Unique

    #define role variables
    foreach ($role in $roles) {
        $roleServers = ($SysConfigVar.hosts | Where-Object { $_.role -Like $role }).IP
        Set-Variable -Name "all$role" -Value $roleServers -Scope "global"
        $varName = Get-Variable "all$role" | Select-Object -ExpandProperty Name
        $varValue = Get-Variable "all$role" -ValueOnly
        Write-Host "`$$varName = $varVAlue"
    }

    #define a list of aliases
    $aliases = $SysConfigVar.hosts.alias | Sort-Object

    #check if aliases are unique
    if ($aliases.length -eq ($aliases | Get-Unique).length) {
        #define alises variables
        foreach ($alias in $aliases) {
            $IPforAParticularAlias = ($SysConfigVar.hosts | Where-Object { $_.alias -Like $alias }).IP
            Set-Variable -Name "$alias" -Value $IPforAParticularAlias -Scope "global"
            $varName = Get-Variable "$alias" | Select-Object -ExpandProperty Name
            $varValue = Get-Variable "$alias" -ValueOnly
            Write-Host "`$$varName = $varValue"
        }
        Write-Host -ForegroundColor Green "`nThe whole System Configuration is kept in json format in `$SysConfig variable."
    }
    else {
        Write-Host -ForegroundColor Red "`nAliases used for hosts defined in the $path are not unique. Please modify your configuration file."
        Return
    }
}

