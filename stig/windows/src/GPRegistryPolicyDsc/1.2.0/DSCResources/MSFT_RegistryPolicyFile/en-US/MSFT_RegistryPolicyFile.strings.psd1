<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource MSFT_RegistryPolicyFile.
#>
ConvertFrom-StringData -StringData @'
    AddPolicyToFile = Adding policy with Key: {0}, ValueName: {1}, ValueData: {2}, ValueType: {3}. (RPF001)
    RemovePolicyFromFile = Removing policy with Key: {0} ValueName: {1}. (RPF002)
    TranslatingNameToSid = Translating {0} to SID. (RPF003)
    RetrievingCurrentState = Retrieving current for Key {0} ValueName {1}. (RPF04)
    InDesiredState = Resource is in desired state. No refresh required. (RPF05)
    AccountNameNull = No AccountName was provided. (RPF06)
    GptIniCseUpdate = Gpt.ini {0} CSE GUID updated from {1} to {2}. (RPF07)
    GptIniVersionUpdate = Gpt.ini Version updated based on {0} from {1} to {2}. (RPF08)
'@
