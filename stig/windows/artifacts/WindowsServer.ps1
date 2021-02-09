configuration WindowsServer
{
    Import-DscResource -ModuleName PowerSTIG -ModuleVersion 4.7.1
    Import-DscResource -ModuleName SecurityPolicyDsc -ModuleVersion 2.10.0.0

    [scriptblock]$localConfigurationManager = {
        LocalConfigurationManager {
            ActionAfterReboot  = 'ContinueConfiguration'
            ConfigurationMode  = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }
    }

    [scriptblock]$ie11Stig = {

        InternetExplorer STIG_IE11
        {
            BrowserVersion = '11'
            SkipRule       = 'V-46477'
        }
    }

    [scriptblock]$dotnetFrameworkStig = {

        DotNetFramework STIG_DotnetFramework
        {
            FrameworkVersion = '4'
        }
    }

    [scriptblock]$windowsFirewallStig = {

        WindowsFirewall STIG_WindowsFirewall
        {
            Skiprule = @('V-17438.a','V-17438.b')
        }
    }

    [scriptblock]$windowsDefenderStig = {

        WindowsDefender STIG_WindowsDefender
        {
            OrgSettings = @{
                'V-213450' = @{ValueData = '1' }
            }
        }
    }

    [scriptblock]$windowsServerStig = {

        $osVersion = (Get-WmiObject Win32_OperatingSystem).Caption
        $certificateTest = Get-ChildItem -Path "C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\*\Downloads\0\*.cer"

        switch -Wildcard ($osVersion) {
            "*2016*" {
                $osVersion = '2016'
                $SkipRules = @('V-224866', 'V-224867', 'V-224868')
                $exceptions = @{
                    'V-225019' = @{Identity = 'Guests'}
                    'V-225016' = @{Identity = 'Guests'}
                    'V-225018' = @{Identity = 'Guests'}
                }

                if ($null -eq $certificateTest -or $certificateTest.count -lt 8)
                {
                    $orgSettings     = @{
                        'V-225015'   = @{Identity    = 'Guests'}
                        'V-225026'   = @{OptionValue = 'xAdmin'}
                        'V-225027'   = @{OptionValue = 'xGuest'}
                    }
                }
                else
                {
                    $orgSettings     = @{
                        'V-225015'   = @{Identity    = 'Guests'}
                        'V-225026'   = @{OptionValue = 'xAdmin'}
                        'V-225027'   = @{OptionValue = 'xGuest'}
                        'V-225021.a' = @{Location = ($certificateTest | where-object FullName -match "8C941B34EA1EA6ED9AE2BC54CF687252B4C9B561.cer").FullName}
                        'V-225021.b' = @{Location = ($certificateTest | where-object FullName -match "D73CA91102A2204A36459ED32213B467D7CE97FB.cer").FullName}
                        'V-225021.c' = @{Location = ($certificateTest | where-object FullName -match "B8269F25DBD937ECAFD4C35A9838571723F2D026.cer").FullName}
                        'V-225021.d' = @{Location = ($certificateTest | where-object FullName -match "4ECB5CC3095670454DA1CBD410FC921F46B8564B.cer").FullName}
                        'V-225022.a' = @{Location = ($certificateTest | where-object FullName -match "AC06108CA348CC03B53795C64BF84403C1DBD341.cer").FullName}
                        'V-225022.b' = @{Location = ($certificateTest | where-object FullName -match "A8C27332CCB4CA49554CE55D34062A7DD2850C02.cer").FullName}
                        'V-225023'   = @{Location = ($certificateTest | where-object FullName -match "AF132AC65DE86FC4FB3FE51FD637EBA0FF0B12A9.cer").FullName}
                    }
                }

                WindowsServer STIG_WindowsServer
                {
                    OsVersion   = $osVersion
                    OsRole      = 'MS'
                    Exception   = $exceptions
                    OrgSettings = $orgSettings
                    SkipRule    = $skipRules
                }

                AccountPolicy BaseLine2
                {
                    Name                                = "2016fix"
                    Account_lockout_threshold           = 3
                    Account_lockout_duration            = 15
                    Reset_account_lockout_counter_after = 15
                }
                break
            }
            "*2019*" {
                $osVersion = '2019'
                $exceptions = @{
                    'V-205733' = @{Identity = 'Guests' }
                    'V-205672' = @{Identity = 'Guests' }
                    'V-205673' = @{Identity = 'Guests' }
                    'V-205675' = @{Identity = 'Guests' }
                }

                if ($null -eq $certificateTest -or $certificateTest.count -lt 8)
                {
                    $orgSettings   = @{
                        'V-205909' = @{OptionValue = 'xAdmin'}
                        'V-205910' = @{OptionValue = 'xGuest'}
                    }
                }
                else
                {
                    $orgSettings   = @{
                        'V-205909' = @{OptionValue = 'xAdmin'}
                        'V-205910' = @{OptionValue = 'xGuest'}
                        'V-205648.a' = @{Location = ($certificateTest | where-object FullName -match "8C941B34EA1EA6ED9AE2BC54CF687252B4C9B561.cer").FullName}
                        'V-205648.b' = @{Location = ($certificateTest | where-object FullName -match "D73CA91102A2204A36459ED32213B467D7CE97FB.cer").FullName}
                        'V-205648.c' = @{Location = ($certificateTest | where-object FullName -match "B8269F25DBD937ECAFD4C35A9838571723F2D026.cer").FullName}
                        'V-205648.d' = @{Location = ($certificateTest | where-object FullName -match "4ECB5CC3095670454DA1CBD410FC921F46B8564B.cer").FullName}
                        'V-205649.a' = @{Location = ($certificateTest | where-object FullName -match "AC06108CA348CC03B53795C64BF84403C1DBD341.cer").FullName}
                        'V-205649.b' = @{Location = ($certificateTest | where-object FullName -match "A8C27332CCB4CA49554CE55D34062A7DD2850C02.cer").FullName}
                        'V-205650.a' = @{Location = ($certificateTest | where-object FullName -match "AF132AC65DE86FC4FB3FE51FD637EBA0FF0B12A9.cer").FullName}
                        'V-205650.b' = @{Location = ($certificateTest | where-object FullName -match "929BF3196896994C0A201DF4A5B71F603FEFBF2E.cer").FullName}
                    }
                }

                WindowsServer STIG_WindowsServer
                {
                    OsVersion   = $osVersion
                    OsRole      = 'MS'
                    Exception   = $exceptions
                    OrgSettings = $orgSettings
                }
                break
            }
        }
    }

    Node localhost
    {
        $localConfigurationManager.invoke()
        $windowsServerStig.invoke()
        $ie11Stig.invoke()
        $dotnetFrameworkStig.invoke()
        $windowsDefenderStig.invoke()
        $windowsFirewallStig.invoke()
    }
}