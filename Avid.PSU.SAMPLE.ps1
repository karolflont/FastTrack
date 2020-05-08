<# 1. 
As the first step to use Avid.PSUtilities module, you should prepare and import the SystemConfiguration.json file.
If you don't know what a System Configuration file is and how to prepare it, please read the README.md.
Here's an example of how to import the SystemConfiguration.json file.
#>
Import-AvSystemConfiguration -Path 'F:\Avid\LocalDrive - Avid\_POWERSHELL\Avid.PSUtilities\Avid.PSU.SystemConfiguration.DevEnv.json'
<#
As you can see, if your .json file had no errors, Import-AvSystemConfiguration creates for you some predefined variables:
 - $all variable - an array of IPs of all hosts defined in SystemConfiguration.json
 - Set of $all<roleName> variables, to let you easy address all servers of the same role
 - Set of $<alias> variables, to let you easy address a particular server using its alias
NOTE: Please note that all these variables are sets of IPs (NOT hostnemes). If you know what you're doing, you can,
for the majority of functions in this module, use a hostname or an array of hostnames as the -ComputerName parameter,
but Avid.PSUtilites by default uses IP addresses when opening the PowerShell remoting sessions to remote hosts. This is to avoid
any connectivity problems, especially in a non-domain environments.
#>

<# 2.
Avid.PSUtilities module at the moment assumes that you can access all the servers defined in the SystemConfiguration.json with
common credentials. These can be either local credentials or domain credentials.
Store the credentials in a $cred object.
NOTE: to input domain credentials use domain\username syntax.
#>
$cred = Get-Credential

<# 3.
You're now ready to run your first function from Avid.PSUtilities module. It is a function testing two things:
1) The WS-MAN (protocol used by PowerShell remoting) communication with the remote machines.
2) Ability to open a remote session to a host - this also test if your credentials are valid
Please rememnber that ICMP is by default blocked by Windows Server 2016 and higher firewall,
so ping is not a valid test of connectivity on newly setup hosts. On contrary, PowerShell remoting
is enabled by default on Windows Server 2016 and higher.
NOTE: all functions from Avid.PSUtilities module have a noun prefix Av, to avoid name collisions with possible functions
from other modules. Av prefix makes it also easy to find a particular function using Intellisense in PowerShell window
or PowerShell ISE.
#>
Test-AvPowerShellRemoting -ComputerIP $all -Credential $cred

<# 4.
If the above powershell remoting test was successful, you can now run any other function from the Avid.PSUtilities module
and all of them sould work. There are mainly two types of functions is Avid.PSUtilities module:
- Get functions (starting with Get verb) - that only READS some configuration paramater from the remote hosts
- Set functions (starting with Set verb) - that MODIFIES some configuration parameters on the remote hosts
The later ones can be potentially HARMFUL, so please be careful!
All the functions are of course extensively tested, before getting in to the stable version of the module,
but please remember this module is anyway provided "as is". Please refer to the Copyright statment for this module
in Avid.PSUtilities.psd1 for license details.
As a sample Get function, run the Get-AvHostname.
#>
Get-AvHostname -ComputerIP $all -Credential $cred

<# 5.
To get the list of all functions in this module you can use Get-Command cmdlet.
#>
Get-Command -Module Avid.PSUtilities

<# 6.
To get help for a particular function you can use Get-Help cmdlet. Here's an example for Get-AvHostname function.
#>
Get-Help -Name Get-AvHostname
Get-Help -Name Get-AvHostname -Examples
Get-Help -Name Get-AvHostname -ShowWindow
