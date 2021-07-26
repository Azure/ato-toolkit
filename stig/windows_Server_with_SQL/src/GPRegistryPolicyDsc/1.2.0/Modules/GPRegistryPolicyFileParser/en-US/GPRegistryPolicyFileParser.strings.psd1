<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        GPRegistryPolicyFileParser module.
#>
ConvertFrom-StringData -StringData @'
    InvalidHeader = File '{0}' has an invalid header. (RPP001)
    InvalidVersion = File '{0}' has an invalid version. It should be 1. (RPP002)
    InvalidIntegerSize = Invalid size for an integer. Must be less than or equal to 8. (RPP003)
    MissingOpeningBracket = Missing the openning bracket. (RPP004)
    MissingTrailingSemicolonAfterKey = Failed to locate the semicolon after key name. (RPP005)
    MissingTrailingSemicolonAfterName = Failed to locate the semicolon after value name. (RPP006)
    MissingTrailingSemicolonAfterType = Failed to locate the semicolon after value type. (RPP007)
    MissingTrailingSemicolonAfterLength = Failed to locate the semicolon after value length. (RPP008)
    MissingClosingBracket = Missing the closing bracket. (RPP009)
    CreateNewPolFile = Creating new pol file at {0}. (RPP010)
    GPRegistryPolicyExists = Registry policy already exists with Key: {0}, ValueName: {1}, ValueData: {2}. (RPP011)
    NoMatchingPolicies = No matching registry policies found. (RPP012)
'@
