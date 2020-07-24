<#
FastTrack is a PowerShell module for automated installation, upgrade and troubleshooting of Avid systems based on Windows Server,
i.e. MediaCentral | Production Management and MediaCentral | Asset Management. It heavily leverages parallel commands execution
on Windows Servers using WinRM.

!!! WARNING !!!
If you're running this sample for the first time, it is STRONGLY RECOMMENDED to do this in a TEST and not any PRODUCTION environment.
Some of the FasTrack functions can introduce important configuration changes to your servers configured in the System Configuration .json file.
!!!!!!!!!!!!!!!

In the below example of usage, we assume you have a set of newly created VMs (or installed HW servers) with only:
    - Windows Server 2016 OS installed
    - Network configured
(You don't have to configure the proper hostnames of the hosts. FastTrack can do this for you.)

Some functions of the FastTrack module restart computers after introducing some configuration changes. Because of this,
it is recommended to install and run the FastTrack module on a separate Windows10/Windows Server 2016 computer than the set
of computers to configure/manage. However, if you don't do this, the computer you're running FastTrack functions from, will be
excluded from restarts - you will have to restart it manually.

I't best to open this FastTrack.SAMPLE.ps1 file in PowerShell ISE. This way:
    - you can run all the example one by one by placing a cursor on an appriopriate line and hitting F8
    - you can browse all the FastTrack module functions (and it's parameters!) in the 'Commands' panel on the right side of PowerShell ISE window.
#>

<# 
One last note before we start playing with FastTrack. At the moment, error handling is, let's say, moderate. Please keep this in mind, as well
as the fact that FastTrack is distributed under the GNU General Public License v3 - https://www.gnu.org/licenses/gpl-3.0.html.
#>

<# 1. 
As the first step to use FastTrack module, you should prepare and import the SystemConfiguration.json file.
If you don't know what a System Configuration file is and how to prepare it, please read README.md.
Preparing SystemConfiguration.json file is OBLIGATORY. You cannot use FastTrack module without it.
You can modify the attached 'FastTrack.SystemConfiguration.DevEnv.json' to mach your infrastructure configuration.
Here's an example of how to import the SystemConfiguration.json file. You can use a relative or absolute path.
#>
Import-FtSystemConfiguration -Path 'FastTrack.SystemConfiguration.DevEnv.json'
<#
As you can see, if your .json file had no errors, Import-FtSystemConfiguration creates for you some predefined global variables:
 - $All variable - an array of IPs of all hosts defined in SystemConfiguration.json
 - Set of $All[<roleName>] variables, to enable addressing easily all servers of the same role
 - Set of $[<alias>] variables, to enable addressing easily remote servers by their aliases
FastTrack is using IP addresses ONLY to communicate with the managed hosts. This is why it creates for you a bunch of predefined variables,
each holding a set of IP addresses.
The whole imported configuration is kept in a $FtConfig global variable. This variable is AN ABSOLUTE REFERENCE for all functions
from FastTrack module. You can type $FtConfig to see it.
#>
$FtConfig

<# 2.
FastTrack module maintains help for all the functions using Powershell help syntax. This means, for every function
from FastTrack module, you can use Get-Help <FunctionName> cmdlet, to get help for this function.
#>
Get-Help Import-FtSystemConfiguration
Get-Help Import-FtSystemConfiguration -Detailed
Get-Help Import-FtSystemConfiguration -Examples

<# 3.
FastTrack module at the moment assumes that you can access all the servers defined in the SystemConfiguration.json with
common credentials that guarantee an administrative access to the servers. These can be either local credentials or domain credentials.
Store the credentials in a $cred object.
NOTE1: To input domain credentials use domain\username syntax.
NOTE2: As you'll see below, FastTrack can batch-add computers to an AD domain, so choosing a local administrator credentials for a new
setup is the best choice.
#>
$cred = Get-Credential

<# 4.
You're now ready to run your first function from FastTrack module. Let it be testing two things:
1) The WS-MAN (protocol used by PowerShell remoting) communication with the remote machines.
2) Ability to open a remote session to a host - this also test if your credentials are valid
Please rememnber that ICMP is by default blocked by Windows Server 2016 and higher firewall,
so ping is not a valid test of connectivity on newly setup hosts. On contrary, PowerShell remoting
is enabled by default on Windows Server 2016 and higher.
NOTE: All functions from FastTrack module have a noun prefix Ft, to avoid name collisions with possible functions
from other modules. Ft prefix makes it also easy to find a particular function using Intellisense in PowerShell window
or PowerShell ISE.
#>
Test-FtPSRemoting -ComputerIP $All -Credential $cred

<# 5.
Now, when we have Powershell remoting working, let's check the basic configuration of the selected remote computers.
#>
Get-FtHWSpecification -ComputerIP $all -Credential $cred
Get-FtOSVersion -ComputerIP $all -Credential $cred
<#
FastTrack module cannot modify the above parameters but can do quite a lot of other operations.
#>

<# 6.
Let's now check the hostnames of the servers from your config (imported from .json file to $FtConfig global variable).
If the hostnames on the remote servers are not in sync with the hostnames in your config, you can change them.
#>
Get-FtHostnameAndDomain -ComputerIP $all -Credential $cred
Set-FtHostname -ComputerIP $all -Credential $cred
<#
NOTE1: As for all FastTrack module functions, there are some additional parameters you can pass to the above functions
to modify their behavior. You can review them using Get-Help cmdlet.
NOTE2: Most of the FastTrack functions exist in pairs Get- function only retrieves some data from the selected remote computers.
Set- function introduces needed config changes on the remote hosts.
#>

<# 7.
Now, when you're hostnames are set, it's time to join the computers to the domain.
#>
Get-FtHostnameAndDomain -ComputerIP $all -Credential $Cred
Set-FtDomain -ComputerIP $all -Credential $cred -DomainName lop.pri -DomainAdminUsername lop\administrator -Join
<#
NOTE: You can use Set-FtDomain to leave the domain too.
#>
Get-Help Set-FtDomain -Detailed

<# 7.
Let's check some other basic parameters of the servers
#>
Get-FtNetworkConfiguration -ComputerIP $all -Credential $cred
Get-FtTimeAndTimeZone -ComputerIP $all -Credential $cred
<#
Unfortunately, at the moment FastTrack cannot modify any network or time related configuration.
#>

<# 8.
But it can control the Firewall state of the remote computers.
#>
Get-FtFirewallService -ComputerIP $all -Credential $cred
Start-FtFirewallService -ComputerIP $all -Credential $cred
Get-FtFirewallState -ComputerIP $all -Credential $cred
Set-FtFirewallState -ComputerIP $all -Credential $cred -AllOff
<#
FastTrack does not support stopping and disabling firewall service as this can have complex implications for Powershell remoting functioning.
It is also not a good idea in general.
#>

<# 8.
You can also check and configure Remote Desktop on the servers. Especially, using FastTrack, you can turn on RDP if you don't have
a physical/iDRAC/iLO/VMware Console access to the servers.
#>
Get-FtRemoteDesktop -ComputerIP $all -Credential $cred
Set-FtRemoteDesktop -ComputerIP $all -Credential $cred -EnableWithEnabledNLA

<# 8.
You can also make a few other small, but sometimes important or handy tweaks.
#>
Get-FtHiddenFilesAndFolders -ComputerIP $all -Credential $cred
Set-FtHiddenFilesAndFolders -ComputerIP $all -Credential $cred -Show
Get-FtServerManagerBehaviorAtLogon -ComputerIP $all -Credential $cred
Set-FtServerManagerBehaviorAtLogon -ComputerIP $all -Credential $cred -Disable
Get-FtUACLevelForAdmins -ComputerIP $all -Credential $cred
Set-FtUACLevelForAdmins -ComputerIP $all -Credential $cred -NeverNotify
Get-FtProcessorScheduling -ComputerIP $all -Credential $cred
Set-FtProcessorScheduling -ComputerIP $all -Credential $cred -Default
Get-FtPowerPlan -ComputerIP $all -Credential $cred
Set-FtPowerPlan -ComputerIP $all -credential $cred -HighPerformance
Get-FtWindowsUpdateService -ComputerIP $all -Credential $cred
Set-FtWindowsUpdateService -ComputerIP $all -Credential $cred -DisableAndStop

<#
If you're setting up a MediaCentral | Production Maangement cluster, you can quickly install the Failover Cloutering Feature on both nodes
#>
Get-FtFailoverClusteringFeature -ComputerIP $ie -Credential $cred
Set-FtFailoverClusteringFeature -ComputerIP $ie -Credential $cred -Install 
Set-FtFailoverClusteringFeature  -ComputerIP $ie -Credential $cred -Uninstall

<#
If there's some CMD command you'd like to run on multiple hosts and compare its results, you can do this.
#>
Invoke-FtCMDExpression -ComputerIP $all -Credential $cred -CMDExpression 'w32tm /query /status'
Invoke-FtCMDExpression -ComputerIP $all -Credential $cred -CMDExpression 'w32tm /query /status' -SortByLineNumber

<#
You can also install (and uninstall if needed) AvidNexis Client on multiple hosts quickly.
#>
Install-FtAvidNexisClient -ComputerIP $all -Credential $Cred -PathToInstaller 'C:\AvidInstallers\AvidNEXISClient_Win64_20.5.0.6.msi'
Uninstall-FtAvidNexisClient -ComputerIP $all -Credential $Cred

<#
Often, it's a nice idea to configure and run BGInfo on the servers. While FastTrack cannot configure the BGInfo template
to match exactly the needs of a particular server, it can halp you with distributing BGInfo executable and a common tamplate
to selected servers and creating a BGInfo Autostart and Desktop shortcuts
#>
Install-FtBGInfo -ComputerIP $ie -Credential $cred -PathToBGInfoExecutable 'C:\AvidInstallers\BGInfo\BGInfo.exe' -PathToBGInfoTemplate 'C:\AvidInstallers\BGInfo\x64Client.bgi'

<#
After the installation of all Avid Software, it's always a good idea to check if all is installed and running as planned.
#>
Get-FtAvidSoftware -ComputerIP $all -Credential $cred
Get-FtAvidSoftware -ComputerIP $all -Credential $cred -SortByDisplayName
Get-FtAvidSoftware -ComputerIP $all -Credential $cred -SortByDisplayVersion
Get-FtAvidServices -ComputerIP $all -Credential $cred
Get-FtAvidServices -ComputerIP $all -Credential $cred -SortByStatus

<#
And after some dry run tests, you can check the System Event Logs of the selected hosts for Errors.
#>
Get-FtEventLogErrors -ComputerIP $all -Credential $cred
Get-FtEventLogErrors -ComputerIP $all -Credential $cred -After '23 Dec 2019 13:53:45'
Get-FtEventLogErrors -ComputerIP $all -Credential $cred -After '23 Dec 2019 13:53:45' -Before '4 Jul 2020 7:10:17' -SortByNumberOfOccurences

<#
Last, but not least a quick check of uptime is sometimes a handy feature
#>
Get-FtUptime -ComputerIP $All -Credential $cred

<#
There are a few other details worth noting at the end.
All of 'Set-' FastTrack funcions support -DontCheck switch parameter, which disables checking the introduced configuration
changes with a corresponding 'Get-' function.
All of 'Get-' FastTrack functions (and some others too) support -RawOutput parameter, which disables formatting the output PowerShell obejct
as a table. Using -RawOutput switch, enables using the function in the Powershell pipeline. This is not possible if the output
is formatted as a table.
#>
Set-FtPowerPlan -ComputerIP $all -credential $cred -HighPerformance -DontCheck
Get-FtAvidSoftware -ComputerIP $all -Credential $cred -RawOutput | Where-Object { ($_.DisplayName -eq 'Avid NEXIS Client') -and ($_.DisplayVersion -like '*20.3*') } | Format-Table
Invoke-FtCMDExpression -ComputerIP $all -Credential $cred -CMDExpression 'w32tm /query /status' -RawOutput | Where-Object { $_.CMDExpressionOutput -like '*Root Delay:*' } | Format-Table

<#
Also, if you'd like to redirect the output of any of the FastTrack functions to a file, please note that ONLY white text
will be redirected to the file. Cyan output text is directed to Console ONLY.
#>
Get-FtEventLogErrors -ComputerIP $all -Credential $cred -After '23 December 2019 13:53:45' > EventLog.txt

<#
That's all for now. Have fun and automate everything!
#>
