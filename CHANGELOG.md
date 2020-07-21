# Changelog
All notable changes to FastTrack will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.2] - 2020-07-21
### Fixed
- Updated Installation procedure in README with a step to bypass the, possibly blocking, Execution Policy.
- Fixed issue with Get-FtProcessorScheduling function. Get-FtProcessorScheduling now treats Win32PrioritySeparation = 0, as a valid option for "Optimized for background services" configuration on Windows Server 2016
- Fixed issue with non-readeable output display of Get-FtServerManagerBehaviorAtLogon function. Get-FtServerManagerBehaviorAtLogon function now uses OpenAtLogon column with Tru/False values.
- Fixed issue with FastTrack.UNINSTALL.ps1 script looking into the wrong directory for installed FastTrack module.
- Fixed issue with non-readeable display of CPU realted information if more then one socket exist. FastTrack now displays the number of socets and the aggregated number of Cores and Logical Processors respectively.

## [0.1.1] - 2020-07-14
### Fixed
- Fixed issue with instalation for administrator user on Windows Server 2016. FastTrack is now installed in 'C:\Program Files\WindowsPowerShell\Modules'

## [0.1.0] - 2020-07-08
### Added
- Initial release
- Includes the below exported functions:
    - 3rd Party Software Related
        - Invoke-FtCMDExpression
    - Avid Software related
        - Install-FtAvidNexisClient
        - Uninstall-FtAvidNexisClient
        - Get-FtAvidSoftware
        - Get-FtAvidServices
    - Diagnostics related
        - Get-FtEventLogErrors
        - Get-FtOSVersion
        - Get-FtHWSpecification
        - Install-FtBGInfo
        - Get-FtUptime
    - Filesystem and Storage realated
        - Get-FtHiddenFilesAndFolders
        - Set-FtHiddenFilesAndFolders
    - Hostname and Domain related
        - Get-FtHostname
        - Set-FtHostname
        - Get-FtDomain
        - Set-FtDomain
    - Module Input/Output related
        - Import-FtSystemConfiguration
    - Network related
        - Get-FtNetworkConfiguration
        - Get-FtFirewallService
        - Start-FtFirewallService
        - Get-FtFirewallState
        - Set-FtFirewallState
    - OS Tweaks related
        - Get-FtServerManagerBehaviorAtLogon
        - Set-FtServerManagerBehaviorAtLogon
        - Get-FtUACLevelForAdmins
        - Set-FtUACLevelForAdmins
        - Get-FtProcessorScheduling
        - Set-FtProcessorScheduling
        - Get-FtPowerPlan
        - Set-FtPowerPlan
    - Remote Access related
        - Test-FtPSRemoting
        - Get-FtRemoteDesktop
        - Set-FtRemoteDesktop
    - Windows Server Roles and Features related
        - Get-FtFailoverClusteringFeature
        - Set-FtFailoverClusteringFeature
    - Time related
        - Get-FtTimeAndTimeZone
    - Windows Update related
        - Get-FtWindowsUpdateService
        - Set-FtWindowsUpdateService

[0.1.2]: https://github.com/karolflont/FastTrack/releases/tag/v0.1.2
[0.1.1]: https://github.com/karolflont/FastTrack/releases/tag/v0.1.1
[0.1.0]: https://github.com/karolflont/FastTrack/releases/tag/v0.1.0