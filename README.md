# FastTrack

Welcome!

FastTrack is a PowerShell module for automated installation, upgrade and troubleshooting of Avid systems based on Windows Server, i.e. MediaCentral | Production Management and MediaCentral | Asset Management. It heavily leverages parallel commands execution on Windows Servers using WinRM.

---

## Prerequisites

This module is tested with PowerShell 5.1 and Windows Server 2016 OS only. However:
- most functions should work properly on later versions of PowerShell and Windows Server,
- some functions should work properly on earlier versions of PowerShell and Windows Server.

There are no other prerequisites for using this module.

---

## Installation

You can istall FastTrack on either:
- a dedicated Windows based computer with PowerShell 5.1 installed
- one of the servers, you're going to configure/manage using this module

First option is the PREFERRED one, as some of the functions of this module trigger a mass restart of managed hosts. Using these functions with FastTrack module installed on one of the managed hosts will result in this host being omitted from the automatic restart and you'll have to restart this host manually.

To install the FastTrack module on your computer:
- open an elevated PowerShell prompt (Run as administrator) (Can be PowerShell ISE as well)
- change your working directory to the directory contatining FastTrack.INSTALL.ps1 file (Do NOT copy this file out of it's directory, as other files in this directory are important as well and have to be in the same directory as FastTrack.INSTALL.ps1 for proper installation)
- run FastTrack.INSTALL.ps1 script

WARNING: Installing FastTrack will add all hosts ("*") to the WSMan:\localhost\Client\TrustedHosts. If you already have some hosts defined as WSMan trusted hosts, these will be backed up and restored automatically when you run FastTrack uninstall script. 

To uninstall the FastTrack module on your computer run FastTrack.UNINSTALL.ps1 script from an elevated PowerShell prompt (Run as administrator).

---

## Usage

Check FastTrack.SAMPLE.ps1 for sample usage of this module. A convinient way to follow this SAMPLE (and to use FastTrack in general) is to open it in PowerShell ISE. This way you can:
- run single lines of FastTrack.SAMPLE.ps1 file by placing a cursor on a selected line and hitting F8
- browse the FastTrack module functions in the PowerShell ISE Commands menu

Note that FastTrack needs a system configuration file for proper function. Please read about how to prepare a config file in the section below.

---

## System Configuration file

FastTrack uses a system configuration file in a .json format which describes the infrastructure you want to manage. You must prepare this file before you start using FastTrack on a particular system.

### Fields descriptions

- systemName - only informational name for your infrastructure configuration

- hosts - list of hosts you want to manage using FastTrack

- IP - IP address of a particular host (you have to set the same address on host before you start using FastTrack)

- hostname - short hostname of a particular host (FastTrack can change the hostname of the remote host according to this entry and will use it frequently in functions output)

- alias - an alias you want to set for a particular host. An alias must be unique among all aliases in the whole configuration

- role - a set of roles a particular server has. One server can have multiple roles and should have at least one

### Sample

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