
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

@{
    # Version number of this module.
    ModuleVersion = '1.4.1'

    # ID used to uniquely identify this module
    GUID = 'a544c26f-3f96-4c1e-8351-1604867aafc5'

    # Author of this module
    Author = 'Microsoft Corporation'

    # Company or vendor of this module
    CompanyName = 'Microsoft Corporation'

    # Copyright statement for this module
    Copyright = '(c) 2017 Microsoft. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Module with DSC resource to manage Registry and NTFS access entries and manage Active Directory SACL'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '4.0'

    # Functions to export from this module
    FunctionsToExport = @()

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource',
                     'AccessControlDsc', 'DACL', 'SACL', 'Permissions')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/mcollera/AccessControlDsc/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/mcollera/AccessControlDsc'
        }
    }
}
