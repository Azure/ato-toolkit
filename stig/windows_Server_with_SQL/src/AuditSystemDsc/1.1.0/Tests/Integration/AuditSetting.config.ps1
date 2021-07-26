# Integration Test Config Template Version: 1.2.1

$configFile = [System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Path, 'json')
if (Test-Path -Path $configFile)
{
    $ConfigurationData = Get-Content -Path $configFile | ConvertFrom-Json
}
else
{
    $ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName = 'localhost'
            }
        )
    }
}

Configuration AuditSetting_AuditNtfsVolumne_Config
{
    Import-DscResource -ModuleName 'AuditSystemDsc'

    node $AllNodes.NodeName
    {
        AuditSetting 'Integration_Test'
        {
            Query = "SELECT * FROM Win32_LogicalDisk WHERE DriveType = '3'"
            Property = "FileSystem"
            DesiredValue = 'NTFS'
            Operator = '-eq'
        }

        AuditSetting LocalAccountWithoutPassword
        {
            NameSpace = 'ROOT/StandardCimv2'
            Query = "SELECT * FROM MSFT_NetIPAddress WHERE InterfaceAlias='Ethernet'"
            Property = "PrefixLength"
            DesiredValue = '24'
            Operator = '-eq'
        }
    }
}
