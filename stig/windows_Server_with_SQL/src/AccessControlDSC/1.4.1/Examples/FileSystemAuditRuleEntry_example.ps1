configuration Sample_FileAuditEntry
{
    Import-DscResource -ModuleName AccessControlDsc

    node localhost
    {
        FileSystemAuditRuleEntry auditFolder
        {
            Path = "C:\auditFolder\auditChildFolder"
            Force = $true
            AuditRuleList = @(
                FileSystemAuditRuleList
                {
                    Principal = 'users'
                    ForcePrincipal = $true
                    AuditRuleEntry = @(
                        FileSystemAuditRule
                        {
                            AuditFlags = 'Success'
                            FileSystemRights = 'Write'
                            Inheritance = 'This folder and files'
                            Ensure = 'Present'
                        }
                    )
                }
            )
        }

        FileSystemAuditRuleEntry SqlInstallFolderAuditing
        {
            Path = "C:\Program Files\SqlServerInstallation"
            Force = $false
            AuditRuleList = @(
                FileSystemAuditRuleList
                {
                    Principal = 'Everyone'
                    ForcePrincipal = $false
                    AuditRuleEntry = @(
                        FileSystemAuditRule
                        {
                            AuditFlags = 'Success'
                            FileSystemRights = 'Traverse','ExecuteFile','ListDirectory','ReadData','ReadExtendedAttributes','ReadAttributes','CreateFiles','WriteData','CreateDirectories','AppendData','WriteAttributes','WriteExtendedAttributes','Delete','ReadPermissions'
                            Inheritance = 'This folder subfolders and files'
                            Ensure = 'Present'
                        }
                    )
                }

                FileSystemAuditRuleList
                {
                    Principal = 'Everyone'
                    ForcePrincipal = $false
                    AuditRuleEntry = @(
                        FileSystemAuditRule
                        {
                            AuditFlags = 'Failure'
                            FileSystemRights = 'Traverse','ExecuteFile','ListDirectory','ReadData','ReadExtendedAttributes','ReadAttributes','CreateFiles','WriteData','CreateDirectories','AppendData','WriteAttributes','WriteExtendedAttributes','Delete','ReadPermissions'
                            Inheritance = 'This folder subfolders and files'
                            Ensure = 'Present'
                        }
                    )
                }
            )
        }
    }
}
