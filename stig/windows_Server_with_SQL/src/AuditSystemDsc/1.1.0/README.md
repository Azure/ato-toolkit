# AuditSystemDsc

This resource module contains resources used to audit system settings/verify compliance.

This project has adopted [this code of conduct](CODE_OF_CONDUCT.md).

## Branches

### master

[![Build status](https://ci.appveyor.com/api/projects/status/github/jcwalker/AuditSystemDsc?branch=master&svg=true)](https://ci.appveyor.com/project/jcwalker/AuditSystemDsc/branch/master)
[![codecov](https://codecov.io/gh/jcwalker/AuditSystemDsc/branch/master/graph/badge.svg)](https://codecov.io/gh/PowerShell/DscResource.Template/branch/master)

This is the branch containing the latest release -
no contributions should be made directly to this branch.

### dev

[![Build status](https://ci.appveyor.com/api/projects/status/github/jcwalker/AuditSystemDsc?branch=dev&svg=true)](https://ci.appveyor.com/project/jcwalker/AuditSystemDsc/branch/dev)
[![codecov](https://codecov.io/gh/jcwalker/AuditSystemDsc/branch/dev/graph/badge.svg)](https://codecov.io/gh/jcwalker/AuditSystemDsc/branch/dev)

This is the development branch to which contributions should be proposed
by contributors as pull requests.
This development branch will periodically be merged to the master branch,
and be released to [PowerShell Gallery](https://www.powershellgallery.com/).

## Contributing

Please see our [contributing guidelines](/CONTRIBUTING.md).

## Installation

### GitHub

To manually install the module,
download the source code and unzip the contents to the directory
'$env:ProgramFiles\WindowsPowerShell\Modules' folder.

### PowerShell Gallery

To install from the PowerShell gallery using PowerShellGet (in PowerShell 5.0)
run the following command:

```powershell
Find-Module -Name AuditSystemDsc -Repository PSGallery | Install-Module
```

To confirm installation, run the below command and ensure you see the
DSC resources available:

```powershell
Get-DscResource -Module AuditSystemDsc
```

## Requirements

The minimum Windows Management Framework (PowerShell) version required is 4.0
or higher.

## Examples

You can review the [Examples](/Examples) directory for some general use
scenarios for all of the resources that are in the module.

## Change log

A full list of changes in each version can be found in the [change log](CHANGELOG.md).

## Resources

* [**AuditSetting**](#AuditSetting) A resource the leverages CIM classes
  to verify system settings.

### AuditSetting

A resource the leverages CIM classes to verify system settings.

#### Requirements

* Target machine must have the CIM cmdlets installed.

#### Parameters

* **`[String]` NameSpace**: Specifies the namespace of CIM class.
* **`[String]` Query** _(Key)_: A WQL query used to retrieve the setting to be audited.
* **`[String]` Property** _(Key)_: The property name to be audited.
* **`[String]` DesiredValue** _(Key)_: Specifies the desired value
  of the property being audited.
* **`[String]` Operator** _(Required)_: The comparison operator to be used
  to craft the condition that defines compliance.

#### Read-Only Properties from Get-TargetResource

* **`[String[]]` ResultString** _(Read)_: An array of strings listing
  all the properties and values of the WMI class being queried.

#### Examples

* [Audit disk volumnes are NTFS](/Examples/Resources/AuditSetting/1-AuditSetting_AuditVolumneNtfs.ps1)
* [Audit local users that don't require a password](/Examples/Resources/AuditSetting/2-AuditSetting_AuditUsersPasswordNotRequired.ps1)
* [Verify netowrk prefix length](/Examples/Resources/AuditSetting/3-AuditSetting_VerifyNetworkPrefixLength.ps1)
* [Verify service pack level](/Examples/Resources/AuditSetting/4-AuditSetting_VerifyServicePackLevel.ps1)

#### Known issues

All issues are not listed here, see [here for all open issues](https://github.com/jcwalker/AuditSystemDsc/issues?utf8=%E2%9C%93&q=is%3Aissue+is%3Aopen+Folder).
