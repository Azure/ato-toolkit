Set-StrictMode -Version 'Latest'

$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

# Import the Networking Common Modules
Import-Module -Name (Join-Path -Path $modulePath `
        -ChildPath (Join-Path -Path 'FileContentDsc.Common' `
            -ChildPath 'FileContentDsc.Common.psm1'))

# Import Localization Strings
$script:localizedData = Get-LocalizedData -ResourceName 'DSR_KeyValuePairFile'

<#
    .SYNOPSIS
        Retrieves the current state of a key in a key value pair text file.

    .PARAMETER Path
        The path to the key value pair text file.

    .PARAMETER Name
        The name of the key.
#>
function Get-TargetResource
{
    [OutputType([Hashtable])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name
    )

    Assert-ParametersValid @PSBoundParameters

    $ensure = 'Absent'
    $text = $null
    $fileEncoding = $null

    if (Test-Path -Path $Path)
    {
        $fileContent = Get-Content -Path $Path -Raw
        $fileEncoding = Get-FileEncoding -Path $Path

        if ($null -ne $fileContent)
        {
            Write-Verbose -Message ($script:localizedData.SearchForKeyMessage -f $Path, $Name)

            # Setup the Regex Options that will be used
            $regExOptions = [System.Text.RegularExpressions.RegexOptions]::Multiline

            # Search the key that matches the requested key
            $results = [regex]::Matches($fileContent, "^[\s]*$Name=([^\n\r]*)", $regExOptions)

            if ($results.Count -eq 0)
            {
                # No matches found
                Write-Verbose -Message ($script:localizedData.KeyNotFoundMessage -f $Path, $Name)
            }
            else
            {
                # One of more key value pairs were found
                $ensure = 'Present'
                $textValues = @()

                foreach ($match in $results)
                {
                    $textValues += $match.Groups[1].Value
                }

                $text = ($textValues -join ',')

                Write-Verbose -Message ($script:localizedData.KeyFoundMessage -f $Path, $Name, $text)
            } # if
        }
        else
        {
            Write-Verbose -Message ($script:localizedData.KeyValuePairFileIsEmpty -f $Path)
        }
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.KeyValuePairFileNotFound -f $Path)
    }

    return @{
        Path            = $Path
        Name            = $Name
        Encoding        = $fileEncoding
        Ensure          = $ensure
        Type            = 'Text'
        Text            = $text
        IgnoreNameCase  = $false
        IgnoreValueCase = $false
    }
}

<#
    .SYNOPSIS
        Sets the current state of a key in a key value pair text file.

    .PARAMETER Path
        The path to the key value pair text file.

    .PARAMETER Name
        The name of the key.

    .PARAMETER Ensure
        Specifies the if the key value pair with the specified key should exist in the file.

    .PARAMETER Type
        Specifies the value type to use as the replacement string. Defaults to 'Text'.

    .PARAMETER Text
        The text to replace the value with in the identified key.
        Only used when Type is set to 'Text'.

    .PARAMETER Secret
        The secret text to replace the value with in the identified key.
        Only used when Type is set to 'Secret'.

    .PARAMETER IgnoreNameCase
        Ignore the case of the name of the key. Defaults to $False.

    .PARAMETER IgnoreValueCase
        Ignore the case of any text or secret when determining if it they need to be updated.
        Defaults to $False.

    .PARAMETER Encoding
        Specifies the file encoding. Defaults to ASCII.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [ValidateSet('Text', 'Secret')]
        [System.String]
        $Type = 'Text',

        [Parameter()]
        [System.String]
        $Text,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Secret,

        [Parameter()]
        [System.Boolean]
        $IgnoreNameCase = $false,

        [Parameter()]
        [System.Boolean]
        $IgnoreValueCase = $false,

        [Parameter()]
        [ValidateSet('ASCII', 'BigEndianUnicode', 'BigEndianUTF32', 'UTF8', 'UTF32')]
        [System.String]
        $Encoding
    )

    Assert-ParametersValid @PSBoundParameters

    $fileContent = Get-Content -Path $Path -Raw -ErrorAction SilentlyContinue
    $fileEncoding = Get-FileEncoding -Path $Path -ErrorAction SilentlyContinue

    $fileProperties = @{
        Path      = $Path
        NoNewline = $true
        Force     = $true
    }

    Write-Verbose -Message ($script:localizedData.SearchForKeyMessage -f $Path, $Name)

    if ($Type -eq 'Secret')
    {
        $Text = $Secret.GetNetworkCredential().Password
    } # if

    if ($null -ne $fileContent)
    {
        # Determine the EOL characters used in the file
        $eolChars = Get-TextEolCharacter -Text $fileContent

        # Setup the Regex Options that will be used
        $regExOptions = [System.Text.RegularExpressions.RegexOptions]::Multiline

        if ($IgnoreNameCase)
        {
            $regExOptions += [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        }

        # Search the key that matches the requested key
        $results = [regex]::Matches($fileContent, "^[\s]*$Name=([^\n\r]*)", $regExOptions)

        if ($Ensure -eq 'Present')
        {
            # The key value pair should exist
            $keyValuePair = '{0}={1}{2}' -f $Name, $Text, $eolChars

            if ($results.Count -eq 0)
            {
                # The key value pair was not found so add it to the end of the file
                if (-not $fileContent.EndsWith($eolChars))
                {
                    $fileContent += $eolChars
                } # if

                $fileContent += $keyValuePair

                Write-Verbose -Message ($script:localizedData.KeyAddMessage -f $Path, $Name)
            }
            else
            {
                # The key value pair was found so update it
                $fileContent = [regex]::Replace($fileContent, "^[\s]*$Name=(.*)($eolChars*)", $keyValuePair, $regExOptions)

                Write-Verbose -Message ($script:localizedData.KeyUpdateMessage -f $Path, $Name)
            } # if
        }
        else
        {
            if ($results.Count -eq 0)
            {
                if ($PSBoundParameters.ContainsKey('Encoding') -and ($Encoding -eq $fileEncoding))
                {
                        # The Key does not exists and should not, and encoding is in the desired state, so don't do anything
                        return
                }
                else
                {
                    Write-Verbose -Message ($script:localizedData.FileEncodingNotInDesiredState -f $fileEncoding, $Encoding)
                }
            }
            else
            {
                # The Key exists in the file but should not so remove it
                $fileContent = [regex]::Replace($fileContent, "^[\s]*$Name=(.*)$eolChars", '', $regExOptions)

                Write-Verbose -Message ($script:localizedData.KeyRemoveMessage -f $Path, $Name)
            }
        } # if
    }
    else
    {
        $fileContent = '{0}={1}' -f $Name, $Text
    } # if

    $fileProperties.Add('Value', $fileContent)

    # Verify encoding is not set to the passed parameter or the default of ASCII
    if ($PSBoundParameters.ContainsKey('Encoding') -and ($Encoding -ne ($fileEncoding -or 'ASCII')))
    {
        # Add encoding parameter and value to the hashtable
        $fileProperties.Add('Encoding', $Encoding)
    }

    Set-Content @fileProperties
}

<#
    .SYNOPSIS
        Tests the current state of a key in a key value pair text file.

    .PARAMETER Path
        The path to the key value pair text file.

    .PARAMETER Name
        The name of the key.

    .PARAMETER Ensure
        Specifies the if the key value pair with the specified key should exist in the file.

    .PARAMETER Type
        Specifies the value type to use as the replacement string. Defaults to 'Text'.

    .PARAMETER Text
        The text to replace the value with in the identified key.
        Only used when Type is set to 'Text'.

    .PARAMETER Secret
        The secret text to replace the value with in the identified key.
        Only used when Type is set to 'Secret'.

    .PARAMETER IgnoreNameCase
        Ignore the case of the name of the key. Defaults to $False.

    .PARAMETER IgnoreValueCase
        Ignore the case of any text or secret when determining if it they need to be updated.
        Defaults to $False.

    .PARAMETER Encoding
        Specifies the file encoding. Defaults to ASCII.
#>
function Test-TargetResource
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [ValidateSet('Text', 'Secret')]
        [System.String]
        $Type = 'Text',

        [Parameter()]
        [System.String]
        $Text,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Secret,

        [Parameter()]
        [System.Boolean]
        $IgnoreNameCase = $false,

        [Parameter()]
        [System.Boolean]
        $IgnoreValueCase = $false,

        [Parameter()]
        [ValidateSet('ASCII', 'BigEndianUnicode', 'BigEndianUTF32', 'UTF8', 'UTF32')]
        [System.String]
        $Encoding
    )

    Assert-ParametersValid @PSBoundParameters

    <#
        If the file being managed does not exist then return true if
        the key should be absent or false if it should be present.
    #>
    if (-not (Test-Path -Path $Path))
    {
        Write-Verbose -Message ($script:localizedData.KeyValuePairFileNotFound -f $Path)

        return ($Ensure -eq 'Absent')
    }

    $fileContent = Get-Content -Path $Path -Raw

    if ($null -eq $fileContent)
    {
        Write-Verbose -Message ($script:localizedData.KeyValuePairFileIsEmpty -f $Path)

        return ($Ensure -eq 'Absent')
    }

    $desiredConfigurationMatch = $true
    $fileEncoding = Get-FileEncoding -Path $Path
    $regExOptions = [System.Text.RegularExpressions.RegexOptions]::Multiline

    Write-Verbose -Message ($script:localizedData.SearchForKeyMessage -f $Path, $Name)

    if ($IgnoreNameCase)
    {
        $regExOptions += [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    }

    # Search the key that matches the requested key
    $results = [regex]::Matches($fileContent, "^[\s]*$Name=([^\n\r]*)", $regExOptions)

    if ($results.Count -eq 0)
    {
        # No matches found
        if ($Ensure -eq 'Present')
        {
            # The key value pairs should exist but do not
            Write-Verbose -Message ($script:localizedData.KeyNotFoundButShouldExistMessage -f $Path, $Name)

            $desiredConfigurationMatch = $false
        }
        else
        {
            # The key value pairs should exist and do
            Write-Verbose -Message ($script:localizedData.KeyNotFoundAndShouldNotExistMessage -f $Path, $Name)
        } # if
    }
    else
    {
        # One or more key value pairs were found
        if ($Ensure -eq 'Present')
        {
            # The key value pairs should exist - but check values
            if ($Type -eq 'Secret')
            {
                $Text = $Secret.GetNetworkCredential().Password
            } # if

            # Check each found key value pair and check it has the correct value
            foreach ($match in $results)
            {
                if (($IgnoreValueCase -and ($match.Groups[1].Value -ne $Text)) -or `
                    (-not $IgnoreValueCase -and ($match.Groups[1].Value -cne $Text)))
                {
                    $desiredConfigurationMatch = $false
                } #
            } # foreach

            if ($desiredConfigurationMatch)
            {
                Write-Verbose -Message ($script:localizedData.KeyFoundButNoReplacementMessage -f $Path, $Name)
            }
        }
        else
        {
            # The key value pairs should not exist
            Write-Verbose -Message ($script:localizedData.KeyFoundButShouldNotExistMessage -f $Path, $Name)

            $desiredConfigurationMatch = $false
        } # if
    } # if

    if ($PSBoundParameters.ContainsKey('Encoding') -and ($Encoding -ne $fileEncoding))
    {
        # File encoding is not in desired state
        Write-Verbose -Message ($script:localizedData.FileEncodingNotInDesiredState -f $fileEncoding, $Encoding)

        $desiredConfigurationMatch = $false
    }

    return $desiredConfigurationMatch
}

<#
    .SYNOPSIS
        Validates the parameters that have been passed are valid.
        If they are not valid then an exception will be thrown.

    .PARAMETER Path
        The path to the key value pair text file.

    .PARAMETER Name
        The name of the key.

    .PARAMETER Ensure
        Specifies the if the key value pair with the specified key should exist in the file.

    .PARAMETER Type
        Specifies the value type to use as the replacement string. Defaults to 'Text'.

    .PARAMETER Text
        The text to replace the value with in the identified key.
        Only used when Type is set to 'Text'.

    .PARAMETER Secret
        The secret text to replace the value with in the identified key.
        Only used when Type is set to 'Secret'.

    .PARAMETER IgnoreNameCase
        Ignore the case of the name of the key. Defaults to $False.

    .PARAMETER IgnoreValueCase
        Ignore the case of any text or secret when determining if it they need to be updated.
        Defaults to $False.

    .PARAMETER Encoding
        Specifies the file encoding. Defaults to ASCII.
#>
function Assert-ParametersValid
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [ValidateSet('Text', 'Secret')]
        [System.String]
        $Type = 'Text',

        [Parameter()]
        [System.String]
        $Text,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Secret,

        [Parameter()]
        [System.Boolean]
        $IgnoreNameCase = $false,

        [Parameter()]
        [System.Boolean]
        $IgnoreValueCase = $false,

        [Parameter()]
        [ValidateSet('ASCII', 'BigEndianUnicode', 'BigEndianUTF32', 'UTF8', 'UTF32')]
        [System.String]
        $Encoding
    )

    # Does the file's parent path exist?
    $parentPath = Split-Path -Path $Path -Parent

    if (-not (Test-Path -Path $parentPath))
    {
        New-InvalidArgumentException `
            -Message ($script:localizedData.FileParentNotFoundError -f $Path) `
            -ArgumentName 'Path'
    } # if
}

Export-ModuleMember -Function *-TargetResource
