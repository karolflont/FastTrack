#
# Module manifest for module 'FastTrack'
#
# Generated by: kflont
#
# Generated on: 2018-08-27
#

@{

    # Script module or binary module file associated with this manifest.
    # RootModule = ''

    # Version number of this module.
    ModuleVersion     = '0.1'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID              = '2e0cd7c0-5600-4d31-90d1-66880389cffb'

    # Author of this module
    Author            = 'Karol Flont'

    # Company or vendor of this module
    # CompanyName = ''

    # Copyright statement for this module
    Copyright         = 'Copyright 2018 Karol Flont
Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
USE OR OTHER DEALINGS IN THE SOFTWARE.'

    # Description of the functionality provided by this module
    Description       = 'Parallel software installation and servers diagnositcs for Avid MediaCentral | Production Management servers'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules     = @(
        '.\scripts\FastTrack.3rdParty.ps1',
        '.\scripts\FastTrack.AvidSoftware.ps1',
        '.\scripts\FastTrack.Diagnostics.ps1',
        '.\scripts\FastTrack.FilesystemAndStorage.ps1',
        '.\scripts\FastTrack.HostnameAndDomain.ps1',
        '.\scripts\FastTrack.InputOutput.ps1',
        '.\scripts\FastTrack.InternalFunctions.ps1',
        '.\scripts\FastTrack.Network.ps1',
        '.\scripts\FastTrack.OSTweaks.ps1',
        '.\scripts\FastTrack.RemoteAccess.ps1',
        '.\scripts\FastTrack.RolesAndFeatures.ps1',
        '.\scripts\FastTrack.Time.ps1',
        '.\scripts\FastTrack.WindowsUpdate.ps1'    
    )

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        #FastTrack.3rdPartySoftware
        'Invoke-FtCMDExpression',
        #FastTrack.AvidSoftware.ps1
        'Install-FtAvidNexisClient',
        'Uninstall-FtAvidNexisClient',
        'Get-FtAvidSoftware',
        'Get-FtAvidServices',
        #FastTrack.Diagnostics.ps1
        'Get-FtEventLogErrors',
        'Get-FtOSVersion',
        'Get-FtHWSpecification',
        'Install-FtBGInfo',
        'Get-FtUptime',
        #FastTrack.FilesystemAndStorage.ps1
        'Get-FtHiddenFilesAndFolders',
        'Set-FtHiddenFilesAndFolders',
        #FastTrack.HostnameAndDomain.ps1
        'Get-FtHostname',
        'Set-FtHostname',
        'Get-FtDomain', 
        'Set-FtDomain',
        #FastTrack.InputOutput
        'Import-FtSystemConfiguration',
        #FastTrack.Network.ps1
        'Get-FtNetworkConfiguration',
        'Get-FtFirewallService',
        'Start-FtFirewallService',
        'Get-FtFirewallState',
        'Set-FtFirewallState',
        #FastTrack.OSTweaks.ps1
        'Get-FtServerManagerBehaviorAtLogon',
        'Set-FtServerManagerBehaviorAtLogon',
        'Get-FtUACLevelForAdmins',
        'Set-FtUACLevelForAdmins',
        'Get-FtProcessorScheduling',
        'Set-FtProcessorScheduling',
        'Get-FtPowerPlan',
        'Set-FtPowerPlan',
        #FastTrack.RemoteAccess.ps1
        'Test-FtPSRemoting',
        'Get-FtRemoteDesktop',
        'Set-FtRemoteDesktop',
        #FastTrack.RolesAndFeatures.ps1
        'Get-FtFailoverClusteringFeature',
        'Install-FtFailoverClusteringFeature',
        'Uninstall-FtFailoverClusteringFeature',
        #FastTrack.Time.ps1
        'Get-FtTimeAndTimeZone',
        #FastTrack.WindowsUpdate.ps1
        'Get-FtWindowsUpdateService',
        'Set-FtWindowsUpdateService'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport   = @()

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            # ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}

