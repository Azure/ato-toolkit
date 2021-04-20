<#PSScriptInfo
.VERSION 1.0.0
.GUID 6a6a7523-91c3-4038-b7f1-178b8dd6803d
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
    Set all occrurances of the string `%secret%` to be the value in
    the password set in the parameter $Secret PSCredential object
    in the file `c:\inetpub\wwwroot\default.htm`.
#>
Configuration ReplaceText_ReplacePlainSecretText_Config
{
    param
    (
        [Parameter()]
        [ValidateNotNullorEmpty()]
        [PSCredential]
        $Secret
    )

    Import-DSCResource -ModuleName FileContentDsc

    Node localhost
    {
        ReplaceText SetSecretText
        {
            Path   = 'c:\inetpub\wwwroot\default.htm'
            Search = '%secret%'
            Type   = 'Secret'
            Secret = $Secret
        }
    }
}
