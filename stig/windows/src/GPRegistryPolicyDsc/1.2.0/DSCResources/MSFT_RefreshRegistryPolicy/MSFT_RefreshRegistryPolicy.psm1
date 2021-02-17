$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'

$script:resourceHelperModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'GPRegistryPolicyDsc.Common'
Import-Module -Name (Join-Path -Path $script:resourceHelperModulePath -ChildPath 'GPRegistryPolicyDsc.Common.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_RefreshRegistryPolicy'

<#
    .SYNOPSIS
        Returns the current state if a machine requires a group policy refresh.

    .PARAMETER Name
        A name to serve as the key property. It is not used during configuration.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance
    )

    $refreshKeyValue = Read-GPRefreshRegistryKey

    Write-Verbose -Message ($script:localizedData.RefreshRequiredValue -f $refreshKeyValue.Value)

    return @{
        IsSingleInstance = 'Yes'
        Path               = $refreshKeyValue.Path
        RefreshRequiredKey = $refreshKeyValue.Value
    }
}

<#
    .SYNOPSIS
        Invokes gpupdate.exe /force to update group policy.

    .PARAMETER Name
        A name to serve as the key property. It is not used during configuration.
#>
function Set-TargetResource
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '',
        Justification = 'Suppressing this rule because $global:DSCMachineStatus is used to trigger a reboot')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
        Justification = 'Suppressing this rule because $global:DSCMachineStatus is used to trigger a reboot')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance
    )

    Write-Verbose -Message $script:localizedData.RefreshingGroupPolicy

    $gpupdateResult = Invoke-Command -ScriptBlock {'N','N' | gpupdate.exe /force}

    Remove-Item -Path HKLM:\SOFTWARE\Microsoft\GPRegistryPolicy -Force

    if ($gpupdateResult -match 'restart|log\soff')
    {
        Write-Warning -Message ($script:localizedData.RebootRequired)
        $global:DSCMachineStatus = 1
    }
}

<#
    .SYNOPSIS
        Reads the value of HKLM:\SOFTWARE\Microsoft\GPRegistryPolicy\RefreshRequired to determine if a group policy refresh is required.

    .PARAMETER Name
        A name to serve as the key property. It is not used during configuration.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance
    )

    $getTargetResourceResult = Get-TargetResource @PSBoundParameters

    if ($getTargetResourceResult.RefreshRequiredKey -ne 1)
    {
        Write-Verbose -Message $script:localizedData.NotRefreshRequired
        return $true
    }

    Write-Verbose -Message $script:localizedData.RefreshRequired

    return $false
}

<#
    .SYNOPSIS
        Writes a registry key indicating a group policy refresh is required.

    .PARAMETER Path
        Specifies the value of the registry path that will contain the properties pertaining to requiring a refresh.

    .PARAMETER PropertyName
        Specifies a name for the new property.
#>
function Read-GPRefreshRegistryKey
{
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param
    (
        [Parameter()]
        [System.String]
        $Path = 'HKLM:\SOFTWARE\Microsoft\GPRegistryPolicy',

        [Parameter()]
        [System.String]
        $PropertyName = 'RefreshRequired'
    )

    $registryKey = Get-Item -Path $Path -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        Path  = $registryKey.Name
        Value = ($registryKey | Get-ItemProperty).$PropertyName
    }
}
