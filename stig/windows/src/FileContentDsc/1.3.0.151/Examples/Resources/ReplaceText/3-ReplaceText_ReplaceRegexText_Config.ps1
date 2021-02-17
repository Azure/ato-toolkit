<#PSScriptInfo
.VERSION 1.0.0
.GUID b29bfcd1-95e1-47e1-971c-a2fffb223113
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
    Set all occrurances of a string matching the regular expression
    `<img src=['``"][a-zA-Z0-9.]*['``"]>` with the text `<img src="imgs/placeholder.jpg">`
    in the file `c:\inetpub\wwwroot\default.htm`
#>
Configuration ReplaceText_ReplaceRegexText_Config
{
    Import-DSCResource -ModuleName FileContentDsc

    Node localhost
    {
        ReplaceText SetTextWithRegex
        {
            Path   = 'c:\inetpub\wwwroot\default.htm'
            Search = "<img src=['`"][a-zA-Z0-9.]*['`"]>"
            Type   = 'Text'
            Text   = '<img src="imgs/placeholder.jpg">'
        }
    }
}
