using module ..\..\Modules\GPRegistryPolicyFileParser
$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'
$script:resourceHelperModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'GPRegistryPolicyDsc.Common'
$script:GPRegistryPolicyFileParserModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'GPRegistryPolicyFileParser'
Import-Module -Name (Join-Path -Path $script:resourceHelperModulePath -ChildPath 'GPRegistryPolicyDsc.Common.psm1')
Import-Module -Name (Join-Path -Path $script:GPRegistryPolicyFileParserModulePath -ChildPath 'GPRegistryPolicyFileParser.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_RegistryPolicyFile'

<#
    .SYNOPSIS
        Returns the current state of the registry policy file.

    .PARAMETER Key
        Indicates the path of the registry key for which you want to ensure a specific state. This path must include the hive.

    .PARAMETER ValueName
        Indicates the name of the registry value.

    .PARAMETER TargetType
        Indicates the target type. This is needed to determine the .pol file path. Supported values are LocalMachine, User, Administrators, NonAdministrators, Account.

    .PARAMETER AccountName
        Specifies the name of the account for an user specific pol file to be managed.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ValueName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('ComputerConfiguration','UserConfiguration','Administrators','NonAdministrators','Account')]
        [System.String]
        $TargetType,

        [Parameter()]
        [AllowNull()]
        [System.String]
        $AccountName
    )

    Write-Verbose -Message ($script:localizedData.RetrievingCurrentState -f $Key, $ValueName)
    # determine pol file path
    $polFilePath = Get-RegistryPolicyFilePath -TargetType $TargetType -AccountName $AccountName
    $assertPolFile = Test-Path -Path $polFilePath

    # read the pol file
    if ($assertPolFile -eq $true)
    {
        $polFileContents = Read-GPRegistryPolicyFile -Path $polFilePath
        $currentResults  = $polFileContents | Where-Object -FilterScript {$PSItem.Key -eq $Key -and $PSItem.ValueName -eq $ValueName}
    }

    # determine if the key is present or not
    if ($null -eq $currentResults.ValueName)
    {
        $ensureResult = 'Absent'
    }
    else
    {
        $ensureResult = 'Present'
        $valueTypeResult = $currentResults.GetRegTypeString()
    }

    # resolve account name
    $polFilePathArray = $polFilePath -split '\\'
    $system32Index = $polFilePathArray.IndexOf('System32')
    $accountNameFromPath = $polFilePathArray[$system32Index+2]

    if ($accountNameFromPath -match '^S-1-')
    {
        $accountNameResult = ConvertTo-NTAccountName -SecurityIdentifier $accountNameFromPath
    }
    else
    {
        $accountNameResult = $accountNameFromPath
    }

    # return the results
    $getTargetResourceResult = @{
        Key         = $Key
        ValueName   = $ValueName
        ValueData   = [System.String[]] $currentResults.ValueData
        ValueType   = $valueTypeResult
        TargetType  = $TargetType
        Ensure      = $ensureResult
        Path        = $polFilePath
        AccountName = $accountNameResult
    }

    return $getTargetResourceResult
}

<#
    .SYNOPSIS
        Adds or removes the policy key in the pol file.

    .PARAMETER Key
        Indicates the path of the registry key for which you want to ensure a specific state. This path must include the hive.

    .PARAMETER ValueName
        Indicates the name of the registry value.

    .PARAMETER ValueData
        The data for the registry value.

    .PARAMETER ValueType
        Indicates the type of the value.

    .PARAMETER TargetType
        Indicates the target type. This is needed to determine the .pol file path. Supported values are LocalMachine, User, Administrators, NonAdministrators, Account.

    .PARAMETER AccountName
        Specifies the name of the account for an user specific pol file to be managed.

    .PARAMETER Ensure
        Specifies the desired state of the registry policy. When set to 'Present', the registry policy will be created. When set to 'Absent', the registry policy will be removed. Default value is 'Present'.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ValueName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('ComputerConfiguration','UserConfiguration','Administrators','NonAdministrators','Account')]
        [System.String]
        $TargetType,

        [Parameter()]
        [System.String[]]
        $ValueData,

        [Parameter()]
        [ValidateSet('Binary','Dword','ExpandString','MultiString','Qword','String','None')]
        [System.String]
        $ValueType,

        [Parameter()]
        [System.String]
        $AccountName,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $getTargetResourceParameters = @{
        Key         = $Key
        TargetType  = $TargetType
        ValueName   = $ValueName
        AccountName = $AccountName
    }

    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters
    $polFilePath = Get-RegistryPolicyFilePath -TargetType $TargetType -AccountName $AccountName
    $gpRegistryEntry = New-GPRegistryPolicy -Key $Key -ValueName $ValueName -ValueData $ValueData -ValueType ([GPRegistryPolicy]::GetRegTypeFromString($ValueType))

    if ($Ensure -eq 'Present')
    {
        if ($getTargetResourceResult.Ensure -eq 'Absent')
        {
            $assertPolFile = Test-Path -Path $polFilePath

            if ($assertPolFile -eq $false)
            {
                # create the pol file
                New-GPRegistryPolicyFile -Path $polFilePath
            }
        }
        # write the desired value
        Write-Verbose -Message ($script:localizedData.AddPolicyToFile -f $Key, $ValueName, $ValueData, $ValueType)
        Set-GPRegistryPolicyFileEntry -Path $polFilePath -RegistryPolicy $gpRegistryEntry
    }
    else
    {
        if ($getTargetResourceResult.Ensure -eq 'Present')
        {
            Write-Verbose -Message ($script:localizedData.RemovePolicyFromFile -f $Key, $ValueName)
            Remove-GPRegistryPolicyFileEntry -Path $polFilePath -RegistryPolicy $gpRegistryEntry
        }
    }

    # write the gpt.ini update
    $setGptIniFileParams = @{
        TargetType = $TargetType
    }
    if ($PSBoundParameters.ContainsKey('AccountName'))
    {
        $setGptIniFileParams.AccountName = $AccountName
    }

    Set-GptIniFile @setGptIniFileParams
    Set-RefreshRegistryKey
}

<#
    .SYNOPSIS
        Tests for the desired state of the policy key in the pol file.

    .PARAMETER Key
        Indicates the path of the registry key for which you want to ensure a specific state. This path must include the hive.

    .PARAMETER ValueName
        Indicates the name of the registry value.

    .PARAMETER ValueData
        The data for the registry value.

    .PARAMETER ValueType
        Indicates the type of the value.

    .PARAMETER TargetType
        Indicates the target type. This is needed to determine the .pol file path. Supported values are LocalMachine, User, Administrators, NonAdministrators, Account.

    .PARAMETER AccountName
        Specifies the name of the account for an user specific pol file to be managed.

    .PARAMETER Ensure
        Specifies the desired state of the registry policy. When set to 'Present', the registry policy will be created. When set to 'Absent', the registry policy will be removed. Default value is 'Present'.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ValueName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('ComputerConfiguration','UserConfiguration','Administrators','NonAdministrators','Account')]
        [System.String]
        $TargetType,

        [Parameter()]
        [System.String[]]
        $ValueData,

        [Parameter()]
        [ValidateSet('Binary','Dword','ExpandString','MultiString','Qword','String','None')]
        [System.String]
        $ValueType,

        [Parameter()]
        [System.String]
        $AccountName,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $getTargetResourceParameters = @{
        Key         = $Key
        TargetType  = $TargetType
        ValueName   = $ValueName
        AccountName = $AccountName
    }

    $testTargetResourceResult = $false

    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

    if ($Ensure -eq 'Present')
    {
        $valuesToCheck = @(
            'Key'
            'ValueName'
            'TargetType'
            'ValueData'
            'ValueType'
            'Ensure'
        )

        $testTargetResourceResult = Test-DscParameterState -CurrentValues $getTargetResourceResult -DesiredValues $PSBoundParameters -ValuesToCheck $valuesToCheck
    }
    else
    {
        if ($Ensure -eq $getTargetResourceResult.Ensure)
        {
            Write-Verbose -Message ($script:localizedData.InDesiredState)
            $testTargetResourceResult = $true
        }
    }

    return $testTargetResourceResult
}

<#
    .SYNOPSIS
        Retrieves the path to the pol file.

    .PARAMETER TargetType
        Indicates the target type. This is needed to determine the .pol file path. Supported values are LocalMachine, User, Administrators, NonAdministrators, Account.

    .PARAMETER AccountName
        Specifies the name of the account for an user specific pol file to be managed.
#>
function Get-RegistryPolicyFilePath
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('ComputerConfiguration','UserConfiguration','Administrators','NonAdministrators','Account')]
        [System.String]
        $TargetType,

        [Parameter()]
        [System.String]
        $AccountName
    )

    switch ($TargetType)
    {
        'ComputerConfiguration'
        {
            $childPath = 'System32\GroupPolicy\Machine\registry.pol'
        }
        'UserConfiguration'
        {
            $childPath = 'System32\GroupPolicy\User\registry.pol'
        }
        'Administrators'
        {
            $childPath = 'System32\GroupPolicyUsers\S-1-5-32-544\User\registry.pol'
        }
        'NonAdministrators'
        {
            $childPath = 'System32\GroupPolicyUsers\S-1-5-32-545\User\registry.pol'
        }
        'Account'
        {
            if ([System.String]::IsNullOrEmpty($AccountName))
            {
                throw $script:localizedData.AccountNameNull
            }

            $sid = ConvertTo-SecurityIdentifier -AccountName $AccountName
            $childPath = "System32\GroupPolicyUsers\$sid\User\registry.pol"
        }
    }

    return (Join-Path -Path $env:SystemRoot -ChildPath $childPath)
}

<#
    .SYNOPSIS
        Converts an identity to a SID to verify it's a valid account.

    .PARAMETER AccountName
        Specifies the identity to convert.
#>
function ConvertTo-SecurityIdentifier
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $AccountName
    )

    Write-Verbose -Message ($script:localizedData.TranslatingNameToSid -f $AccountName)
    $id = [System.Security.Principal.NTAccount] $AccountName

    return $id.Translate([System.Security.Principal.SecurityIdentifier]).Value
}

<#
    .SYNOPSIS
        Converts a SID to an NTAccount name.

    .PARAMETER SecurityIdentifier
        Specifies SID of the identity to convert.
#>
function ConvertTo-NTAccountName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Security.Principal.SecurityIdentifier]
        $SecurityIdentifier
    )

    $identiy = [System.Security.Principal.SecurityIdentifier] $SecurityIdentifier

    return $identiy.Translate([System.Security.Principal.NTAccount]).Value
}

<#
    .SYNOPSIS
        Writes a registry key indicating a group policy refresh is required.

    .PARAMETER Path
        Specifies the value of the registry path that will contain the properties pertaining to requiring a refresh.

    .PARAMETER PropertyName
        Specifies a name for the new property.

    .PARAMETER Value
        Specifies the property value.
#>
function Set-RefreshRegistryKey
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $Path = 'HKLM:\SOFTWARE\Microsoft\GPRegistryPolicy',

        [Parameter()]
        [System.String]
        $PropertyName = 'RefreshRequired',

        [Parameter()]
        [System.Object]
        $Value = 1
    )

    New-Item -Path $Path -Force
    New-ItemProperty -Path $Path -Name $PropertyName -Value $Value -Force
}

<#
    .SYNOPSIS
        Sets the gpt.ini file according to user/computer policy changes.

    .PARAMETER TargetType
        Indicates the target type. This is needed to determine the gpt.ini file path. Supported values are LocalMachine, User, Administrators, NonAdministrators, Account.

    .PARAMETER AccountName
        Specifies the name of the account for an user specific gpt.ini file to be managed.
#>
function Set-GptIniFile
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('ComputerConfiguration','UserConfiguration','Administrators','NonAdministrators','Account')]
        [System.String]
        $TargetType,

        [Parameter()]
        [System.String]
        $AccountName
    )

    $registryPolicyPath = Split-Path -Path (Get-RegistryPolicyFilePath @PSBoundParameters) -Parent | Split-Path -Parent
    $gptIniPath = Join-Path -Path $registryPolicyPath -ChildPath 'gpt.ini'

    $extensionNamesPattern = '{35378EAC-683F-11D2-A89A-00C04FBBCFA2}.*{D02B1F7[2|3]-3407-48AE-BA88-E8213C6761F1}'
    $extensionHashtable = @{
        gPCMachineExtensionNames = '35378EAC-683F-11D2-A89A-00C04FBBCFA2', 'D02B1F72-3407-48AE-BA88-E8213C6761F1'
        gPCUserExtensionNames    = '35378EAC-683F-11D2-A89A-00C04FBBCFA2', 'D02B1F73-3407-48AE-BA88-E8213C6761F1'
    }

    # Detect gPCMachineExtensionNames/gPCUserExtensionNames presence and value
    foreach ($gPCItem in $extensionHashtable.Keys)
    {
        $gptEntry = Get-PrivateProfileString -AppName 'General' -KeyName $gPCItem -GptIniPath $gptIniPath
        if (-not ($gptEntry -match $extensionNamesPattern))
        {
            if ($gptEntry -ne [String]::Empty)
            {
                $gPCExistingValue = $gptEntry -replace '\[{|}]' -split '}{'
                $gPCNewValue = $gPCExistingValue + $extensionHashtable[$gPCItem] | Select-Object -Unique | Sort-Object
            }
            else
            {
                $gPCNewValue = $extensionHashtable[$gPCItem]
            }

            $formattedgPCNewValue = '[{{{0}}}]' -f $($gPCNewValue -join '}{')
            Write-Verbose -Message ($script:localizedData.GptIniCseUpdate -f $gPCItem, $gptEntry, $formattedgPCNewValue)
            Write-PrivateProfileString -AppName 'General' -KeyName $gPCItem -KeyValue $formattedgPCNewValue -GptIniPath $gptIniPath
        }

        <#
            To ensure consistent gpt.ini file structure, querying Version and setting Version so the structure will be:
            gPC[User|Machine]ExtensionName = [{guids}]
            Version = 11111
            gPC[User|Machine]ExtensionName = [{guids}]
        #>
        $gptVersion = Get-PrivateProfileString -AppName 'General' -KeyName 'Version' -Default 0 -GptIniPath $gptIniPath
        Write-PrivateProfileString -AppName 'General' -KeyName 'Version' -KeyValue $gptVersion -GptIniPath $gptIniPath
    }

    # Determine incremented version number
    $newGptVersion = Get-IncrementedGptVersion -TargetType $TargetType -Version $gptVersion

    # Write incremented version to GPT
    Write-Verbose -Message ($script:localizedData.GptIniVersionUpdate -f $TargetType, $gptVersion, $newGptVersion)
    Write-PrivateProfileString -AppName 'General' -KeyName 'Version' -KeyValue $newGptVersion -GptIniPath $gptIniPath
}

<#
    .SYNOPSIS
        Queries an ini file for specific information.

    .PARAMETER AppName
        The name of the section containing the key name in an ini file, also known as 'Section'.

    .PARAMETER KeyName
        The name of the key whose associated string is to be retrieved.

    .PARAMETER Default
        If the KeyName key cannot be found in the initialization file, GetPrivateProfileString
        copies the default string to the ReturnedString buffer.

    .PARAMETER GptIniPath
        Path to the gpt.ini file to be queried.
#>
function Get-PrivateProfileString
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.String]
        $AppName = 'General',

        [Parameter(Mandatory = $true)]
        [System.String]
        $KeyName,

        [Parameter()]
        [System.String]
        $Default,

        [Parameter(Mandatory = $true)]
        [System.String]
        $GptIniPath
    )

    # The GetPrivateProfileString method requires a FileSystem path, meaning no PSDrive paths
    $fullyQualifiedFilePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($GptIniPath)

    $stringBuilder = [System.Text.StringBuilder]::new(65535)

    [void][GPRegistryPolicyDsc.IniUtility]::GetPrivateProfileString(
        $AppName,
        $KeyName,
        $Default,
        $stringBuilder,
        $stringBuilder.Capacity,
        $fullyQualifiedFilePath
    )

    return $stringBuilder.ToString()
}

<#
    .SYNOPSIS
        Writes information to an ini file.

    .PARAMETER AppName
        The name of the section containing the key name in an ini file, also known as 'Section'.

    .PARAMETER KeyName
        The name of the key whose associated KeyValue string is to be written/modified.

    .PARAMETER KeyValue
        A null-terminated string to be written to the file.

    .PARAMETER GptIniPath
        Path to the gpt.ini file to be written/modified.
#>
function Write-PrivateProfileString
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.String]
        $AppName = 'General',

        [Parameter(Mandatory = $true)]
        [System.String]
        $KeyName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $KeyValue,

        [Parameter(Mandatory = $true)]
        [System.String]
        $GptIniPath
    )

    # The WritePrivateProfileString method requires a FileSystem path, meaning no PSDrive paths
    $fullyQualifiedFilePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($GptIniPath)

    [void][GPRegistryPolicyDsc.IniUtility]::WritePrivateProfileString(
        $AppName,
        $KeyName,
        $KeyValue,
        $fullyQualifiedFilePath
    )
}

<#
    .SYNOPSIS
        Determines the incremented version number from the specified gpt.ini file.

    .PARAMETER Version
        The current gpt.ini version number which will be incremented based on TargetType.

    .PARAMETER TargetType
        Indicates the target type. This is needed to determine the gpt.ini file path. Supported values are LocalMachine, User, Administrators, NonAdministrators, Account.
#>
function Get-IncrementedGptVersion
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Version,

        [Parameter(Mandatory = $true)]
        [ValidateSet('ComputerConfiguration','UserConfiguration','Administrators','NonAdministrators','Account')]
        [System.String]
        $TargetType
    )

    <#
        Reference: https://docs.microsoft.com/en-us/archive/blogs/grouppolicy/understanding-the-gpo-version-number
        The version integer value in the GPT.ini has the following structure:
            Version = [user version number top 16 bits] [computer version number lower 16 bits]
        Below is a simple way to split the version number into the user and computer version number:
            * First, recognize that the version number is in decimal. Before we can split the number into the two version numbers,
              we first convert the decimal value to hex. The easiest way to perform this conversion is to use the calculator in windows
              in scientific mode. Enter the decimal value and then click the hex button to convert the number. You should see a value of 15002F.
            * If you are using the calculator, it will not display the leading zeros of the number. In hexadecimal, four hexadecimal characters
              are equal to 16 bits. When you split the number into two parts you'll need to add two leading zeros to show the full version number
              in hexadecimal. For our case, I would write this number out as 0015002F. (When written on paper, a 0x is added to the beginning of
              the number to clarify the number is hexadecimal, 0x0015002F.)
            * Input the lower 4 hex characters (002F) into the calculator while in hex mode. Then convert this value to decimal by clicking the
              decimal button. You should see a computer version number of 47 decimal.
            * Input the upper 4 hex characters (0015) into the calculator while in hex mode. Then convert this value to decimal by clicking the
              decimal button. You should see a user version number of 21 decimal.
    #>

    # Increment gpt.ini version number based on user or computer policy change.
    $versionBytes = [System.BitConverter]::GetBytes([int]$Version)
    $loVersion    = [System.BitConverter]::ToUInt16($versionBytes, 0)
    $hiVersion    = [System.BitConverter]::ToUInt16($versionBytes, 2)

    if ($TargetType -eq 'ComputerConfiguration')
    {
        if ($loVersion -eq [uint16]::MaxValue)
        {
            # Once the GPT version hits the uint16 max (65535), the incremented number is reset to 1
            $loVersion = 1
        }
        else
        {
            $loVersion++
        }
    }
    else
    {
        if ($hiVersion -eq [uint16]::MaxValue)
        {
            # Once the GPT version hits the uint16 max (65535), the incremented number is reset to 1
            $hiVersion = 1
        }
        else
        {
            $hiVersion++
        }
    }

    # Convert lo/hi to byte array
    $loVersionByte = [System.BitConverter]::GetBytes($loVersion)
    $hiVersionByte = [System.BitConverter]::GetBytes($hiVersion)

    # Create new byte array and convert to int32
    $newGptVersionBytes = [byte[]]::new(4)
    $newGptVersionBytes[0] = $loVersionByte[0]
    $newGptVersionBytes[1] = $loVersionByte[1]
    $newGptVersionBytes[2] = $hiVersionByte[0]
    $newGptVersionBytes[3] = $hiVersionByte[1]

    return [System.BitConverter]::ToInt32($newGptVersionBytes, 0)
}
