@{
  # Version number of this module.
  moduleVersion = '1.2.0'

  # ID used to uniquely identify this module
  GUID = 'fcded2c6-6ba2-4d6c-a35e-55848f90462b'

  # Author of this module
  Author = 'DSC Community'

  # Company or vendor of this module
  CompanyName = 'DSC Community'

  # Copyright statement for this module
  Copyright = 'Copyright the DSC Community contributors. All rights reserved.'

  # Description of the functionality provided by this module
  Description = 'This resource module contains DSC resources used to apply and manage local group policies by modifying the respective .pol file.'

  # Minimum version of the Windows PowerShell engine required by this module
  PowerShellVersion = '5.0'

  # Minimum version of the common language runtime (CLR) required by this module
  CLRVersion = '4.0'

  # Functions to export from this module
  FunctionsToExport = @()

  # Cmdlets to export from this module
  CmdletsToExport = @()

  # Variables to export from this module
  VariablesToExport = @()

  # Aliases to export from this module
  AliasesToExport = @()

  # DSC resources to export from this module
  DscResourcesToExport = @(
      'RefreshRegistryPolicy'
      'RegistryPolicyFile'
  )

  # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
  PrivateData = @{

      PSData = @{
          Prerelease = ''

          # Tags applied to this module. These help with module discovery in online galleries.
          Tags = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

          # A URL to the license for this module.
          LicenseUri = 'https://github.com/dsccommunity/GPRegistryPolicyDsc/blob/master/LICENSE'

          # A URL to the main website for this project.
          ProjectUri = 'https://github.com/dsccommunity/GPRegistryPolicyDsc'

          # ReleaseNotes of this module
          ReleaseNotes = '## [1.2.0] - 2020-03-13

### Added

- GPRegistryPolicyDsc
  - Add support to upload coverage to Codecov.io ([issue #16](https://github.com/dsccommunity/GPRegistryPolicyDsc/issues/16)).

### Fixed

- GPRegistryPolicyDsc
  - Update GitVersion.yml with the correct regular expression.
  - Added GPT.ini creation/updating logic in order to properly apply Group Policy.

### Changed

- GPRegistryPolicyDsc
  - Set a display name on all the jobs and tasks in the CI pipeline.
  - Change the Azure Pipelines Microsoft Host Agents to use the image 
    `windows-2019` ([issue #15](https://github.com/dsccommunity/GPRegistryPolicyDsc/issues/15)).

## [1.1.0] - 2020-01-05

### Added

- GPRegistryPolicyDsc
  - Added continuous delivery with a new CI pipeline.

## [1.0.1] - 2019-09-29

- Fixed [#3](https://github.com/dsccommunity/GPRegistryPolicyDsc/issues/3)
- Updated release logic to not include .git folder.

## [1.0.0] - 2019-09-18

- Initial release.

'

      } # End of PSData hash table

  } # End of PrivateData hash table
}





