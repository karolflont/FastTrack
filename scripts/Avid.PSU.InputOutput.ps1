function Import-AvSystemConfiguration{

    param(
        [Parameter(Mandatory = $true)] [string] $path
    )

    try {
        $sysConfig = Get-Content -Raw -Path $path | ConvertFrom-Json
    }
    catch {
        Write-Host -BackgroundColor White -ForegroundColor Red "`n Import of JSON config file failed. Plese validate it's syntax, e.g. using https://jsonlint.com/ "
        return
    }

    Write-Host -BackgroundColor White -ForegroundColor DarkGreen "`n Lists of hosts created based on the system configuration file "

    #set All variable including all the servers, no matter if a server has any roles defined
    $global:All = $sysConfig.hosts.IP
    Write-Host "`$All = $global:All"

    #define a list of unique roles
    $roles = $sysconfig.hosts.role | Sort-Object | Get-Unique

    #define role variables
    foreach ($role in $roles) {
        $roleServers = ($sysconfig.hosts | Where-Object {$_.role -Like $role}).IP
        Set-Variable -Name "All$role" -Value $roleServers -Scope "global"
        $varName = Get-Variable "All$role" | Select-Object -ExpandProperty Name
        $varValue = Get-Variable "All$role" -ValueOnly
        Write-Host "`$$varName = $varVAlue"
    }
}

function New-AvMRemoteNGSessionsConfiguration{}

function New-AvMobaXtermSessionsConfiguration{}

