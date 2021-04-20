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
    This examples shows how to verify all local users require a password.
#>

#Requires -Module AuditSystemDsc

configuration AuditSetting_VerifyNetworkPrefixLength
{
    Import-DscResource -ModuleName AuditSystemDsc

    node localhost
    {
        AuditSetting VerifyNetworkPrefixLength
        {
            NameSpace = 'ROOT/StandardCimv2'
            Query = "SELECT * FROM MSFT_NetIPAddress WHERE InterfaceAlias='Ethernet'"
            Property = "PrefixLength"
            DesiredValue = '24'
            Operator = '-eq'
        }
    }
}
