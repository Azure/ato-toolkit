configuration Sample_ADAccessControl
{
    Import-DscResource -ModuleName AccessControlDsc
    node localhost
    {
        ActiveDirectoryAuditRuleEntry WestOU
        {
            DistinguishedName = "OU=West,DC=contoso,DC=com"
            AccessControlList = @(
                ActiveDirectorySystemAccessControlList
                {
                    Principal = "Everyone"
                    ForcePrincipal = $false
                    AccessControlEntry = @(
                        ActiveDirectoryAuditRule
                        {
                            AuditFlags = 'Success'
                            ActiveDirectoryRights = 'GenericAll'
                            InheritanceType = 'Descendents'
                            Ensure = 'Present'
                        }
                    )
                }
            )
        }
        ActiveDirectoryAuditRuleEntry DscOU
        {
            DistinguishedName = "Ou=Dsc,DC=contoso,DC=com"
            AccessControlList = @(
                ActiveDirectorySystemAccessControlList
                {
                    Principal = "Everyone"
                    ForcePrincipal = $true
                    AccessControlEntry = @(
                        ActiveDirectoryAuditRule
                        {
                            AuditFlags = 'Failure'
                            ActiveDirectoryRights = 'Delete'
                            InheritanceType = 'Descendents'
                            InheritedObjectType = 'organizational-unit'
                            Ensure = 'Present'
                        }
                    )
                }
            )
        }
    }
}
