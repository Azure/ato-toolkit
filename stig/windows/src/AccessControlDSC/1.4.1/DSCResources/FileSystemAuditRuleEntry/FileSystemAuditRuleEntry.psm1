$resourceRootPath = Split-Path -Path $PSScriptRoot -Parent
$resourceHelperPath = Join-Path -Path $resourceRootPath -ChildPath 'AccessControlResourceHelper'
$resourceHelperPsm1 = Join-Path -Path $resourceHelperPath -ChildPath 'AccessControlResourceHelper.psm1'
Import-Module -Name $resourceHelperPsm1 -Force

try
{
    $importLocalizedDataParams = @{
        BaseDirectory = $resourceHelperPath
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
        Returns the current state of the resource.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Path,

        [Parameter(Mandatory=$true)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AuditRuleList
    )

    $nameSpace = "root/Microsoft/Windows/DesiredStateConfiguration"
    $cimfileSystemAuditRuleList = New-Object -TypeName 'System.Collections.ObjectModel.Collection`1[Microsoft.Management.Infrastructure.CimInstance]'
    $inputPath = Get-InputPath($Path)

    if (Test-Path -Path $inputPath)
    {
        $currentAcl = Get-Acl -Path $inputPath -Audit

        if ($null -ne $currentAcl)
        {
            $message = $localizedData.AclFound -f $inputPath
            Write-Verbose -Message $message

            foreach ($principal in $AuditRuleList)
            {
                $cimFileSystemAuditRule = New-Object -TypeName 'System.Collections.ObjectModel.Collection`1[Microsoft.Management.Infrastructure.CimInstance]'

                $principalName = $principal.Principal
                $forcePrincipal = $principal.ForcePrincipal

                $identity = Resolve-Identity -Identity $principalName
                $currentPrincipalAccess = $currentAcl.Audit.Where({$_.IdentityReference -eq $identity.Name})

                foreach ($access in $currentPrincipalAccess)
                {
                    $auditFlags = $access.AuditFlags.ToString()
                    $fileSystemRights = $access.FileSystemRights.ToString().Split(',').Trim()
                    $Inheritance = Get-NtfsInheritenceName -InheritanceFlag $access.InheritanceFlags.value__ -PropagationFlag $access.PropagationFlags.value__

                    $cimFileSystemAuditRule += New-CimInstance -ClientOnly -Namespace $nameSpace -ClassName FileSystemAuditRule -Property @{
                        AuditFlags = $auditFlags
                        FileSystemRights = @($fileSystemRights)
                        Inheritance = $Inheritance
                        Ensure = ""
                    }
                }

                $cimFileSystemAuditRuleList += New-CimInstance -ClientOnly -Namespace $nameSpace -ClassName FileSystemAuditRuleList -Property @{
                    Principal = $principalName
                    ForcePrincipal = $forcePrincipal
                    AuditRuleEntry = [Microsoft.Management.Infrastructure.CimInstance[]]@($cimFileSystemAuditRule)
                }
            }
        }
        else
        {
            $message = $localizedData.AclNotFound -f $inputPath
            Write-Verbose -Message $message
        }
    }
    else
    {
        $Message = $localizedData.ErrorPathNotFound -f $inputPath
        Write-Verbose -Message $Message
    }

    $returnValue = @{
        Force = $Force
        Path = $inputPath
        AuditRuleList = $cimfileSystemAuditRuleList
    }

    return $returnValue
}

<#
    .SYNOPSIS
        Changes the state to desired state.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory=$true)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AuditRuleList,

        [Parameter()]
        [bool]
        $Force = $false
    )

    if (Test-Path -Path $Path)
    {
        $currentAcl = Get-AuditAcl -Path $Path

        if ($null -ne $currentAcl)
        {
            if ($Force)
            {
                # If inheritance is set, disable it and clear inherited audit rules
                if (-not $currentAcl.AreAuditRulesProtected)
                {
                    $currentAcl.SetAuditRuleProtection($true, $false)
                    Write-Verbose -Message ($localizedData.ResetDisableInheritance)
                }

                # Removing all audit rules to ensure a blank list
                if ($null -ne $currentAcl.Audit)
                {
                    foreach ($rule in $currentAcl.Audit)
                    {
                        $ruleRemoval = $currentAcl.RemoveAuditRule($rule)

                        if (-not $ruleRemoval)
                        {
                            $currentAcl.RemoveAuditRuleSpecific($rule)
                        }

                        Write-CustomVerboseMessage -Action 'ActionRemoveAudit' -Path $path -Rule $rule
                    }
                }
            }

            foreach ($auditRuleItem in $AuditRuleList)
            {
                $principal = $auditRuleItem.Principal
                $identity = Resolve-Identity -Identity $principal
                $identityRef = New-Object System.Security.Principal.NTAccount($identity.Name)
                $actualAce = $currentAcl.Audit.Where({$_.IdentityReference -eq $identity.Name})
                $aclRules = ConvertTo-FileSystemAuditRule -AuditRuleList $auditRuleItem -IdentityRef $identityRef
                $results = Compare-FileSystemAuditRule -Expected $aclRules -Actual $actualAce
                $expected += $results.Rules
                $toBeRemoved += $results.Absent

                if ($auditRuleItem.ForcePrincipal)
                {
                    $toBeRemoved += $results.ToBeRemoved
                }
            }

            $isInherited = $toBeRemoved.Rule.Where({$_.IsInherited -eq $true}).Count

            if ($isInherited -gt 0)
            {
                $currentAcl.SetAuditRuleProtection($true,$true)
                Set-Acl -Path $path -AclObject $currentAcl
                $currentAcl = $currentAcl = Get-AuditAcl -Path $Path
            }

            foreach ($rule in $expected)
            {
                if ($rule.Match -eq $false)
                {
                    $currentAcl.AddAuditRule($rule.Rule)
                    Write-CustomVerboseMessage -Action 'ActionAddAudit' -Path $path -Rule $rule.Rule
                }
            }

            foreach ($rule in $toBeRemoved.Rule)
            {
                $ruleRemoval = $currentAcl.RemoveAuditRule($rule)
                if (-not $ruleRemoval)
                {
                    $currentAcl.RemoveAuditRuleSpecific($rule)
                }

                Write-CustomVerboseMessage -Action 'ActionRemoveAudit' -Path $path -Rule $rule
            }

            Set-Acl -Path $path -AclObject $currentAcl
        }
        else
        {
            $message = $localizedData.AclNotFound -f $path
            Write-Verbose -Message $message
        }
    }
    else
    {
        $message = $localizedData.ErrorPathNotFound -f $path
        Write-Verbose -Message $message
    }
}

<#
    .SYNOPSIS
        Test the current state of the resource.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory=$true)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AuditRuleList,

        [Parameter()]
        [bool]
        $Force = $false
    )

    $aclRules = @()

    $inDesiredState = $true
    $inputPath = Get-InputPath($Path)
    $currentAuditAcl = Get-Acl -Path $inputPath -Audit -ErrorAction Stop

    if ($null -ne $currentAuditAcl)
    {
        if ($Force)
        {
            if ($currentAcl.AreAccessRulesProtected -eq $false)
            {
                Write-Verbose -Message ($localizedData.InheritanceDetectedForce -f $Force, $inputPath)
                return $false
            }

            foreach ($auditRuleItem in $AuditRuleList)
            {
                $principal = $auditRuleItem.Principal
                $identity = Resolve-Identity -Identity $principal
                $identityRef = New-Object System.Security.Principal.NTAccount($identity.Name)
                $aclRules += ConvertTo-FileSystemAuditRule -AuditRuleList $auditRuleItem -IdentityRef $identityRef
            }

            $actualAce = $currentAuditAcl.Audit
            $results = Compare-FileSystemAuditRule -Expected $aclRules -Actual $actualAce -Force $auditRuleItem.ForcePrincipal
            $expected = $results.Rules
            $absentToBeRemoved = $results.Absent
            $toBeRemoved = $results.ToBeRemoved
        }
        else
        {
            foreach ($auditRuleItem in $AuditRuleList)
            {
                $principal = $auditruleItem.Principal
                $identity = Resolve-Identity -Identity $principal
                $identityRef = New-Object System.Security.Principal.NTAccount($identity.Name)
                $aclRules = ConvertTo-FileSystemAuditRule -AuditRuleList $auditRuleItem -IdentityRef $identityRef
                $actualAce = $currentAuditAcl.Audit.Where( {$_.IdentityReference -eq $identity.Name})
                $results = Compare-FileSystemAuditRule -Expected $aclRules -Actual $actualAce -Force $auditRuleItem.ForcePrincipal
                $expected += $results.Rules
                $absentToBeRemoved += $results.Absent

                if ($auditRuleItem.ForcePrincipal)
                {
                    $toBeRemoved += $results.ToBeRemoved
                }
            }
        }

        foreach ($rule in $expected)
        {
            if ($rule.Match -eq $false)
            {
                Write-CustomVerboseMessage -Action 'ActionMissPresentPerm' -Path $inputPath -Rule $rule.rule
                $inDesiredState = $false
            }
        }

        if ($absentToBeRemoved.Count -gt 0)
        {
            foreach ($rule in $absentToBeRemoved.Rule)
            {
                Write-CustomVerboseMessage -Action 'ActionAbsentPermission' -Path $inputPath -Rule $rule
            }

            $inDesiredState = $false
        }

        if ($toBeRemoved.Count -gt 0)
        {
            foreach ($rule in $toBeRemoved.Rule)
            {
                Write-CustomVerboseMessage -Action 'ActionNonMatchPermission' -Path $inputPath -Rule $rule
            }

            $inDesiredState = $false
        }
    }
    else
    {
        Write-Verbose -Message ($localizedData.AclNotFound -f $inputPath)
        $inDesiredState = $false
    }

    return $inDesiredState
}

<#
    .SYNOPSIS
        Converts a CimInstance to a File System.Security.AccessControl.FileSystemAuditRule
    
    .PARAMETER AuditRuleList
        A collection of CIM instances to be converted to an FileSystemAuditRule

    .PARAMETER IndentityRef
        Specifies the prinipal to attach to the FileSystemAuditRule
#>
function ConvertTo-FileSystemAuditRule
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance]
        $AuditRuleList,

        [Parameter(Mandatory = $true)]
        [System.Security.Principal.NTAccount]
        $IdentityRef
    )

    $referenceRule = @()

    foreach ($ace in $AuditRuleList.AuditRuleEntry)
    {
        $inheritance = Get-NtfsInheritenceFlag -Inheritance $ace.Inheritance
        $rule = [PSCustomObject]@{
            Rules = New-Object System.Security.AccessControl.FileSystemAuditRule(
                $IdentityRef,
                $ace.FileSystemRights,
                $inheritance.InheritanceFlag,
                $inheritance.PropagationFlag,
                $ace.AuditFlags
            )

            Ensure = $ace.Ensure
        }

        $referenceRule += $rule
    }

    return $referenceRule
}

<#
    .SYNOPSIS
        Compares desired file system audit rules with the current state.

    .PARAMETER Expected
        Specifies the expected state

    .PARAMETER Actual
        Specifies the current state

    .PARAMETER Force
        Specifies if that the Expected auditRules are the only rules to be applied.
#>
function Compare-FileSystemAuditRule
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [PSCustomObject[]]
        $Expected,

        [Parameter()]
        [System.Security.AccessControl.FileSystemAuditRule[]]
        $Actual,

        [Parameter()]
        [bool]
        $Force = $false
    )

    $results = @()
    $toBeRemoved = @()
    $absentToBeRemoved = @()
    $presentRules = $Expected.Where({$_.Ensure -eq 'Present'}).Rules
    $absentRules = $Expected.Where({$_.Ensure -eq 'Absent'}).Rules

    foreach ($referenceRule in $PresentRules)
    {
        $match = Test-FileSystemAuditRuleMatch -ReferenceRule $referenceRule -DifferenceRule $Actual -Force $Force

        if
        (
            ($match.Count -ge 1) -and
            ($match.FileSystemRights.value__ -ge $referenceRule.FileSystemRights.value__)
        )
        {
            $results += [PSCustomObject]@{
                Rule  = $referenceRule
                Match = $true
            }
        }
        else
        {
            $results += [PSCustomObject]@{
                Rule  = $referenceRule
                Match = $false
            }
        }
    }

    foreach ($referenceRule in $AbsentRules)
    {
        $match = Test-FileSystemAuditRuleMatch -ReferenceRule $referenceRule -DifferenceRule $Actual -Force $Force

        if ($match.Count -gt 0)
        {
            $absentToBeRemoved += [PSCustomObject]@{
                Rule = $match
            }
        }
    }

    foreach ($referenceRule in $Actual)
    {
        $match = Test-FileSystemAuditRuleMatch -ReferenceRule $referenceRule -DifferenceRule $Expected.Rules -Force $Force

        if ($match.Count -eq 0)
        {
            $toBeRemoved += [PSCustomObject]@{
                Rule = $referenceRule
            }
        }
    }

    return [PSCustomObject]@{
        Rules = $results
        ToBeRemoved = $toBeRemoved
        Absent = $absentToBeRemoved
    }
}

<#
    .SYNOPSIS
        Tests if files system audit rules match.

    .PARAMETER DifferenceRule
        Specifies the rules in the configuration.

    .PARAMETER ReferenceRule
        Specifies the rules currently applied

    .PARAMETER Force
        Specifies if that the Expected ReferenceRule are the only rules to be applied.
#>
function Test-FileSystemAuditRuleMatch
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Security.AccessControl.FileSystemAuditRule[]]
        [AllowEmptyCollection()]
        $DifferenceRule,

        [Parameter(Mandatory = $true)]
        [System.Security.AccessControl.FileSystemAuditRule]
        $ReferenceRule,

        [Parameter(Mandatory = $true)]
        [bool]
        $Force
    )

    if ($Force)
    {
        $DifferenceRule.Where({
            $_.FileSystemRights -eq $ReferenceRule.FileSystemRights -and
            $_.AuditFlags -eq $ReferenceRule.AuditFlags -and
            $_.InheritanceFlags -eq $ReferenceRule.InheritanceFlags -and
            $_.PropagationFlags -eq $ReferenceRule.PropagationFlags -and
            $_.IdentityReference -eq $ReferenceRule.IdentityReference
        })
    }
    else
    {
        $DifferenceRule.Where({
            ($_.FileSystemRights.value__ -band $ReferenceRule.FileSystemRights.value__) -match
            "$($_.FileSystemRights.value__)|$($ReferenceRule.FileSystemRights.value__)" -and
            (($_.AuditFlags.value__ -eq 3 -and $ReferenceRule.AuditFlags.value__ -in 1..3) -or
            ($_.AuditFlags.value__ -in 1..3 -and $ReferenceRule.AuditFlags.value__ -eq 0) -or
            ($_.AuditFlags.value__ -eq $ReferenceRule.AuditFlags.value__)) -and

            (($_.InheritanceFlags.value__ -eq 3 -and $ReferenceRule.InheritanceFlags.value__ -in 1..3) -or
            ($_.InheritanceFlags.value__ -in 1..3 -and $ReferenceRule.InheritanceFlags.value__ -eq 0) -or
            ($_.InheritanceFlags.value__ -eq $ReferenceRule.InheritanceFlags.value__)) -and
            (($_.PropagationFlags.value__ -eq 3 -and $ReferenceRule.PropagationFlags.value__ -in 1..3) -or
            ($_.PropagationFlags.value__ -in 1..3 -and $ReferenceRule.PropagationFlags.value__ -eq 0) -or
            ($_.PropagationFlags.value__ -eq $ReferenceRule.PropagationFlags.value__)) -and

            $_.IdentityReference -eq $ReferenceRule.IdentityReference
        })
    }
}

<#
    .SYNOPSIS
        Retrieves the Audit authorization data from a filesystem object

    .PARAMETER PATH
        Specifies the path to the target folder.
#>#>
function Get-AuditAcl
{
    [CmdletBinding()]
    [OutputType([System.Security.AccessControl.DirectorySecurity])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    $sacl =  (Get-Item -Path $Path).GetAccessControl('All')
    $auditRules = $sacl.GetAuditRules($true,$true,[System.Security.Principal.NTAccount])
    $sacl | Add-Member -MemberType NoteProperty -Value $auditRules -Name Audit

    return $sacl
}

Export-ModuleMember -Function @('Get-TargetResource','Set-TargetResource','Test-TargetResource')
