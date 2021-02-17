<#PSScriptInfo
.VERSION 1.0.0
.GUID ede9ed8a-808e-4fcc-9c5b-f0bf6e1411e6
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
    This examples shows how to verify all local users require a password.
#>

#Requires -Module AuditSystemDsc

configuration AuditSetting_AuditUsersPasswordNotRequired
{
    Import-DscResource -ModuleName AuditSystemDsc

    node localhost
    {
        AuditSetting LocalAccountWithoutPassword
        {
            Query = "SELECT * FROM Win32_UserAccount WHERE Disabled = $false"
            Property = "PasswordRequired"
            DesiredValue = $true
            Operator = '-eq'
        }
    }
}
