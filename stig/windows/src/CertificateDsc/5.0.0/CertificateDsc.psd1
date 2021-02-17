@{
    # Version number of this module.
    moduleVersion        = '5.0.0'

    # ID used to uniquely identify this module
    GUID                 = '1b8d785e-79ae-4d95-ae58-b2460aec1031'

    # Author of this module
    Author               = 'DSC Community'

    # Company or vendor of this module
    CompanyName          = 'DSC Community'

    # Copyright statement for this module
    Copyright            = 'Copyright the DSC Community contributors. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'DSC resources for managing certificates on a Windows Server.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '4.0'

    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion           = '4.0'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = @()

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport      = @()

    # DSC resources to export from this module
    DscResourcesToExport = @(
        'CertificateExport'
        'CertificateImport'
        'CertReq'
        'PfxImport'
        'WaitForCertificateServices'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{
        PSData = @{
            # Set to a prerelease string value if the release should be a prerelease.
            Prerelease   = ''

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('DesiredStateConfiguration', 'DSC', 'DSCResource', 'Certificate', 'PKI')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/dsccommunity/CertificateDsc/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/dsccommunity/CertificateDsc'

            # A URL to an icon representing this module.
            IconUri      = 'https://dsccommunity.org/images/DSC_Logo_300p.png'

            # ReleaseNotes of this module
            ReleaseNotes = '## [5.0.0] - 2020-10-16

### Changed

- Corrected incorrectly located entries in `CHANGELOG.MD`.
- Fix bug `Find-Certificate` when invalid certificate path is passed - fixes
  [Issue #208](https://github.com/dsccommunity/CertificateDsc/issues/208).
- CertReq:
  - Added `Get-CertificateCommonName` function as a fix for multiple
    certificates being issued when having a third party CA which doesn''t
    format the Issuer CN in the same order as a MS CA - fixes [Issue #207](https://github.com/dsccommunity/CertificateDsc/issues/207).
  - Updated `Compare-CertificateIssuer` to use the new
    `Get-CertificateCommonName` function.
  - Added check for X500 subject name in Get-TargetResource, which already
    exists in Test- and Set-TargetResource - fixes [Issue #210](https://github.com/dsccommunity/CertificateDsc/issues/210).
  - Corrected name of working path to remove `x` - fixes [Issue #211](https://github.com/dsccommunity/CertificateDsc/issues/211).
- BREAKING CHANGE: Changed resource prefix from MSFT to DSC.
- Updated to use continuous delivery pattern using Azure DevOps - Fixes
  [Issue #215](https://github.com/dsccommunity/CertificateDsc/issues/215).
- Updated Examples and Module Manifest to be DSC Community from Microsoft.
- Fix style issues in `Certificate.PDT` and `Certificate.Common` modules.
- Update badges in README.MD to refer to correct pipeline.
- Correct version number in `GitVersion.yml` file.
- Change Azure DevOps Pipeline definition to include `source/*` - Fixes [Issue #226](https://github.com/dsccommunity/CertificateDsc/issues/226).
- Updated pipeline to use `latest` version of `ModuleBuilder` - Fixes [Issue #226](https://github.com/dsccommunity/CertificateDsc/issues/226).
- Merge `HISTORIC_CHANGELOG.md` into `CHANGELOG.md` - Fixes [Issue #227](https://github.com/dsccommunity/CertificateDsc/issues/227).
- Fixed build failures caused by changes in `ModuleBuilder` module v1.7.0
  by changing `CopyDirectories` to `CopyPaths` - Fixes [Issue #230](https://github.com/dsccommunity/CertificateDsc/issues/230).
- Updated to use the common module _DscResource.Common_ - Fixes [Issue #229](https://github.com/dsccommunity/CertificateDsc/issues/229).
- Pin `Pester` module to 4.10.1 because Pester 5.0 is missing code
  coverage - Fixes [Issue #233](https://github.com/dsccommunity/CertificateDsc/issues/233).
- Added a catch for certreq generic errors which fixes [Issue #224](https://github.com/dsccommunity/CertificateDsc/issues/224)
- CertificateDsc
  - Automatically publish documentation to GitHub Wiki - Fixes [Issue #235](https://github.com/dsccommunity/CertificateDsc/issues/235).

### Added

- PfxImport:
  - Added example showing importing private key using `PsDscRunAsCredential`
    to specify an administrator account - Fixes [Issue #213](https://github.com/dsccommunity/CertificateDsc/issues/213).

'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}



