<#PSScriptInfo
.VERSION 1.0.0
.GUID 40050783-8d84-4d71-be0c-a03c8da76133
.AUTHOR Daniel Scott-Raynsford
.COMPANYNAME
.COPYRIGHT (c) 2018 Daniel Scott-Raynsford. All rights reserved.
.TAGS DSCConfiguration
.LICENSEURI https://github.com/PlagueHO/FileContentDsc/blob/master/LICENSE
.PROJECTURI https://github.com/PlagueHO/FileContentDsc
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES First version.
.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core
#>

#Requires -module FileContentDsc

<#
    .DESCRIPTION
    Set all occrurances of the string `%appname%` to be Awesome App`
    in the file `c:\inetpub\wwwroot\default.htm`.
#>
Configuration ReplaceText_ReplacePlainText_Config
{
    Import-DSCResource -ModuleName FileContentDsc

    Node localhost
    {
        ReplaceText SetText
        {
            Path   = 'c:\inetpub\wwwroot\default.htm'
            Search = '%appname%'
            Type   = 'Text'
            Text   = 'Awesome App'
        }
    }
}
