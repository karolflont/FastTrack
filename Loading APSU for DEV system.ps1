### Copy
$source = 'C:\Users\kflont\LocalDrive - Avid\_POWERSHELL\Avid.PSUtilities'
$destination = 'C:\Program Files\WindowsPowerShell\Modules'
Copy-Item -LiteralPath $source -Destination $destination -Recurse -Force

### Removing the module from the active memory
Remove-Module Avid.PSUtilities

### Loading the module to the active memory
Import-Module Avid.PSUtilities
#####################################################################################

### Listing all cmdlets from AvidPSUtilities module
Get-Command -Module Avid.PSUtilities

### Set PAM servers nemes list - IPs, as they are not yet in the DNS
$srv_IP = "192.168.30.31","192.168.30.32","192.168.30.33"
$srv = "server1","server2","server3"


###NO DOMAIN
#1. Configuring winrm
winrm quickconfig -force
#2. Adding hosts to trusted hosts
#Get-Item WSMan:\localhost\Client\TrustedHosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value '192.168.30.31,192.168.30.32,192.168.30.33' -Force
#Appending a host to existing list
#Set-Item WSMan:\localhost\Client\TrustedHosts -Value 'machineC' -Concatenate
#############################################################

### NO DOMAIN - Set the credentials to access the servers
$Username = 'administrator'
$Password = 'is-admin19'
$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
#or
$cred = Get-Credential

$ADUsername = 'administrator'
$ADPassword = 'is-admin18'
$ADpass = ConvertTo-SecureString -AsPlainText $Password -Force
$ADCred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass

Invoke-Command -ComputerName $srv_IP -Credential $Cred -ScriptBlock {Set-ItemProperty "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "DisableDomainCreds" -Value 0}
Invoke-Command -ComputerName $srv_IP -Credential $Cred -ScriptBlock {Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "DisableDomainCreds"}

Invoke-Command -ComputerName $srv_IP -Credential $Cred -ScriptBlock {Restart-Computer -force}

Enable-WSManCredSSP –Role Client –DelegateComputer *
Disable-WSManCredSSP -Role Client
###Here we should have a test command sth. like test-WSMan

#If WinRM is not enabled on some computers:
#1) Go to the problematic computer
#2) Run from command line "winrm qc" command