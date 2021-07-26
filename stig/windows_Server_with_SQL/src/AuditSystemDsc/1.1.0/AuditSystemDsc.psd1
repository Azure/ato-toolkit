@{

# Version number of this module.
ModuleVersion = '1.1.0'

# ID used to uniquely identify this module
GUID = '4e702818-a3b0-4a19-a8f1-92341a2a734a'

# Author of this module
Author = 'Jason Walker'

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = '(c) 2019 Jason Walker. All rights reserved.'

# Description of the functionality provided by this module
Description = 'This module contains resources used to audit system settings/verify compliance.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = '4.0'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{
        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('DesiredStateConfiguration', 'DSC', 'Audit', 'Compliance', 'DSCResource')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/jcwalker/AuditSystemDsc/blob/dev/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/jcwalker/AuditSystemDsc'

        # ReleaseNotes of this module
        ReleaseNotes = '* Added NameSpace parameter to AuditSetting [#8](https://github.com/jcwalker/AuditSystemDsc/issues/8)
        * Add example demonstrating how to assert service pack level.'

    } # End of PSData hash table

} # End of PrivateData hash table

}
