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

Function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String]
        $DistinguishedName,

        [Parameter(Mandatory=$true)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AccessControlList,

        [Parameter()]
        [bool]
        $Force = $false
    )

    Assert-Module -ModuleName 'ActiveDirectory'
    Import-Module -Name 'ActiveDirectory' -Verbose:$false

    $nameSpace = "root/Microsoft/Windows/DesiredStateConfiguration"
    $cimAccessControlList = New-Object -TypeName 'System.Collections.ObjectModel.Collection`1[Microsoft.Management.Infrastructure.CimInstance]'

    $path = Join-Path -Path "AD:\" -ChildPath $DistinguishedName

    if (Test-Path -Path $path)
    {
        $currentACL = Get-Acl -Path $path -Audit -ErrorAction Stop

        if ($null -ne $currentACL)
        {
            $message = $localizedData.AclFound -f $path
            Write-Verbose -Message $message

            foreach ($principal in $AccessControlList)
            {
                $cimAccessControlEntry = New-Object -TypeName 'System.Collections.ObjectModel.Collection`1[Microsoft.Management.Infrastructure.CimInstance]'

                $principalName = $principal.Principal
                $forcePrincipal = $principal.ForcePrincipal

                $identity = Resolve-Identity -Identity $principalName
                $currentPrincipalAccess = $currentACL.Audit.Where({$_.IdentityReference -eq $identity.Name})

                foreach ($access in $currentPrincipalAccess)
                {
                    $auditFlags = $access.AuditFlags.ToString()
                    $activeDirectoryRights = $access.ActiveDirectoryRights.ToString().Split(',').Trim()
                    $inheritanceType = $access.InheritanceType.ToString()
                    $inheritedObjectType = $access.InheritedObjectType.ToString()

                    $cimAccessControlEntry += New-CimInstance -ClientOnly -Namespace $NameSpace -ClassName ActiveDirectoryAuditRule -Property @{
                        ActiveDirectoryRights = @($activeDirectoryRights)
                        AuditFlags = $auditFlags
                        InheritanceType = $inheritanceType
                        InheritedObjectType = $inheritedObjectType
                        Ensure = ""
                    }
                }

                $CimAccessControlList += New-CimInstance -ClientOnly -Namespace $NameSpace -ClassName ActiveDirectorySystemAccessControlList -Property @{
                    Principal = $principalName
                    ForcePrincipal = $forcePrincipal
                    AccessControlEntry = [Microsoft.Management.Infrastructure.CimInstance[]]@($cimAccessControlEntry)
                }
            }

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

    $ReturnValue = @{
        Force = $Force
        DistinguishedName = $DistinguishedName
        AccessControlList = $CimAccessControlList
    }

    return $ReturnValue
}

Function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String]
        $DistinguishedName,

        [Parameter(Mandatory=$true)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AccessControlList,

        [Parameter()]
        [bool]
        $Force = $false
    )

    Assert-Module -ModuleName 'ActiveDirectory'
    Import-Module -Name 'ActiveDirectory' -Verbose:$false

    $path = Join-Path -Path "AD:\" -ChildPath $DistinguishedName

    if (Test-Path -Path $path)
    {
        $currentAcl = Get-Acl -Path $path -Audit
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

            foreach ($accessControlItem in $AccessControlList)
            {
                $principal = $accessControlItem.Principal
                $identity = Resolve-Identity -Identity $principal
                $identityRef = New-Object System.Security.Principal.NTAccount($identity.Name)
                $actualAce = $currentAcl.Audit.Where({$_.IdentityReference -eq $identity.Name})
                $aclRules = ConvertTo-ActiveDirectoryAuditRule -AccessControlList $accessControlItem -IdentityRef $identityRef
                $results = Compare-ActiveDirectoryAuditRule -Expected $aclRules -Actual $actualAce
                $expected += $results.Rules
                $toBeRemoved += $results.Absent

                if ($accessControlItem.ForcePrinciPal)
                {
                    $toBeRemoved += $results.ToBeRemoved
                }
            }

            $isInherited = $toBeRemoved.Rule.Where({$_.IsInherited -eq $true}).Count

            if ($isInherited -gt 0)
            {
                $currentAcl.SetAuditRuleProtection($true,$true)
                Set-Acl -Path $path -AclObject $currentAcl
                $currentAcl = Get-Acl -Path $path -Audit
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

Function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String]
        $DistinguishedName,

        [Parameter(Mandatory=$true)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AccessControlList,

        [Parameter()]
        [bool]
        $Force = $false
    )

    Assert-Module -ModuleName 'ActiveDirectory'
    Import-Module -Name 'ActiveDirectory' -Verbose:$false

    $inDesiredState = $true
    $path = Join-Path -Path "AD:\" -ChildPath $DistinguishedName

    if (Test-Path -Path $path)
    {
        $currentACL = Get-Acl -Path $path -Audit

        if ($null -ne $currentACL)
        {
            if ($Force)
            {
                if ($currentAcl.AreAuditRulesProtected -eq $false)
                {
                    Write-Verbose -Message ($localizedData.InheritanceDetectedForce -f $Force, $path)
                    return $false
                }

                foreach ($accessControlItem in $AccessControlList)
                {
                    $principal = $accessControlItem.Principal
                    $identity = Resolve-Identity -Identity $principal
                    $identityRef = New-Object System.Security.Principal.NTAccount($identity.Name)
                    $aclRules += ConvertTo-ActiveDirectoryAuditRule -AccessControlList $accessControlItem -IdentityRef $identityRef
                }

                $actualAce = $currentAcl.Audit
                $results = Compare-ActiveDirectoryAuditRule -Expected $aclRules -Actual $actualAce
                $expected = $results.Rules
                $absentToBeRemoved = $results.Absent
                $toBeRemoved = $results.ToBeRemoved
            }
            else
            {
                foreach ($accessControlItem in $AccessControlList)
                {
                    $principal = $accessControlItem.Principal
                    $identity = Resolve-Identity -Identity $principal
                    $identityRef = New-Object System.Security.Principal.NTAccount($identity.Name)
                    $aclRules = ConvertTo-ActiveDirectoryAuditRule -AccessControlList $accessControlItem -IdentityRef $identityRef
                    $actualAce = $currentAcl.Audit.Where( {$_.IdentityReference -eq $identity.Name})
                    $results = Compare-ActiveDirectoryAuditRule -Expected $aclRules -Actual $actualAce
                    $expected += $results.Rules
                    $absentToBeRemoved += $results.Absent

                    if ($accessControlItem.ForcePrincipal)
                    {
                        $toBeRemoved += $results.ToBeRemoved
                    }
                }
            }

            foreach ($rule in $expected)
            {
                if ($rule.Match -eq $false)
                {
                    Write-CustomVerboseMessage -Action 'ActionMissPresentAudit' -Path $path -Rule $rule.Rule
                    $inDesiredState = $false
                }
            }

            if ($absentToBeRemoved.Count -gt 0)
            {
                foreach ($rule in $absentToBeRemoved.Rule)
                {
                    Write-CustomVerboseMessage -Action 'ActionAbsentAudit' -Path $path -Rule $rule
                }

                $inDesiredState = $false
            }

            if ($toBeRemoved.Count -gt 0)
            {
                foreach ($rule in $toBeRemoved.Rule)
                {
                    Write-CustomVerboseMessage -Action 'ActionNonMatchAudit' -Path $path -Rule $rule
                }

                $inDesiredState = $false
            }
        }
        else
        {
            $message = $localizedData.AclNotFound -f $path
            Write-Verbose -Message $message
            $inDesiredState = $false
        }
    }
    else
    {
        $message = $localizedData.ErrorPathNotFound -f $path
        Write-Verbose -Message $message
        $inDesiredState = $false
    }

    return $inDesiredState
}

Function ConvertTo-ActiveDirectoryAuditRule
{
    param
    (
        [Parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance]
        $AccessControlList,

        [Parameter(Mandatory = $true)]
        [System.Security.Principal.NTAccount]
        $IdentityRef
    )

    $referenceRule = @()

    foreach ($ace in $AccessControlList.AccessControlEntry)
    {
        # ActiveDirectoryAuditRule overloads require identity, adRights and auditFlags, adding the optional overloads, in order, via if statements
        $auditRuleOverloads = @($IdentityRef, $ace.ActiveDirectoryRights, $ace.AuditFlags)

        if ($null -ne $ace.ObjectType)
        {
            $auditRuleOverloads += Get-DelegationRightsGuid -ObjectName $ace.ObjectType
        }

        if ($null -ne $ace.InheritanceType)
        {
            $auditRuleOverloads += $ace.InheritanceType -as [int]
        }

        if (($null -ne $ace.InheritedObjectType) -and ($null -ne $ace.InheritanceType))
        {
            $auditRuleOverloads += Get-DelegationRightsGuid -ObjectName $ace.InheritedObjectType
        }

        $rule = [PSCustomObject]@{
            Rules  = New-Object -TypeName System.DirectoryServices.ActiveDirectoryAuditRule -ArgumentList $auditRuleOverloads
            Ensure = $ace.Ensure
        }

        $referenceRule += $rule
    }

    return $referenceRule
}

Function Compare-ActiveDirectoryAuditRule
{
    param
    (
        [Parameter(Mandatory = $true)]
        [PSCustomObject[]]
        $Expected,

        [Parameter()]
        [System.DirectoryServices.ActiveDirectoryAuditRule[]]
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
    foreach ($referenceRule in $presentRules)
    {
        $match = Test-ActiveDirectoryAuditRuleMatch -ReferenceRule $referenceRule -DifferenceRule $Actual -Force $Force

        if
        (
            ($match.Count -ge 1) -and
            ($match.ActiveDirectoryRights.value__ -ge $referenceRule.ActiveDirectoryRights.value__)
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

    foreach ($referenceRule in $absentRules)
    {
        $match = Test-ActiveDirectoryAuditRuleMatch -ReferenceRule $referenceRule -DifferenceRule $Actual -Force $Force

        if ($match.Count -gt 0)
        {
            $absentToBeRemoved += [PSCustomObject]@{
                Rule = $match
            }
        }
    }

    foreach ($referenceRule in $Actual)
    {
        $match = Test-ActiveDirectoryAuditRuleMatch -ReferenceRule $referenceRule -DifferenceRule $Expected.Rules -Force $Force

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

function Test-ActiveDirectoryAuditRuleMatch
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.DirectoryServices.ActiveDirectoryAuditRule[]]
        [AllowEmptyCollection()]
        $DifferenceRule,

        [Parameter(Mandatory = $true)]
        [System.DirectoryServices.ActiveDirectoryAuditRule]
        $ReferenceRule,

        [Parameter(Mandatory = $true)]
        [bool]
        $Force
    )

    if ($Force)
    {
        $DifferenceRule.Where({
            $_.ActiveDirectoryRights -eq $ReferenceRule.ActiveDirectoryRights -and
            $_.AuditFlags -eq $ReferenceRule.AuditFlags -and
            $_.ObjectType -eq $ReferenceRule.ObjectType -and
            $_.InheritanceType -eq $ReferenceRule.InheritanceType -and
            $_.InheritedObjectType -eq $ReferenceRule.InheritedObjectType -and
            $_.IdentityReference -eq $ReferenceRule.IdentityReference
        })
    }
    else
    {
        $DifferenceRule.Where({
            ($_.ActiveDirectoryRights.value__ -band $ReferenceRule.ActiveDirectoryRights.value__) -match
            "$($_.ActiveDirectoryRights.value__)|$($ReferenceRule.ActiveDirectoryRights.value__)" -and
            (($_.AuditFlags.value__ -eq 3 -and $ReferenceRule.AuditFlags.value__ -in 1..3) -or
            ($_.AuditFlags.value__ -in 1..3 -and $ReferenceRule.AuditFlags.value__ -eq 0) -or
            ($_.AuditFlags.value__ -eq $ReferenceRule.AuditFlags.value__)) -and
            $_.ObjectType -eq $ReferenceRule.ObjectType -and
            $_.InheritanceType -eq $ReferenceRule.InheritanceType -and
            $_.InheritedObjectType -eq $ReferenceRule.InheritedObjectType -and
            $_.IdentityReference -eq $ReferenceRule.IdentityReference
        })
    }
}
