# Coffee Break

Welcome!

CoffeeBreak is a PowerShell module for parallel software installation and servers diagnositcs for Avid MediaCentral | Production Management servers.
The aim of the project is to speed up the process Avid MediaCentral | Production Management system installation and diagnostics.


---

## Prerequisites

This module is tested with PowerShell 5.1 and Windows Server 2016 OS only. However:
- most functions should work on higher versions of PowerShell and Windows Server,
- some functions will work fine on lower versions of PowerShell and Windows Server.

There are no other prerequisites for using this module.

---

## Installing

You can istall CoffeeBreak on either:
- a dedicated Windows based computer with PowerShell 5.1 installed
- one of the servers, you're going to configure/manage using this module

First option is the PREFERRED one, as some of the functions of this module trigger a mass reboot of managed hosts. Using these functions with CoffeeBreak module installed on one of the managed hosts can give undetermined results.

To install the CoffeeBreak module on your computer run CoffeeBreak.INSTALL.ps1 script from an elevated PowerShell prompt (Run as administrator).

WARNING: Installing CoffeeBreak will add all hosts ("*") to the WSMan:\localhost\Client\TrustedHosts. If you already have some hosts defined as WSMan trusted hosts, you have to backup the WSMan:\localhost\Client\TrustedHosts configuration and restore it manually later, as uninstall srtipt will clear the WSMan:\localhost\Client\TrustedHosts. 

To uninstall the CoffeeBreak module on your computer run CoffeeBreak.UNINSTALL.ps1 script from an elevated PowerShell prompt (Run as administrator).

---

## Usage

Check CoffeeBreak.SAMPLE.ps1 for sample usage of this module.

---

## List of functions

3rd Party Software Related

    Invoke-CbCMDExpression

Avid Software related

    Install-CbNexisClient
    Uninstall-CbNexisClient
    Get-CbSoftwareVersions
    Get-CbServicesStatus

Diagnostics related

    Get-CbEventLogErrors
    Get-CbOSVersion
    Get-CbHWSpecification
    Install-CbBGInfo
    Get-CbUptime 

Filesystem and Storage realated

    Get-CbHiddenFilesAndFoldersStatus
    Set-CbHiddenFilesAndFolders

Firewall and Defender related

    Get-CbFirewallStatus
    Set-CbFirewall
    Get-CbDefenderStatus
    Set-CbDefender
    Install-CbDefender
    Uninstall-CbDefender

Hostname and Domain related

    Get-CbHostname
    Set-CbHostname
    Get-CbDomain
    Join-CbDomain

Module Input/Output related

    Import-CbSystemConfiguration

Network related

    Get-CbNetworkInfo

OS Tweaks related

    Get-CbServerManagerBehaviorAtLogon
    Set-CbServerManagerBehaviorAtLogon
    Get-CbUACLevel
    Set-CbUACLevel
    Get-CbProcessorScheduling
    Set-CbProcessorScheduling
    Get-CbPowerPlan
    Set-CbPowerPlan

Remote Access related

    Test-CbPowershellRemoting
    Get-CbRemoteDesktopStatus
    Set-CbRemoteDesktop

Windows Server Roles and Features related

    Get-CbFailoverClusteringFeature
    Install-CbFailoverClusteringFeature
    Uninstall-CbFailoverClusteringFeature

Time related

    Get-CbTimeAndTimeZone

Windows Update related

    Get-CbWindowsUpdateServiceStatus
    Set-CbWindowsUpdateService

---

## Sample System Configuration files

### Basic configuration file
```json
{
    "systemName":"DEV",
    "hosts": [
        {
            "IP":"192.168.30.31",
            "hostname":"lop-ie2",
            "alias":"ie",
            "role":["PAM","IE"]
        },
        {
            "IP":"192.168.30.32",
            "hostname":"lop-tc-01",
            "alias":"tc1",
            "role":["PAM","TRC"]
        },
        {
            "IP":"192.168.30.33",
            "hostname":"lop-tc-02",
            "alias":"tc2",
            "role":["PAM","TRC"]
        }
    ]
}
```

### Advanced configuration file
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
        }
    ],
    "domain":{
        "mainSuffix":"lop.prm",
        "additionalSuffixes":[],
        "DNSServers":[
            {
                "IP":"192.168.30.71",
                "alias":"dc1",
                "role":["DC"]
            },
            {
                "IP":"192.168.30.72",
                "alias":"dc2",
                "role":["DC"]
            }
        ]
    },
    "timesync":{
        "inhouseSources": ["192.168.30.71"],
        "AvidSystemPrimaryMaster": "",
        "AvidSystemSecondaryMaster": ""
    }
}
```

---

## License

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org)

- **[MIT license](http://opensource.org/licenses/mit-license.php)**
- Copyright 2020 © <a>Karol Flont</a>.