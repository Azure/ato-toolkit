try
{
    $importLocalizedDataParams = @{
        BaseDirectory = $PSScriptRoot
        UICulture     = $PSUICulture
        FileName      = 'AccessControlResourceHelper.strings.psd1'
        ErrorAction   = 'Stop'
    }
    $script:localizedData = Import-LocalizedData @importLocalizedDataParams
}
catch
{
    $importLocalizedDataParams.UICulture = 'en-US'
    try
    {
        $script:localizedData = Import-LocalizedData @importLocalizedDataParams
    }
    catch
    {
        throw 'Unable to load localized data'
    }
}

<#
    .SYNOPSIS
        Resolves the principal name SID

    .PARAMETER Identity
        Specifies the identity of the principal.

    .EXAMPLE
    Resolve-Identity -Identity "everyone"
#>
function Resolve-Identity
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Identity
    )
    process
    {
        Write-Verbose -Message "Resolving identity for '$Identity'."

        $tryNTService = $false

        try
        {
            if ($Identity -match '^S-\d-(\d+-){1,14}\d+$')
            {
                [System.Security.Principal.SecurityIdentifier]$Identity = $Identity
            }
            else
            {
                 [System.Security.Principal.NTAccount]$Identity = $Identity
            }

            $SID = $Identity.Translate([System.Security.Principal.SecurityIdentifier])
            $NTAccount = $SID.Translate([System.Security.Principal.NTAccount])

            $Principal = [PSCustomObject]@{
                Name = $NTAccount.Value
                SID = $SID.Value
            }

            return $Principal
        }
        catch
        {
            # Try to resolve identity to NT Service
            $tryNTService = $true
        }

        if ($tryNTService)
        {
            try
            {
                [System.Security.Principal.NTAccount]$Id = "NT Service\" + $Identity
                $SID = $Id.Translate([System.Security.Principal.SecurityIdentifier])
                $NTAccount = $SID.Translate([System.Security.Principal.NTAccount])

                $Principal = [PSCustomObject]@{
                    Name = $NTAccount.Value
                    SID = $SID.Value
                }

                return $Principal
            }
            catch
            {
                $ErrorMessage = "Could not resolve identity '{0}': '{1}'." -f $Identity, $_.Exception.Message
                Write-Error -Exception $_.Exception -Message $ErrorMessage
            }
        }
    }
}

<#
    .SYNOPSIS
    Takes identity name and translates to SID

    .PARAMETER IdentityReference
    System.Security.Principal.NTAccount object

    .EXAMPLE
    $IdentityReference = (Get-Acl -Path C:\temp).access[0].IdentityReference
    ConvertTo-SID -IdentityReference $IdentityReference
#>

function ConvertTo-SID
{
    Param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $IdentityReference
    )

    try
    {
        If($IdentityReference.Contains("\"))
        {
            $IdentityReference = $IdentityReference.split('\')[1]
        }

        [System.Security.Principal.NTAccount]$PrinicipalName = $IdentityReference
        $SID = $PrinicipalName.Translate([System.Security.Principal.SecurityIdentifier])

        Return $SID
    }
    catch
    {
        # Probably NT Service which needs domain portion to translate without error
        [System.Security.Principal.NTAccount]$Id = "NT Service\" + $IdentityReference
        $SID = $Id.Translate([System.Security.Principal.SecurityIdentifier])

        return $SID
    }

}

<#
    .SYNOPSIS
        Confirms a required module exists.
#>
function Assert-Module
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ModuleName
    )

    if (-not (Get-Module -Name $ModuleName -ListAvailable))
    {
        $errorId = '{0}_ModuleNotFound' -f $ModuleName;
        $errorMessage = $localizedString.RoleNotFoundError -f $ModuleName;
        ThrowInvalidOperationError -ErrorId $errorId -ErrorMessage $errorMessage;
    }
}

<#
    .SYNOPSIS
        Retrieves teh guid of the delegation right
#>
function Get-DelegationRightsGuid
{
    Param
    (
        [Parameter()]
        [string]
        $ObjectName
    )

    if ($ObjectName)
    {
        # Create a hashtable to store the GUID value of each schemaGuids and rightsGuids
        $guidmap = @{}
        $rootdse = Get-ADRootDSE
        Get-ADObject -SearchBase ($rootdse.SchemaNamingContext) -LDAPFilter "(schemaidguid=*)" -Properties Name,schemaIDGUID |
            Foreach-Object -Process {$guidmap[$_.Name] = [System.GUID]$_.schemaIDGUID}

        Get-ADObject -SearchBase ($rootdse.ConfigurationNamingContext) -LDAPFilter "(&(objectclass=controlAccessRight)(rightsguid=*))" -Properties Name,rightsGuid |
            Foreach-Object -Process {$guidmap[$_.Name] = [System.GUID]$_.rightsGuid}

        return [system.guid]$guidmap[$ObjectName]
    }
    else
    {
        return [system.guid]'00000000-0000-0000-0000-000000000000'
    }
}

<#
    .SYNOPSIS
        Retrieves the name of the AD schema object.
#>
function Get-SchemaObjectName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    Param
    (
        [Parameter()]
        [guid]
        $SchemaIdGuid
    )

    if ($SchemaIdGuid -and ($SchemaIdGuid.Guid -ne '00000000-0000-0000-0000-000000000000'))
    {
        $guidmap = @{}
        $rootdse = Get-ADRootDSE
        Get-ADObject -SearchBase ($rootdse.SchemaNamingContext) -LDAPFilter "(schemaidguid=*)" -Properties Name,schemaIDGUID |
            Foreach-Object -Process {$guidmap[$_.Name] = [System.GUID]$_.schemaIDGUID}

        Get-ADObject -SearchBase ($rootdse.ConfigurationNamingContext) -LDAPFilter "(&(objectclass=controlAccessRight)(rightsguid=*))" -Properties Name,rightsGuid |
            Foreach-Object -Process {$guidmap[$_.Name] = [System.GUID]$_.rightsGuid}

        # This is to address the edge case where one guid resolves to multiple names ex. f3a64788-5306-11d1-a9c5-0000f80367c1 resolves to Service-Principal-Name,Validated-SPN
        $names = ($guidmap.GetEnumerator() | Where-Object -FilterScript {$_.Value -eq $SchemaIdGuid}).Name
        return $names -join ','
    }
    else
    {
        return 'None'
    }
}

<#
    .SYNOPSIS
        Produces a custom verbose message displaying details of every property touched by the resource.
#>
function Write-CustomVerboseMessage
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Action,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [ValidateScript({
            $_ -is [System.DirectoryServices.ActiveDirectoryAccessRule] -or
            $_ -is [System.DirectoryServices.ActiveDirectoryAuditRule] -or
            $_ -is [System.Security.AccessControl.FileSystemAccessRule] -or
            $_ -is [System.Security.AccessControl.AuditRule]
        })]
        $Rule
    )

    $properties = [ordered]@{
        IdentityReference = $Rule.IdentityReference
    }

    switch ($Rule.GetType().Name)
    {
        'ActiveDirectoryAccessRule'
        {
            # future expansion
            break
        }

        'ActiveDirectoryAuditRule'
        {
            $properties.Add('ActiveDirectoryRights', $Rule.ActiveDirectoryRights)
            $properties.Add('AuditFlags', $Rule.AuditFlags)
            $properties.Add('ObjectType', $(Get-SchemaObjectName -SchemaIdGuid $Rule.ObjectType))
            $properties.Add('InheritanceType', $Rule.InheritanceType)
            $properties.Add('InheritedObjectType', $(Get-SchemaObjectName -SchemaIdGuid $Rule.InheritedObjectType))
            break
        }

        'FileSystemAccessRule'
        {
            $properties.Add('AccessControlType', $Rule.AccessControlType)
            $properties.Add('FileSystemRights', $Rule.FileSystemRights)
            $properties.Add('InheritanceFlags', $Rule.InheritanceFlags)
            $properties.Add('PropagationFlags', $Rule.PropagationFlags)
            break
        }
        'FileSystemAuditRule'
        {
            $properties.Add('FileSystemRights', $Rule.FileSystemRights)
            $properties.Add('AuditFlags', $Rule.AuditFlags)
            $properties.Add('InheritanceFlags', $Rule.InheritanceFlags)
            $properties.Add('PropagationFlags', $Rule.PropagationFlags)
            break
        }
    }

    Write-Verbose -Message $localizedData[$Action] -Verbose
    Write-Verbose -Message ($localizedData.Path -f $Path) -Verbose

    foreach ($property in $properties.Keys -as [array])
    {
        Write-Verbose -Message ($localizedData[$property] -f $properties[$property]) -Verbose
    }
}

<#
    .SYNOPSIS
        Resolves inheritance to inheritanceFlag and propagationFlag
#>
function Get-NtfsInheritenceFlag
{
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Inheritance
    )

    switch($Inheritance)
    {
        "This folder only"{
            $InheritanceFlag = "0"
            $PropagationFlag = "0"
            break
        }
        "This folder subfolders and files"{
            $InheritanceFlag = "3"
            $PropagationFlag = "0"
            break

        }
        "This folder and subfolders"{
            $InheritanceFlag = "1"
            $PropagationFlag = "0"
            break
        }
        "This folder and files"{
            $InheritanceFlag = "2"
            $PropagationFlag = "0"
            break

        }
        "Subfolders and files only"{
            $InheritanceFlag = "3"
            $PropagationFlag = "2"
            break

        }
        "Subfolders only"{
            $InheritanceFlag = "1"
            $PropagationFlag = "2"
            break
        }
        "Files only"{
            $InheritanceFlag = "2"
            $PropagationFlag = "2"
            break
        }
    }

    return [PSCustomObject]@{
        InheritanceFlag = $InheritanceFlag
        PropagationFlag = $PropagationFlag
    }
}

<#
    .SYNOPSIS
        Returns Inheritance name from inheritanceFlag and propagationFlag
#>
function Get-NtfsInheritenceName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $InheritanceFlag,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PropagationFlag
    )

    switch("$InheritanceFlag-$PropagationFlag")
    {
        "0-0"{
            return "This folder only"
        }
        "3-0"{
            return "This folder subfolders and files"
        }
        "1-0"{
            return "This folder and subfolders"
        }
        "2-0"{
            return "This folder and files"
        }
        "3-2"{
            return "Subfolders and files only"
        }
        "1-2"{
            return "Subfolders Only"
        }
        "2-2"{
            return "Files Only"
        }
    }

    return "none"
}

<#
    .SYNOPSIS
        Resolves environment variable that are included in a folder/file path.
#>
function Get-InputPath
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    # If Path has a environment variable, convert it to a locally usable path
    $returnPath = [System.Environment]::ExpandEnvironmentVariables($Path)

    return $returnPath
}

<#
    .SYNOPSIS
        Removes the domain from an NT Principal
    .DESCRIPTION
        Removes the domain from an NT Principal
    .PARAMETER Identity
        Specifies the identity of the principal.
#>
function Remove-NtPrincipalDomain
{
    [CmdletBinding()]
    [OutputType([System.Security.Principal.NTAccount])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Security.Principal.NTAccount]
        $Identity
    )

    $modifiedIdentity = $Identity.ToString() -replace '.*\\'
    $returnIdentity = New-Object -Type System.Security.Principal.NTAccount -ArgumentList $modifiedIdentity
    return $returnIdentity
}
