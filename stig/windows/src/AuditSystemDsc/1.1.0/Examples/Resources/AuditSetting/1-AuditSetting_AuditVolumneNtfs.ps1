<#PSScriptInfo
.VERSION 1.0.0
.GUID 9a10bb5d-84cc-45fa-a3ca-24d83ff7e1e1
.AUTHOR Jason Walker
.COMPANYNAME
.COPYRIGHT
.TAGS DSCConfiguration
.LICENSEURI https://github.com/jcwalker/AuditSystemDsc/blob/dev/LICENSE
.PROJECTURI https://github.com/jcwalker/AuditSystemDsc/
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
First version
#>

<#
.DESCRIPTION 
    This examples shows how to verify no volumes are formated anything other than NTFS
#>

#Requires -Module AuditSystemDsc

configuration AuditSetting_AuditVolumneNtfs
{
    Import-DscResource -ModuleName AuditSystemDsc

    node localhost
    {
        AuditSetting AuditNtfsVolumne
        {
            Query = "SELECT * FROM Win32_LogicalDisk WHERE DriveType = '3'"
            Property = "FileSystem"
            DesiredValue = 'NTFS'
            Operator = '-eq'
        }
    }
}
