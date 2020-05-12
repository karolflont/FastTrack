# Avid.PSUtilities

Welcome!

Avid.PSUtilities is a PowerShell module for mass scale deployment and management of Avid MediaCentral | Production Management servers.

---

## Prerequisites

This module is tested with PowerShell 5.1 and Windows Server 2016 OS only. However:
- most functions should work on higher versions of PowerShell and Windows Server,
- some functions will work fine on lower versions of PowerShell and Windows Server.

There are no other prerequisites for using this module.

---

## Installing

You can istall Avid.PSUtilities on either:
- a dedicated Windows based computer with PowerShell 5.1 installed
- one of the servers, you're going to configure/manage using this module

First option is the PREFERRED one, as some of the functions of this module trigger a mass reboot of managed hosts. Using these functions with Avid.PSUtilities module installed on one of the mnaged hosts can give undetermined results.

To install the Avid.PSUtilities module on your computer run Avid.PSU.INSTALL.ps1 script from a PowerShell session with elevated privileges.

WARNING: Installing AvidPS.Utilities will add all hosts ("*") to the WSMan:\localhost\Client\TrustedHosts. If you already have some hosts defined as WSMan trusted hosts, you have to backup the WSMan:\localhost\Client\TrustedHosts configuration and restore it manually later.

To uninstall the Avid.PSUtilities module on your computer run Avid.PSU.UNINSTALL.ps1 script from a PowerShell session with elevated privileges.

---

## Usage

Check Avid.PSU.SAMPLE.ps1 for sample usage of this module.

---

## List of functions

3rd Party Software Related

    Invoke-AvCMDExpression

Avid Software related

    Install-AvNexisClient
    Uninstall-AvNexisClient
    Get-AvSoftwareVersions
    Get-AvServicesStatus

Diagnostics related

    Get-AvEventLogErrors
    Get-AvOSVersion
    Get-AvHWSpecification
    Install-AvBGInfo
    Get-AvUptime 

Filesystem and Storage realated

    Get-AvHiddenFilesAndFoldersStatus
    Set-AvHiddenFilesAndFolders

Firewall and Defender related

    Get-AvFirewallStatus
    Set-AvFirewall
    Get-AvDefenderStatus
    Set-AvDefender
    Install-AvDefender
    Uninstall-AvDefender

Hostname and Domain related

    Get-AvHostname
    Set-AvHostname
    Get-AvDomain
    Join-AvDomain

Module Input/Output related

    Import-AvSystemConfiguration

Network related

    Get-AvNetworkInfo

OS Tweaks related

    Get-AvServerManagerBehaviorAtLogon
    Set-AvServerManagerBehaviorAtLogon
    Get-AvUACLevel
    Set-AvUACLevel
    Get-AvProcessorScheduling
    Set-AvProcessorScheduling
    Get-AvPowerPlan
    Set-AvPowerPlan

Remote Access related

    Test-AvPowershellRemoting
    Get-AvRemoteDesktopStatus
    Set-AvRemoteDesktop

Windows Server Roles and Features related

    Install-AvFailoverClusteringFeature

Time related

    Get-AvTimeAndTimeZone

Windows Update related

    Get-AvWindowsUpdateServiceStatus
    Set-AvWindowsUpdateService

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