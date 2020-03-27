function Import-AvSystemConfiguration{

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
        return
    }

    Write-Host -ForegroundColor Green "`nLists of hosts created based on the system configuration file: "

    #set All variable including all the servers, no matter if a server has any roles defined
    $global:All = $SysConfigVar.hosts.IP
    Write-Host "`$All = $global:All"

    #define a list of unique roles
    $roles = $SysConfigVar.hosts.role | Sort-Object | Get-Unique

    #define role variables
    foreach ($role in $roles) {
        $roleServers = ($SysConfigVar.hosts | Where-Object {$_.role -Like $role}).IP
        Set-Variable -Name "All$role" -Value $roleServers -Scope "global"
        $varName = Get-Variable "All$role" | Select-Object -ExpandProperty Name
        $varValue = Get-Variable "All$role" -ValueOnly
        Write-Host "`$$varName = $varVAlue"
    }

    Write-Host -ForegroundColor Green "`nThe whole System Configuration is kept in json format in `$SysConfig variable. "

}

function New-AvMRemoteNGSessionsConfiguration{}

function New-AvMobaXtermSessionsConfiguration{}

