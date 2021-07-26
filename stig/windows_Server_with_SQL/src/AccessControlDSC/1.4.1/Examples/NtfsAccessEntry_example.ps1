configuration Sample_NTFSAccessControl
{
    Import-DscResource -ModuleName AccessControlDsc
    node localhost
    {
        NTFSAccessEntry Test
        {
            Path = "c:\test"
            AccessControlList = @(
                NTFSAccessControlList
                {
                    Principal = "Everyone"
                    ForcePrincipal = $true
                    AccessControlEntry = @(
                        NTFSAccessControlEntry
                        {
                            AccessControlType = 'Allow'
                            FileSystemRights = 'FullControl'
                            Inheritance = 'This folder and files'
                            Ensure = 'Present'
                        }
                    )               
                }
                NTFSAccessControlList
                {
                    Principal = "Users"
                    ForcePrincipal = $false
                    AccessControlEntry = @(
                        NTFSAccessControlEntry
                        {
                            AccessControlType = 'Allow'
                            FileSystemRights = 'FullControl'
                            Inheritance = 'This folder and files'
                            Ensure = 'Present'
                        }
                    )               
                }
            )
        }
        NTFSAccessEntry Test2
        {
            Path = "c:\test2"
            AccessControlList = @(
                NTFSAccessControlList
                {
                    Principal = "Everyone"
                    ForcePrincipal = $true
                    AccessControlEntry = @(
                        NTFSAccessControlEntry
                        {
                            AccessControlType = 'Allow'
                            FileSystemRights = 'FullControl'
                            Inheritance = 'This folder and files'
                            Ensure = 'Present'
                        }
                    )               
                }
                NTFSAccessControlList
                {
                    Principal = "Users"
                    ForcePrincipal = $false
                    AccessControlEntry = @(
                        NTFSAccessControlEntry
                        {
                            AccessControlType = 'Allow'
                            FileSystemRights = 'FullControl'
                            Inheritance = 'This folder and files'
                            Ensure = 'Present'
                        }
                    )               
                }
            )
        }
    }
}

