Set-StrictMode -Version 'Latest'

$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

# Import the Networking Common Modules
Import-Module -Name (Join-Path -Path $modulePath `
        -ChildPath (Join-Path -Path 'FileContentDsc.Common' `
            -ChildPath 'FileContentDsc.Common.psm1'))

# Import Localization Strings
$script:localizedData = Get-LocalizedData -ResourceName 'DSR_IniSettingsFile'

<#
    .SYNOPSIS
        Retrieves the current state of the INI settings file entry.

    .PARAMETER Path
        The path to the INI settings file to set the entry in.

    .PARAMETER Section
        The section to add or set the entry in.

    .PARAMETER Key
        The name of the key to add or set in the section.
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
        $Section,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Key
    )

    Assert-ParametersValid @PSBoundParameters

    Write-Verbose -Message ($script:localizedData.GetIniSettingMessage -f `
            $Path, $Section, $Key)

    $text = Get-IniSettingFileValue @PSBoundParameters

    return @{
        Path    = $Path
        Section = $Section
        Key     = $Key
        Type    = 'Text'
        Text    = $text
    }
}

<#
    .SYNOPSIS
        Sets the value of an entry in an INI settings file.

    .PARAMETER Path
        The path to the INI settings file to set the entry in.

    .PARAMETER Section
        The section to add or set the entry in.

    .PARAMETER Key
        The name of the key to add or set in the section.

    .PARAMETER Type
        Specifies the value type that contains the value to set the entry to. Defaults to 'Text'.

    .PARAMETER Text
        The text to set the entry value to.
        Only used when Type is set to 'Text'.

    .PARAMETER Secret
        The secret text to set the entry value to.
        Only used when Type is set to 'Secret'.
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
        $Section,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Key,

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
        $Secret
    )

    Assert-ParametersValid @PSBoundParameters

    if (-not (Test-Path -Path $Path))
    {
        Out-File -FilePath $Path -Force
    }

    if ($Type -eq 'Secret')
    {
        Write-Verbose -Message ($script:localizedData.SetIniSettingSecretMessage -f `
                $Path, $Section, $Key)

        $Text = $Secret.GetNetworkCredential().Password
        $null = $PSBoundParameters.Remove('Secret')
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.SetIniSettingTextMessage -f `
                $Path, $Section, $Key, $Text)
    } # if

    # Prepare the for the PSBoundParameters to be splatted
    $null = $PSBoundParameters.Remove('Type')
    $null = $PSBoundParameters.Add('Value',$Text)
    $null = $PSBoundParameters.Remove('Text')

    Set-IniSettingFileValue @PSBoundParameters
}

<#
    .SYNOPSIS
        Tests the value of an entry in an INI settings file.

    .PARAMETER Path
        The path to the INI settings file to set the entry in.

    .PARAMETER Section
        The section to add or set the entry in.

    .PARAMETER Key
        The name of the key to add or set in the section.

    .PARAMETER Type
        Specifies the value type that contains the value to set the entry to. Defaults to 'Text'.

    .PARAMETER Text
        The text to set the entry value to.
        Only used when Type is set to 'Text'.

    .PARAMETER Secret
        The secret text to set the entry value to.
        Only used when Type is set to 'Secret'.
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
        $Section,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Key,

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
        $Secret
    )

    Assert-ParametersValid @PSBoundParameters

    # Check if file being managed exists. If not return $False.
    if (-not (Test-Path -Path $Path))
    {
        return $false
    }

    if ($Type -eq 'Secret')
    {
        $Text = $Secret.GetNetworkCredential().Password
    } # if

    # Prepare the PSBoundParameters for splat
    $null = $PSBoundParameters.Remove('Type')
    $null = $PSBoundParameters.Remove('Text')
    $null = $PSBoundParameters.Remove('Secret')

    if ((Get-IniSettingFileValue @PSBoundParameters) -eq $Text)
    {
        Write-Verbose -Message ($script:localizedData.IniSettingMatchesMessage -f `
                $Path, $Section, $Key)

        return $true
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.IniSettingMismatchMessage -f `
                $Path, $Section, $Key)

        return $false
    } # if
}

<#
    .SYNOPSIS
        Validates the parameters that have been passed are valid.
        If they are not valid then an exception will be thrown.

    .PARAMETER Path
        The path to the INI settings file to set the entry in.

    .PARAMETER Section
        The section to add or set the entry in.

    .PARAMETER Key
        The name of the key to add or set in the section.

    .PARAMETER Type
        Specifies the value type that contains the value to set the entry to. Defaults to 'Text'.

    .PARAMETER Text
        The text to set the entry value to.
        Only used when Type is set to 'Text'.

    .PARAMETER Secret
        The secret text to set the entry value to.
        Only used when Type is set to 'Secret'.
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
        $Section,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Key,

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
        $Secret
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

Export-ModuleMember -Function *-TargetResource
