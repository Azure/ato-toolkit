<#PSScriptInfo
.VERSION 1.0.0
.GUID ac6e5b9b-c16b-46c6-a3ba-172da1b4a212
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
    This examples shows how to verify service pack level by
    asserting the DesiredValue (6.2.9200) is less than or equal
    to the operating system build number.
#>

#Requires -Module AuditSystemDsc

configuration AuditSetting_VerifyServicePackLevel
{
    Import-DscResource -ModuleName AuditSystemDsc

    node localhost
    {
        AuditSetting OperatingSystemVersion
        {
            Property = 'Version'
            Operator = '-le'
            Query = 'SELECT * FROM Win32_OperatingSystem'
            DesiredValue = '6.2.9200'
        }
    }
}
