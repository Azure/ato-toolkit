@{
    # Script module or binary module file associated with this manifest.
    RootModule        = 'GPRegistryPolicyFileParser.psm1'

    # Version number of this module.
    ModuleVersion     = '1.0'

    # ID used to uniquely identify this module
    GUID              = '0223a0e8-85ac-4803-a127-585e547f34a8'

    # Author of this module
    Author            = 'Zia Jalali, PowerSTIG Team'

    # Company or vendor of this module
    CompanyName       = 'Microsoft'

    # Copyright statement for this module
    Copyright         = '(c) 2019 Microsoft. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'These cmdlets will allow you to work with .POL files, which contain the registry keys enacted by Group Policy.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Cmdlets to export from this module
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport   = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Read-GPRegistryPolicyFile'
        'New-GPRegistryPolicy'
        'New-GPRegistryPolicyFile'
        'New-GPRegistrySettingsEntry'
        'Set-GPRegistryPolicyFileEntry'
        'Remove-GPRegistryPolicyFileEntry'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{
        PSData = @{

        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
