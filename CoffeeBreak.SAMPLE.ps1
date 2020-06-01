<# 1. 
As the first step to use CoffeeBreak module, you should prepare and import the SystemConfiguration.json file.
If you don't know what a System Configuration file is and how to prepare it, please read README.md.
Preparing SystemConfiguration.json file is technically not obligatory, but it will be much easier to follow this
example if you prepare it.
Here's an example of how to import the SystemConfiguration.json file.
#>
Import-CbSystemConfiguration -Path 'F:\Avid\LocalDrive - Avid\_POWERSHELL\CoffeeBreak\CoffeeBreak.SystemConfiguration.DevEnv.json'
<#
As you can see, if your .json file had no errors, Import-CbSystemConfiguration creates for you some predefined variables:
 - $All variable - an array of IPs of all hosts defined in SystemConfiguration.json
 - Set of $All[<roleName>] variables, to let you easy address all servers of the same role
#>

<# 2.
CoffeeBreak module at the moment assumes that you can access all the servers defined in the SystemConfiguration.json with
common credentials. These can be either local credentials or domain credentials.
Store the credentials in a $cred object.
NOTE: to input domain credentials use domain\username syntax.
#>
$cred = Get-Credential

<# 3.
You're now ready to run your first function from CoffeeBreak module. Let it be testing two things:
1) The WS-MAN (protocol used by PowerShell remoting) communication with the remote machines.
2) Ability to open a remote session to a host - this also test if your credentials are valid
Please rememnber that ICMP is by default blocked by Windows Server 2016 and higher firewall,
so ping is not a valid test of connectivity on newly setup hosts. On contrary, PowerShell remoting
is enabled by default on Windows Server 2016 and higher.
NOTE: All functions from CoffeeBreak module have a noun prefix Av, to avoid name collisions with possible functions
from other modules. Av prefix makes it also easy to find a particular function using Intellisense in PowerShell window
or PowerShell ISE.
#>
Test-CbPowershellRemoting -ComputerIP $All -Credential $cred

<# 4.
#>
Get-CbHostname

<# 5.
#>
Set-CbHostname

<# 4.
Let it be Get-CbUptime.

#>
Get-Uptime -ComputerIP $All -Credential $cred