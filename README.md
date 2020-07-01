# FastTrack

Welcome!

FastTrack is a PowerShell module for speeding up the installation and diagnostics process of Avid Windows based systems, i.e. MediaCentral | Production Management and MediaCentral | Asset Management. It heavily leverages parallel commands execution on Windows Servers using WinRM.

---

## Prerequisites

This module is tested with PowerShell 5.1 and Windows Server 2016 OS only. However:
- most functions should work properly on higher versions of PowerShell and Windows Server,
- some functions should work properly on lower versions of PowerShell and Windows Server.

There are no other prerequisites for using this module.

---

## Installing

You can istall FastTrack on either:
- a dedicated Windows based computer with PowerShell 5.1 installed
- one of the servers, you're going to configure/manage using this module

First option is the PREFERRED one, as some of the functions of this module trigger a mass reboot of managed hosts. Using these functions with FastTrack module installed on one of the managed hosts can give undetermined results.

To install the FastTrack module on your computer run FastTrack.INSTALL.ps1 script from an elevated PowerShell prompt (Run as administrator).

WARNING: Installing FastTrack will add all hosts ("*") to the WSMan:\localhost\Client\TrustedHosts. If you already have some hosts defined as WSMan trusted hosts, you have to backup the WSMan:\localhost\Client\TrustedHosts configuration and restore it manually later, as uninstall srtipt will clear the WSMan:\localhost\Client\TrustedHosts. 

To uninstall the FastTrack module on your computer run FastTrack.UNINSTALL.ps1 script from an elevated PowerShell prompt (Run as administrator).

---

## Usage

Check FastTrack.SAMPLE.ps1 for sample usage of this module.

---

## List of functions

3rd Party Software Related

    Invoke-FtCMDExpression

Avid Software related

    Install-FtAvidNexisClient
    Uninstall-FtAvidNexisClient
    Get-FtAvidSoftware
    Get-FtAvidServices

Diagnostics related

    Get-FtEventLogErrors
    Get-FtOSVersion
    Get-FtHWSpecification
    Install-FtBGInfo
    Get-FtUptime 

Filesystem and Storage realated

    Get-FtHiddenFilesAndFolders
    Set-FtHiddenFilesAndFolders

Hostname and Domain related

    Get-FtHostname
    Set-FtHostname
    Get-FtDomain
    Join-FtDomain

Module Input/Output related

    Import-FtSystemConfiguration

Network related

    Get-FtNetworkConfiguration
    Get-FtFirewallService
    Start-FtFirewallService
    Get-FtFirewallState
    Set-FtFirewallState

OS Tweaks related

    Get-FtServerManagerBehaviorAtLogon
    Set-FtServerManagerBehaviorAtLogon
    Get-FtUACLevelForAdmins
    Set-FtUACLevelForAdmins
    Get-FtProcessorScheduling
    Set-FtProcessorScheduling
    Get-FtPowerPlan
    Set-FtPowerPlan

Remote Access related

    Test-FtPowershellRemoting
    Get-FtRemoteDesktop
    Set-FtRemoteDesktop

Windows Server Roles and Features related

    Get-FtFailoverClusteringFeature
    Install-FtFailoverClusteringFeature
    Uninstall-FtFailoverClusteringFeature

Time related

    Get-FtTimeAndTimeZone

Windows Update related

    Get-FtWindowsUpdateService
    Set-FtWindowsUpdateService

---

## Sample System Configuration file

```json
{
    "systemName":"LopDEV",
    "hosts": [
        {
            "IP":"192.168.30.31",
            "hostname":"lop-ie-01",
            "alias":"ie1",
            "role":["PAM","IE"]
        },
        {
            "IP":"192.168.30.32",
            "hostname":"lop-ie-02",
            "alias":"ie2",
            "role":["PAM","IE"]
        },
        {
            "IP":"192.168.30.33",
            "hostname":"lop-mi-01",
            "alias":"mi1",
            "role":["PAM","MI"]
        },
        {
            "IP":"192.168.30.34",
            "hostname":"lop-mi-02",
            "alias":"mi2",
            "role":["PAM","MI"]
        },
        {
            "IP":"192.168.30.35",
            "hostname":"lop-pse",
            "alias":"pse",
            "role":["PAM"]
        },
        {
            "IP":"192.168.30.36",
            "hostname":"lop-tc-01",
            "alias":"tc1",
            "role":["PAM","TC"]
        },
        {
            "IP":"192.168.30.37",
            "hostname":"lop-tc-02",
            "alias":"tc2",
            "role":["PAM","TC"]
        },
        {
            "IP":"192.168.30.38",
            "hostname":"lop-tm-01",
            "alias":"tm1",
            "role":["PAM","TM"]
        },
        {
            "IP":"192.168.30.39",
            "hostname":"lop-tm-02",
            "alias":"tm2",
            "role":["PAM","TM"]
        },
        {
            "IP":"192.168.30.40",
            "hostname":"lop-del",
            "alias":"del",
            "role":["PAM","DEL"]
        },
        {
            "IP":"192.168.30.41",
            "hostname":"lop-cap-01",
            "alias":"cap1",
            "role":["CAP"]
        },
        {
            "IP":"192.168.30.42",
            "hostname":"lop-cap-02",
            "alias":"cap2",
            "role":["CAP"]
        },
        {
            "IP":"192.168.30.43",
            "hostname":"lop-sql",
            "alias":"sql",
            "role":["MAM"]
        },
        {
            "IP":"192.168.30.44",
            "hostname":"lop-app-01",
            "alias":"app1",
            "role":["MAM","APP"]
        },
        {
            "IP":"192.168.30.45",
            "hostname":"lop-app-02",
            "alias":"app2",
            "role":["MAM","APP"]
        }
    ]
}
```

---

## License

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org)

- **[MIT license](http://opensource.org/licenses/mit-license.php)**
- Copyright 2020 © <a>Karol Flont</a>.