# WindowsDefenderDsc

A collection of DSC resources to manage security mitigations in Windows Defender Security Center

## How to Contribute

Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).

## Resources

* **ProcessMitigation**: Leverages the ProcessMitigations module in (Windows 10 v1709 and newer) to manage process mitigation policies.

## ProcessMitigation

* **MitigationTarget**: Name of the process to apply mitigation settings to.
* **MitigationType**: Type of mitigation to apply to process.
* **MitigationName**: Name of mitigation to apply to process.
* **MitigationValue**: Value of mitigation to apply to process (true/false).

## Versions

### Unreleased

* Update WindowsDefenderDSC Get-TargetResource to return a hashtable

### 2.0.0

* Update WindowsDefenderDSC to use export current state as XML for all settings.

### 1.0.0.0

* Intiial release with the following resources:
  * ProcessMitigation

## Examples

### Enable/Disable process mitigations on SYSTEM and msfeedsync.exe

In the following example configuration, the Non System fonts are disabled on Firefox.exe, while Control Flow Gaurd is enabled on msfeedssync.exe.

```PowerShell
configuration SYSTEM_MSFeedSync
{

    Import-DscResource -ModuleName WindowsDefenderDsc
    node localhost
    {
        ProcessMitigation Firefox
        {
            MitigationTarget = 'firefox.exe'
            MitigationType   = 'fonts'
            MitigationName   = 'DisableNonSystemFonts'
            MitigationValue  = 'true'
        }

        ProcessMitigation msfeedssync
        {
            MitigationTarget = 'msfeedssync.exe'
            MitigationType   = 'ControlFlowGaurd'
            MitigationName   = 'Enable'
            MitigationValue  = 'true'
        }
    }
}

SYSTEM_MSFeedSync -OutputPath 'C:\DSC'

Start-DscConfiguration -Path 'C:\DSC' -Wait -Force -Verbose
```
