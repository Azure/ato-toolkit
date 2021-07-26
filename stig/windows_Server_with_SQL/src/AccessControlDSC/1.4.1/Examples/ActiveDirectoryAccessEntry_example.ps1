configuration Sample_ADAccessControl
{
    Import-DscResource -ModuleName AccessControlDsc
    node localhost
    {
        ActiveDirectoryAccessEntry EastOU
        {
            DistinguishedName = "OU=east,DC=contoso,DC=com"
            AccessControlList = @(
                ActiveDirectoryAccessControlList
                {
                    Principal = "contoso\Tier3"
                    ForcePrincipal = $false
                    AccessControlEntry = @(
                        ActiveDirectoryAccessRule
                        {
                            AccessControlType = 'Allow'
                            ActiveDirectoryRights = 'GenericAll'
                            InheritanceType = 'Descendents'
                            Ensure = 'Present'
                        }
                    )
                }
            )
        }
        ActiveDirectoryAccessEntry HelpdeskOU
        {
            DistinguishedName = "OU=dsc,DC=contoso,DC=com"
            AccessControlList = @(
                ActiveDirectoryAccessControlList
                {
                    Principal = "contoso\helpdesk"
                    ForcePrincipal = $true
                    AccessControlEntry = @(
                        ActiveDirectoryAccessRule
                        {
                            AccessControlType = 'Allow'
                            ActiveDirectoryRights = 'Delete'
                            InheritanceType = 'Descendents'
                            InheritedObjectType = 'organizational-unit'
                            Ensure = 'Present'
                        }
                    )
                }
                ActiveDirectoryAccessControlList
                {
                    Principal = "contoso\testgroup"
                    ForcePrincipal = $true
                    AccessControlEntry = @(
                        ActiveDirectoryAccessRule
                        {
                            AccessControlType = 'Allow'
                            ActiveDirectoryRights = 'CreateChild', 'DeleteChild'
                            InheritanceType = 'all'
                            ObjectType = 'computer'
                            Ensure = 'Present'
                        }
                    )
                }
            )
        }
    }
}
