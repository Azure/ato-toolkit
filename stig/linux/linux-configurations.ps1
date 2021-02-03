# configuration data for all supported STIG deployment templates
$configurationData = @{
    AllNodes = @(
        @{
            NodeName  = 'CentOS79'
            STIGType  = 'RedHat'
            OsVersion = '7'
            SkipRule  = @('V-204623', 'V-204399.a', 'V-204399.b', 'V-204400', 'V-204403')
        },
        @{
            NodeName  = 'CentOS78'
            STIGType  = 'RedHat'
            OsVersion = '7'
            SkipRule  = @('V-204623', 'V-204399.a', 'V-204399.b', 'V-204400', 'V-204403')
        },
        @{
            NodeName  = 'CentOS77'
            STIGType  = 'RedHat'
            OsVersion = '7'
            SkipRule  = @('V-204623', 'V-204399.a', 'V-204399.b', 'V-204400', 'V-204403')
        },
        @{
            NodeName  = 'CentOS76'
            STIGType  = 'RedHat'
            OsVersion = '7'
            SkipRule  = @('V-204623', 'V-204399.a', 'V-204399.b', 'V-204400', 'V-204403')
        },
        @{
            NodeName  = 'CentOS75'
            STIGType  = 'RedHat'
            OsVersion = '7'
            SkipRule  = @('V-204623', 'V-204399.a', 'V-204399.b', 'V-204400', 'V-204403')
        },
        @{
            NodeName  = 'CentOS74'
            STIGType  = 'RedHat'
            OsVersion = '7'
            SkipRule  = @('V-204623', 'V-204399.a', 'V-204399.b', 'V-204400', 'V-204403')
        },
        @{
            NodeName  = 'RHEL79'
            STIGType  = 'RedHat'
            OsVersion = '7'
            SkipRule  = @('V-204623', 'V-204399.a', 'V-204399.b', 'V-204400', 'V-204403')
        },
        @{
            NodeName  = 'RHEL78'
            STIGType  = 'RedHat'
            OsVersion = '7'
            SkipRule  = @('V-204623', 'V-204399.a', 'V-204399.b', 'V-204400', 'V-204403')
        },
        @{
            NodeName  = 'RHEL77'
            STIGType  = 'RedHat'
            OsVersion = '7'
            SkipRule  = @('V-204623', 'V-204399.a', 'V-204399.b', 'V-204400', 'V-204403')
        },
        @{
            NodeName  = 'RHEL75'
            STIGType  = 'RedHat'
            OsVersion = '7'
            SkipRule  = @('V-204623', 'V-204399.a', 'V-204399.b', 'V-204400', 'V-204403')
        },
        @{
            NodeName  = 'RHEL74'
            STIGType  = 'RedHat'
            OsVersion = '7'
            SkipRule  = @('V-204623', 'V-204399.a', 'V-204399.b', 'V-204400', 'V-204403')
        },
        @{
            NodeName  = 'RHEL73'
            STIGType  = 'RedHat'
            OsVersion = '7'
            SkipRule  = @('V-204623', 'V-204399.a', 'V-204399.b', 'V-204400', 'V-204403')
        },
        @{
            NodeName  = 'RHEL72'
            STIGType  = 'RedHat'
            OsVersion = '7'
            SkipRule  = @('V-204623', 'V-204399.a', 'V-204399.b', 'V-204400', 'V-204403')
        },
        @{
            NodeName  = 'Ubuntu1804'
            StigType  = 'Ubuntu'
            OsVersion = '18.04'
            SkipRule  = @('V-219159', 'V-219167.a', 'V-219167.b', 'V-219167.c')
        }
    )
}

# this configuraiton generates all configuration data based configurations (linux)
configuration LinuxBaseLine
{
    Import-DscResource -ModuleName nx
    Import-DscResource -ModuleName PowerSTIG

    Node 'localhost'
    {
        nxScript EmptyDsc {
            GetScript  = "#!/bin/bash`necho emptyGet"
            SetScript  = "#!/bin/bash`necho emptySet"
            TestScript = "#!/bin/bash`nexit 0"
        }
    }

    Node $allNodes.Where{$_.STIGType -eq 'Ubuntu'}.NodeName
    {
        Ubuntu Baseline
        {
            OsVersion = $node.OsVersion
            SkipRule  = $node.SkipRule
        }
    }

    Node $allNodes.Where{$_.STIGType -eq 'RedHat'}.NodeName
    {
        RHEL Baseline
        {
            OsVersion = $node.OsVersion
            SkipRule  = $node.SkipRule
        }
    }
}

# configuration parameter splat
$configurationParams = @{
    ConfigurationData = $configurationData
    OutputPath        = Join-Path -Path $PSScriptRoot -ChildPath "artifacts/mofStore"
}

LinuxBaseLine @configurationParams
