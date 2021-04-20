# Versions

## 1.3.0.0

- Opted into Common Tests 'Common Tests - Validate Localization' -
  fixes [Issue #31](https://github.com/PlagueHO/FileContentDsc/issues/32).
- Combined all `FileContent.ResourceHelper` module functions into
  `FileContent.Common` module - fixes [Issue #32](https://github.com/PlagueHO/FileContentDsc/issues/32).
- Renamed all localization strings so that they are detected by
  'Common Tests - Validate Localization'.
- Correct style violations in unit tests:
  - Adding `Get`, `Set` and `Test` tags to appropriate `describe` blocks.
  - Removing uneccesary `#region` blocks.
  - Conversion of double quotes to single quotes where possible.
  - Replace variables with string litterals in `describe` block description.
- KeyValuePairFile:
  - Improve unit tests to simplify and cover additional test cases.
  - Fix error occuring when file is empty or does not exist - fixes [Issue #34](https://github.com/PlagueHO/FileContentDsc/issues/34).

## 1.2.0.0

- Added .VSCode settings for applying DSC PSSA rules - fixes [Issue #25](https://github.com/PlagueHO/FileContentDsc/issues/25).
- Added an Encoding parameter to the KeyValuePairFile and ReplaceText
  resources - fixes [Issue #5](https://github.com/PlagueHO/FileContentDsc/issues/5).

## 1.1.0.0

- Enabled PSSA rule violations to fail build - Fixes [Issue #6](https://github.com/PlagueHO/FileContentDsc/issues/6).
- Updated tests to meet Pester v4 standard.
- Added Open Code of Conduct.
- Refactored module folder structure to move resource
  to root folder of repository and remove test harness - Fixes [Issue #11](https://github.com/PlagueHO/FileContentDsc/issues/11).
- Converted Examples to support format for publishing to PowerShell
  Gallery.
- Refactor Test-TargetResource to return $false in all DSC resource - Fixes
  [Issue #12](https://github.com/PlagueHO/FileContentDsc/issues/13).
- Correct configuration names in Examples - fixes [Issue #15](https://github.com/PowerShell/FileContentDsc/issues/15).
- Refactor Test/Set-TargetResource in ReplaceText to be able to add a key if it
  doesn't exist but should -Fixes
  [Issue#20](https://github.com/PlagueHO/FileContentDsc/issues/20).
- Opted into common tests:
  - Common Tests - Validate Example Files To Be Published
  - Common Tests - Validate Markdown Links
  - Common Tests - Relative Path Length
  - Common Tests - Relative Path Length
- Correct test context description in IniSettingsFile tests to include 'When'.
- Change IniSettingsFile unit tests to be non-destructive - fixes [Issue #22](https://github.com/PowerShell/FileContentDsc/issues/22).
- Update to new format LICENSE.

## 1.0.0.0

- DSR_ReplaceText:
  - Created new resource for replacing text in text files.
- DSR_KeyValuePairFile:
  - Created new resource for setting key value pairs in text files.
- DSR_IniSettingsFile:
  - Created new resource for setting Windows INI file settings.
