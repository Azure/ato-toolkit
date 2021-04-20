Set-StrictMode -Version 'Latest'

$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

# Import the Networking Common Modules
Import-Module -Name (Join-Path -Path $modulePath `
        -ChildPath (Join-Path -Path 'FileContentDsc.Common' `
            -ChildPath 'FileContentDsc.Common.psm1'))

# Import Localization Strings
$script:localizedData = Get-LocalizedData -ResourceName 'DSR_ReplaceText'

<#
    .SYNOPSIS
        Retrieves the current state of the text file.

    .PARAMETER Path
        The path to the text file to replace the string in.

    .PARAMETER Search
        The RegEx string to use to search the text file.
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
        $Search
    )

    Assert-ParametersValid @PSBoundParameters

    $fileContent = Get-Content -Path $Path -Raw
    $fileEncoding = Get-FileEncoding $Path

    Write-Verbose -Message ($script:localizedData.SearchForTextMessage -f `
        $Path, $Search)

    $text = ''

    # Search the file content for any matches
    $results = [regex]::Matches($fileContent, $Search)

    if ($results.Count -eq 0)
    {
        # No matches found - already in state
        Write-Verbose -Message ($script:localizedData.StringNotFoundMessage -f `
            $Path, $Search)
    }
    else
    {
        $text = ($results.Value -join ',')

        Write-Verbose -Message ($script:localizedData.StringMatchFoundMessage -f `
            $Path, $Search, $text)
    } # if

    return @{
        Path     = $Path
        Search   = $Search
        Type     = 'Text'
        Text     = $text
        Encoding = $fileEncoding
    }
}

<#
    .SYNOPSIS
        Replaces text the matches the RegEx in the file.

    .PARAMETER Path
        The path to the text file to replace the string in.

    .PARAMETER Search
        The RegEx string to use to search the text file.

    .PARAMETER Type
        Specifies the value type to use as the replacement string. Defaults to 'Text'.

    .PARAMETER Text
        The text to replace the text identifed by the RegEx.
        Only used when Type is set to 'Text'.

    .PARAMETER Secret
        The secret text to replace the text identified by the RegEx.
        Only used when Type is set to 'Secret'.

    .PARAMETER AllowAppend
        Specifies to append text to the file being modified. Adds the ability to add a configuration entry.

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
        $Search,

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
        $AllowAppend = $false,

        [Parameter()]
        [ValidateSet("ASCII", "BigEndianUnicode", "BigEndianUTF32", "UTF8", "UTF32")]
        [System.String]
        $Encoding
    )

    Assert-ParametersValid @PSBoundParameters

    $fileContent = Get-Content -Path $Path -Raw -ErrorAction SilentlyContinue
    $fileEncoding = Get-FileEncoding $Path

    $fileProperties = @{
        Path      = $Path
        NoNewline = $true
        Force     = $true
    }

    if ($Type -eq 'Secret')
    {
        Write-Verbose -Message ($script:localizedData.StringReplaceSecretMessage -f `
            $Path)

        $Text = $Secret.GetNetworkCredential().Password
    }
    elseif ($PSBoundParameters.ContainsKey('Encoding'))
    {
        if ($Encoding -eq $fileEncoding)
        {
            Write-Verbose -Message ($script:localizedData.StringReplaceTextMessage -f `
            $Path, $Text)
        }
        else
        {
            Write-Verbose -Message ($script:localizedData.StringReplaceTextMessage -f `
            $Path, $Text)

            # Add encoding parameter and value to the hashtable
            $fileProperties.Add('Encoding', $Encoding)
        }
    }

    if ($null -eq $fileContent)
    {
        # Configuration file does not exist
        $fileContent = $Text
    }
    elseif ([regex]::Matches($fileContent, $Search).Count -eq 0 -and $AllowAppend -eq $true)
    {
        # Configuration file exists but Text does not exist so lets add it
        $fileContent = Add-ConfigurationEntry -FileContent $fileContent -Text $Text
    }
    else
    {
        # Configuration file exists but Text not in a desired state so lets update it
        $fileContent = $fileContent -Replace $Search, $Text
    }

    $fileProperties.Add('Value', $fileContent)

    Set-Content @fileProperties
}

<#
    .SYNOPSIS
        Tests if any text in the file matches the RegEx.

    .PARAMETER Path
        The path to the text file to replace the string in.

    .PARAMETER Search
        The RegEx string to use to search the text file.

    .PARAMETER Type
        Specifies the value type to use as the replacement string. Defaults to 'Text'.

    .PARAMETER Text
        The text to replace the text identifed by the RegEx.
        Only used when Type is set to 'Text'.

    .PARAMETER Secret
        The secret text to replace the text identified by the RegEx.
        Only used when Type is set to 'Secret'.

    .PARAMETER AllowAppend
        Specifies to append text to the file being modified. Adds the ability to add a configuration entry.

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
        $Search,

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
        $AllowAppend = $false,

        [Parameter()]
        [ValidateSet("ASCII", "BigEndianUnicode", "BigEndianUTF32", "UTF8", "UTF32")]
        [System.String]
        $Encoding
    )

    Assert-ParametersValid @PSBoundParameters

    # Check if file being managed exists. If not return $false.
    if (-not (Test-Path -Path $Path))
    {
        return $false
    }

    $fileContent = Get-Content -Path $Path -Raw
    $fileEncoding = Get-FileEncoding $Path

    Write-Verbose -Message ($script:localizedData.SearchForTextMessage -f `
        $Path, $Search)

    # Search the file content for any matches
    $results = [regex]::Matches($fileContent, $Search)

    if ($results.Count -eq 0)
    {
        if ($AllowAppend -eq $true)
        {
            # No matches found - but we want to append
            Write-Verbose -Message ($script:localizedData.StringNotFoundMessageAppend -f `
                    $Path, $Search)

            return $false
        }
        if ($PSBoundParameters.ContainsKey('Encoding'))
        {
            if ($Encoding -eq $fileEncoding)
            {
                # No matches found and encoding is in desired state
                Write-Verbose -Message ($script:localizedData.StringNotFoundMessage -f `
                $Path, $Search)

                return $true
            }
            else
            {
                # No matches found but encoding is not in desired state
                Write-Verbose -Message ($script:localizedData.FileEncodingNotInDesiredState -f `
                $fileEncoding, $Encoding)

                return $false
            }
        }
    }

    # Flag to signal whether settings are correct
    [System.Boolean] $desiredConfigurationMatch = $true

    if ($Type -eq 'Secret')
    {
        $Text = $Secret.GetNetworkCredential().Password
    } # if

    foreach ($result in $results)
    {
        if ($result.Value -ne $Text)
        {
            $desiredConfigurationMatch = $false
        } # if
    } # foreach

    if ($desiredConfigurationMatch)
    {
        Write-Verbose -Message ($script:localizedData.StringNoReplacementMessage -f `
            $Path, $Search)
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.StringReplacementRequiredMessage -f `
            $Path, $Search)
    } # if

    return $desiredConfigurationMatch
}

<#
    .SYNOPSIS
        Validates the parameters that have been passed are valid.
        If they are not valid then an exception will be thrown.

    .PARAMETER Path
        The path to the text file to replace the string in.

    .PARAMETER Search
        The RegEx string to use to search the text file.

    .PARAMETER Type
        Specifies the value type to use as the replacement string. Defaults to 'Text'.

    .PARAMETER Text
        The text to replace the text identifed by the RegEx.
        Only used when Type is set to 'Text'.

    .PARAMETER Secret
        The secret text to replace the text identified by the RegEx.
        Only used when Type is set to 'Secret'.

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
        $Search,

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
        $AllowAppend = $false,

        [Parameter()]
        [ValidateSet("ASCII", "BigEndianUnicode", "BigEndianUTF32", "UTF8", "UTF32")]
        [System.String]
        $Encoding
    )

    # Does the file's parent path exist?
    $parentPath = Split-Path -Path $Path -Parent
    if (-not (Test-Path -Path $parentPath))
    {
        New-InvalidArgumentException `
            -Message ($script:localizedData.FileParentNotFoundError -f $parentPath) `
            -ArgumentName 'Path'
    } # if
}

<#
    .SYNOPSIS
        Uses the stringBuilder class to append a configuration entry to the existing file content.

    .PARAMETER FileContent
        The existing file content of the configuration file.

    .PARAMETER Text
        The text to append to the end of the FileContent.
#>
function Add-ConfigurationEntry
{
    [OutputType([System.String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $FileContent,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Text
    )

    if ($FileContent -match '\n$' -and $FileContent -notmatch '\r\n$')
    {
        # default *nix line ending
        $detectedNewLineFormat = "`n"
    }
    else
    {
        # default Windows line ending
        $detectedNewLineFormat = "`r`n"
    }

    $stringBuilder = New-Object -TypeName System.Text.StringBuilder

    $null = $stringBuilder.Append($FileContent)
    $null = $stringBuilder.Append($Text)
    $null = $stringBuilder.Append($detectedNewLineFormat)

    return $stringBuilder.ToString()
}

Export-ModuleMember -Function *-TargetResource
