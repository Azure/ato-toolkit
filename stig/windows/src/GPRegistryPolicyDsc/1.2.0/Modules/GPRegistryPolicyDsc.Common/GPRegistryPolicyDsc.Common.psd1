@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'GPRegistryPolicyDsc.Common.psm1'

    # Version number of this module.
    ModuleVersion     = '1.0.0'

    # ID used to uniquely identify this module
    GUID              = 'f976ae92-b760-407b-ac50-f8d249a547ad'

    # Author of this module
    Author            = 'DSC Community'

    # Company or vendor of this module
    CompanyName       = 'DSC Community'

    # Copyright statement for this module
    Copyright         = 'Copyright the DSC Community contributors. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'Functions used by the DSC resources in GPRegistryPolicyDsc.'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'New-InvalidArgumentException',
        'New-InvalidOperationException',
        'New-ObjectNotFoundException',
        'New-InvalidResultException',
        'New-NotImplementedException'
        'Get-LocalizedData'
        'Test-DscParameterState'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport   = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{
        } # End of PSData hashtable

    } # End of PrivateData hashtable
}
