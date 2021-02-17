<#PSScriptInfo
.VERSION 1.0.0
.GUID 89fa6d5d-c121-4502-8bac-5d3ea66e8e80
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
    Set all `Core.Password` keys to the password provided in the $Secret
    credential object or add it if it is missing in the file `c:\myapp\myapp.conf`.
#>
Configuration KeyValuePairFile_SetSecretTextPair_Config
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
        KeyValuePairFile SetCorePassword
        {
            Path   = 'c:\myapp\myapp.conf'
            Name   = 'Core.Password'
            Ensure = 'Present'
            Type   = 'Secret'
            Secret = $Secret
        }
    }
}
