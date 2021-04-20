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
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory=$true)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AccessControlList,

        [Parameter()]
        [bool]
        $Force = $false
    )

    $nameSpace = "root/Microsoft/Windows/DesiredStateConfiguration"
    $cimAccessControlList = New-Object -TypeName 'System.Collections.ObjectModel.Collection`1[Microsoft.Management.Infrastructure.CimInstance]'
    $inputPath = Get-InputPath($Path)

    if (Test-Path -Path $inputPath)
    {
        $fileSystemItem = Get-Item -Path $inputPath -ErrorAction Stop
        $currentAcl = $fileSystemItem.GetAccessControl('Access')

        if ($null -ne $currentAcl)
        {
            $message = $localizedData.AclFound -f $inputPath
            Write-Verbose -Message $message

            foreach ($principal in $AccessControlList)
            {
                $cimAccessControlEntry = New-Object -TypeName 'System.Collections.ObjectModel.Collection`1[Microsoft.Management.Infrastructure.CimInstance]'

                $principalName = $principal.Principal
                $forcePrincipal = $principal.ForcePrincipal

                $identity = Resolve-Identity -Identity $principalName
                $currentPrincipalAccess = $currentAcl.Access.Where({$_.IdentityReference -eq $identity.Name})

                foreach ($access in $currentPrincipalAccess)
                {
                    $accessControlType = $access.AccessControlType.ToString()
                    $fileSystemRights = $access.FileSystemRights.ToString().Split(',').Trim()
                    $Inheritance = Get-NtfsInheritenceName -InheritanceFlag $access.InheritanceFlags.value__ -PropagationFlag $access.PropagationFlags.value__

                    $cimAccessControlEntry += New-CimInstance -ClientOnly -Namespace $nameSpace -ClassName NTFSAccessControlEntry -Property @{
                        AccessControlType = $accessControlType
                        FileSystemRights = @($fileSystemRights)
                        Inheritance = $Inheritance
                        Ensure = ""
                    }
                }

                $cimAccessControlList += New-CimInstance -ClientOnly -Namespace $nameSpace -ClassName NTFSAccessControlList -Property @{
                    Principal = $principalName
                    ForcePrincipal = $forcePrincipal
                    AccessControlEntry = [Microsoft.Management.Infrastructure.CimInstance[]]@($cimAccessControlEntry)
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
        AccessControlList = $cimAccessControlList
    }

    return $returnValue
}

Function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory=$true)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AccessControlList,

        [Parameter()]
        [bool]
        $Force = $false
    )

    $aclRules = @()

    $inputPath = Get-InputPath($Path)

    if (Test-Path -Path $inputPath)
    {
        $fileSystemItem = Get-Item -Path $inputPath
        $currentAcl = $fileSystemItem.GetAccessControl('Access')

        if ($null -ne $currentAcl)
        {
            if ($Force)
            {
                # If inheritance is set, disable it and clear inherited access rules
                if (-not $currentAcl.AreAccessRulesProtected)
                {
                    Write-Verbose -Message ($localizedData.ResetDisableInheritance)
                    $currentAcl.SetAccessRuleProtection($true, $false)
                }

                # Removing all access rules to ensure a blank list
                if ($null -ne $currentAcl.Access)
                {
                    foreach ($ace in $currentAcl.Access)
                    {
                        # Added this condition and function to address Win32 API Bug: https://github.com/PowerShell/Win32-OpenSSH/issues/750
                        if ($ace.IdentityReference -match 'APPLICATION PACKAGE AUTHORITY\\.*')
                        {
                            $ace = Update-NtfsAccessControlEntry -AccessControlEntry $ace
                        }

                        $currentAcl.RemoveAccessRuleAll($ace)
                        Write-CustomVerboseMessage -Action 'ActionRemoveAccess' -Path $inputPath -Rule $ace
                    }
                }
            }

            foreach ($accessControlItem in $AccessControlList)
            {
                $principal = $accessControlItem.Principal
                $identity = Resolve-Identity -Identity $principal
                $identityRef = New-Object System.Security.Principal.NTAccount($identity.Name)
                $actualAce = $currentAcl.Access.Where({$_.IdentityReference -eq $identity.Name})
                $aclRules = ConvertTo-FileSystemAccessRule -AccessControlList $accessControlItem -IdentityRef $identityRef
                $results = Compare-NtfsRule -Expected $aclRules -Actual $actualAce -Force $accessControlItem.ForcePrincipal
                $expected += $results.Rules
                $toBeRemoved += $results.Absent

                if ($accessControlItem.ForcePrincipal)
                {
                    $toBeRemoved += $results.ToBeRemoved
                }
            }

            $isInherited = $toBeRemoved.Rule.Where({$_.IsInherited -eq $true}).Count

            if ($isInherited -gt 0)
            {
                $currentAcl.SetAccessRuleProtection($true, $true)
                $fileSystemItem.SetAccessControl($currentAcl)
                $currentAcl = $fileSystemItem.GetAccessControl('Access')
            }

            foreach ($rule in $toBeRemoved.Rule)
            {
                try
                {
                    Write-CustomVerboseMessage -Action 'ActionRemoveAccess' -Path $inputPath -Rule $rule
                    $currentAcl.RemoveAccessRuleSpecific($rule)
                }
                catch
                {
                    try
                    {
                        #If failure due to Idenitity translation issue then create the same rule with the identity as a sid to remove account
                        $sid = ConvertTo-SID -IdentityReference $rule.IdentityReference.Value
                        $sidRule = New-Object System.Security.AccessControl.FileSystemRights($sid, $rule.FileSystemRights.value__, $rule.InheritanceFlags.value__, $rule.PropagationFlags.value__, $rule.AccessControlType.value__)
                        Write-CustomVerboseMessage -Action 'ActionRemoveAccess' -Path $inputPath -Rule $sidRule
                        $currentAcl.RemoveAccessRuleSpecific($sidRule)
                    }
                    catch
                    {
                        Write-Verbose -Message ($localizedData.AclNotFound -f $($rule.IdentityReference.Value))
                    }
                }
            }

            foreach ($rule in $expected.Rule)
            {
                Write-CustomVerboseMessage -Action 'ActionAddAccess' -Path $inputPath -Rule $rule
                $currentAcl.AddAccessRule($rule)
            }

            $fileSystemItem.SetAccessControl($currentAcl)
        }
        else
        {
            Write-Verbose -Message ($localizedData.AclNotFound -f $inputPath)
        }
    }
    else
    {
        Write-Verbose -Message ($localizedData.ErrorPathNotFound -f $inputPath)
    }
}

Function Test-TargetResource
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
        $AccessControlList,

        [Parameter()]
        [bool]
        $Force = $false
    )

    $aclRules = @()

    $inDesiredState = $True
    $inputPath = Get-InputPath($Path)

    if (Test-Path -Path $inputPath)
    {
        $fileSystemItem = Get-Item -Path $inputPath
        $currentAcl = $fileSystemItem.GetAccessControl('Access')
        $mappedAcl = Update-FileSystemRightsMapping($currentAcl)

        if ($null -ne $currentAcl)
        {
            if ($Force)
            {
                if ($currentAcl.AreAccessRulesProtected -eq $false)
                {
                    Write-Verbose -Message ($localizedData.InheritanceDetectedForce -f $Force, $inputPath)
                    return $false
                }

                foreach ($accessControlItem in $AccessControlList)
                {
                    $principal = $accessControlItem.Principal
                    $identity = Resolve-Identity -Identity $principal
                    $identityRef = New-Object System.Security.Principal.NTAccount($identity.Name)
                    $aclRules += ConvertTo-FileSystemAccessRule -AccessControlList $accessControlItem -IdentityRef $identityRef
                }

                $actualAce = $mappedAcl.Access
                $results = Compare-NtfsRule -Expected $aclRules -Actual $actualAce -Force $accessControlItem.ForcePrincipal
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
                    $aclRules = ConvertTo-FileSystemAccessRule -AccessControlList $accessControlItem -IdentityRef $identityRef
                    $actualAce = $mappedAcl.Access.Where({$_.IdentityReference -eq $identity.Name})
                    $results = Compare-NtfsRule -Expected $aclRules -Actual $actualAce -Force $accessControlItem.ForcePrincipal
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
    }
    else
    {
        Write-Verbose -Message ($localizedData.ErrorPathNotFound -f $inputPath)
        $inDesiredState = $false
    }

    return $inDesiredState
}

Function ConvertTo-FileSystemAccessRule
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

    if
    (
        $IdentityRef -match 'APPLICATION PACKAGE AUTHORITY\\.*' -and
        (Get-PSCallStack)[1].Command -eq 'Set-TargetResource'
    )
    {
        $identityRef = Remove-NtPrincipalDomain -Identity $IdentityRef
    }

    foreach ($ace in $AccessControlList.AccessControlEntry)
    {
        $inheritance = Get-NtfsInheritenceFlag -Inheritance $ace.Inheritance
        $rule = [PSCustomObject]@{
            Rules = New-Object System.Security.AccessControl.FileSystemAccessRule(
                $IdentityRef,
                $ace.FileSystemRights,
                $Inheritance.InheritanceFlag,
                $Inheritance.PropagationFlag,
                $ace.AccessControlType
            )
            Ensure = $ace.Ensure
        }

        $referenceRule += $rule
    }

    return $referenceRule
}

Function Compare-NtfsRule
{
    param
    (
        [Parameter(Mandatory = $true)]
        [PSCustomObject[]]
        $Expected,

        [Parameter()]
        [System.Security.AccessControl.FileSystemAccessRule[]]
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
        $match = Test-FileSystemAccessRuleMatch -ReferenceRule $referenceRule -DifferenceRule $Actual -Force $Force

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
        $match = Test-FileSystemAccessRuleMatch -ReferenceRule $referenceRule -DifferenceRule $Actual -Force $Force

        if ($match.Count -gt 0)
        {
            $absentToBeRemoved += [PSCustomObject]@{
                Rule = $match
            }
        }
    }

    foreach ($referenceRule in $Actual)
    {
        $match = Test-FileSystemAccessRuleMatch -ReferenceRule $referenceRule -DifferenceRule $Expected.Rules -Force $Force

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

Function Update-FileSystemRightsMapping
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Ace
    )

    foreach ($rule in $Ace.Access)
    {
        $rightsBand = [int]0xf0000000 -band $rule.FileSystemRights.value__
        if (($rightsBand -gt 0) -or ($rightsBand -lt 0))
        {
            $sid = ConvertTo-SID -IdentityReference $rule.IdentityReference
            $mappedRight = Get-MappedGenericRight($rule.FileSystemRights)
            $mappedRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                $sid,
                $mappedRight,
                $rule.InheritanceFlags,
                $rule.PropagationFlags,
                $rule.AccessControlType
            )

            try
            {
                $Ace.RemoveAccessRule($rule)
            }
            catch
            {
                $sidRule = $Ace.AccessRuleFactory(
                    $sid,
                    $rule.FileSystemRights,
                    $rule.IsInherited,
                    $rule.InheritanceFlags,
                    $rule.PropagationFlags,
                    $rule.AccessControlType
                )
                $Ace.RemoveAccessRule($sidRule)
            }

            $Ace.AddAccessRule($mappedRule)
        }
    }

    return $Ace
}

Function Get-MappedGenericRight
{
    param
    (
        [Parameter(Mandatory = $true)]
        [int]
        $Rights
    )

    [int]$genericRead = 0x80000000
    [int]$genericWrite = 0x40000000
    [int]$genericExecute = 0x20000000
    [int]$genericFullControl = 0x10000000
    [int]$fsarGenericRead = (
        [System.Security.AccessControl.FileSystemRights]::ReadAttributes -bor
        [System.Security.AccessControl.FileSystemRights]::ReadData -bor
        [System.Security.AccessControl.FileSystemRights]::ReadExtendedAttributes -bor
        [System.Security.AccessControl.FileSystemRights]::ReadPermissions -bor
        [System.Security.AccessControl.FileSystemRights]::Synchronize
    )

    [int]$fsarGenericWrite = (
        [System.Security.AccessControl.FileSystemRights]::AppendData -bor
        [System.Security.AccessControl.FileSystemRights]::WriteAttributes -bor
        [System.Security.AccessControl.FileSystemRights]::WriteData -bor
        [System.Security.AccessControl.FileSystemRights]::WriteExtendedAttributes -bor
        [System.Security.AccessControl.FileSystemRights]::ReadPermissions -bor
        [System.Security.AccessControl.FileSystemRights]::Synchronize
    )

    [int]$fsarGenericExecute = (
        [System.Security.AccessControl.FileSystemRights]::ExecuteFile -bor
        [System.Security.AccessControl.FileSystemRights]::ReadPermissions -bor
        [System.Security.AccessControl.FileSystemRights]::ReadAttributes -bor
        [System.Security.AccessControl.FileSystemRights]::Synchronize
    )

    [int]$fsarGenericFullControl = [System.Security.AccessControl.FileSystemRights]::FullControl
    $fsarRights = 0

    if (($Rights -band $genericRead) -eq $genericRead)
    {
        $fsarRights = $fsarRights -bor $fsarGenericRead
    }

    if (($Rights -band $genericWrite) -eq $genericWrite)
    {
        $fsarRights = $fsarRights -bor  $fsarGenericWrite
    }

    if (($Rights -band $genericExecute) -eq $genericExecute)
    {
        $fsarRights = $fsarRights -bor  $fsarGenericExecute
    }

    if (($Rights -band $genericFullControl) -eq $genericFullControl)
    {
        $fsarRights = $fsarRights -bor  $fsarGenericFullControl
    }

    if ($fsarRights -ne 0)
    {
        return $fsarRights
    }

    return $Rights
}

Function Get-InputPath
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    $returnPath = $Path

    # If Path has a environment variable, convert it to a locally usable path
    $returnPath = [System.Environment]::ExpandEnvironmentVariables($Path)

    return $returnPath
}

function Test-FileSystemAccessRuleMatch
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Security.AccessControl.FileSystemAccessRule[]]
        [AllowEmptyCollection()]
        $DifferenceRule,

        [Parameter(Mandatory = $true)]
        [System.Security.AccessControl.FileSystemAccessRule]
        $ReferenceRule,

        [Parameter(Mandatory = $true)]
        [bool]
        $Force
    )

    if ($Force)
    {
        $DifferenceRule.Where({
                $_.FileSystemRights -eq $ReferenceRule.FileSystemRights -and
                $_.InheritanceFlags -eq $ReferenceRule.InheritanceFlags -and
                $_.PropagationFlags -eq $ReferenceRule.PropagationFlags -and
                $_.AccessControlType -eq $ReferenceRule.AccessControlType -and
                $_.IdentityReference -eq $ReferenceRule.IdentityReference
            })
    }
    else
    {
        $DifferenceRule.Where({
                ($_.FileSystemRights.value__ -band $ReferenceRule.FileSystemRights.value__) -match
                "$($_.FileSystemRights.value__)|$($ReferenceRule.FileSystemRights.value__)" -and
                (($_.InheritanceFlags.value__ -eq 3 -and $ReferenceRule.InheritanceFlags.value__ -in 1..3) -or
                ($_.InheritanceFlags.value__ -in 1..3 -and $ReferenceRule.InheritanceFlags.value__ -eq 0) -or
                ($_.InheritanceFlags.value__ -eq $ReferenceRule.InheritanceFlags.value__)) -and
                (($_.PropagationFlags.value__ -eq 3 -and $ReferenceRule.PropagationFlags.value__ -in 1..3) -or
                ($_.PropagationFlags.value__ -in 1..3 -and $ReferenceRule.PropagationFlags.value__ -eq 0) -or
                ($_.PropagationFlags.value__ -eq $ReferenceRule.PropagationFlags.value__)) -and
                $_.AccessControlType -eq $ReferenceRule.AccessControlType -and
                $_.IdentityReference -eq $ReferenceRule.IdentityReference
        })
    }
}

function Update-NtfsAccessControlEntry
{
    [CmdletBinding()]
    [OutputType([System.Security.AccessControl.FileSystemAccessRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Security.AccessControl.FileSystemAccessRule]
        $AccessControlEntry
    )

    $identity = Remove-NtPrincipalDomain -Identity $AccessControlEntry.IdentityReference
    $ace = New-Object -Type System.Security.AccessControl.FileSystemAccessRule -ArgumentList (
        $identity,
        $AccessControlEntry.FileSystemRights,
        $AccessControlEntry.AccessControlType
    )
    return $ace
}
