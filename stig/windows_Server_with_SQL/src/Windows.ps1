configuration Windows
{
    Import-DscResource -ModuleName PowerSTIG -ModuleVersion 4.9.0
    Import-DscResource -ModuleName SecurityPolicyDsc -ModuleVersion 2.10.0.0

    [scriptblock]$localConfigurationManager = {
        LocalConfigurationManager {
            ActionAfterReboot  = 'ContinueConfiguration'
            ConfigurationMode  = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }
    }
    
    [scriptblock]$microsoftEdgeStig = {

        Edge STIG_MicrosoftEdge
        {

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
            Skiprule = @('V-17443', 'V-17442')
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

    [scriptblock]$windowsSqlServer2016InstanceStig = {

        if (Test-Path "HKLM:\Software\Microsoft\Microsoft SQL Server\Instance Names\SQL")
        {
            $hostname = [System.Net.Dns]::GetHostName()

            File AuditFolderCreate
            {
                Type            = 'Directory'
                DestinationPath = 'C:\Audits'
                Ensure          = "Present"
            }

            SqlServer STIG_WindowsSqlServer2016Instance
            {
                SqlVersion     = '2016'
                SqlRole        = 'Instance'
                ServerInstance = $hostname
            }
        }
        else
        {
            break
        }
    }

    [scriptblock]$windowsStig = {

        $osVersion = (Get-WmiObject Win32_OperatingSystem).Caption
        $certificateTest = Get-ChildItem -Path "C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\*\Downloads\0\*.cer"

        if($osVersion -match "Windows 10")
        {
            WindowsClient STIG_WindowsClient
            {
                OsVersion   = '10'
                SkipRule    = @("V-220740","V-220739","V-220741", "V-220908")
                Exception   = @{
                    'V-220972' = @{
                        Identity = 'Guests'
                    }
                    'V-220968' = @{
                        Identity = 'Guests'
                    }
                    'V-220969' = @{
                        Identity = 'Guests'
                    }
                    'V-220971' = @{
                        Identity = 'Guests'
                    }
                }
                OrgSettings =  @{
                    'V-220912' = @{
                        OptionValue = 'xGuest'
                    }
                }
            }
            AccountPolicy BaseLine2
            {
                Name                                = "Windows10fix"
                Account_lockout_threshold           = 3
                Account_lockout_duration            = 15
                Reset_account_lockout_counter_after = 15
            }
            break
        }

        switch -Wildcard ($osVersion) 
        {
            "*2016*" 
            {
                $osVersion = '2016'
                $skipRules = @('V-224866', 'V-224867', 'V-224868')
                $exceptions = @{
                    'V-225019' = @{Identity = 'Guests'}
                    'V-225016' = @{Identity = 'Guests'}
                    'V-225018' = @{Identity = 'Guests'}
                }

                if ($null -eq $certificateTest -or $certificateTest.count -lt 8)
                {
                    $orgSettings = @{
                        'V-225015' = @{Identity     = 'Guests'}
                        'V-225027' = @{OptionValue  = 'xGuest'}
                        'V-225063' = @{ValueData      = '2'}
                    }
                }
                else
                {
                    $orgSettings = @{
                        'V-225015'   = @{Identity       = 'Guests'}
                        'V-225027'   = @{OptionValue    = 'xGuest'}
                        'V-225063'   = @{ValueData      = '2'}
                        'V-225021.a' = @{Location = ($certificateTest | Where-Object FullName -match "8C941B34EA1EA6ED9AE2BC54CF687252B4C9B561.cer").FullName}
                        'V-225021.b' = @{Location = ($certificateTest | Where-Object FullName -match "D73CA91102A2204A36459ED32213B467D7CE97FB.cer").FullName}
                        'V-225021.c' = @{Location = ($certificateTest | Where-Object FullName -match "B8269F25DBD937ECAFD4C35A9838571723F2D026.cer").FullName}
                        'V-225021.d' = @{Location = ($certificateTest | Where-Object FullName -match "4ECB5CC3095670454DA1CBD410FC921F46B8564B.cer").FullName}
                        'V-225022.a' = @{Location = ($certificateTest | Where-Object FullName -match "AC06108CA348CC03B53795C64BF84403C1DBD341.cer").FullName}
                        'V-225022.b' = @{Location = ($certificateTest | Where-Object FullName -match "A8C27332CCB4CA49554CE55D34062A7DD2850C02.cer").FullName}
                        'V-225023'   = @{Location = ($certificateTest | Where-Object FullName -match "AF132AC65DE86FC4FB3FE51FD637EBA0FF0B12A9.cer").FullName}
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
            "*2019*" 
            {
                $osVersion = '2019'
                $exceptions = @{
                    'V-205733' = @{Identity = 'Guests'}
                    'V-205672' = @{Identity = 'Guests'}
                    'V-205673' = @{Identity = 'Guests'}
                    'V-205675' = @{Identity = 'Guests'}
                }

                if ($null -eq $certificateTest -or $certificateTest.count -lt 8)
                {
                    $orgSettings = @{
                        'V-205910' = @{OptionValue = 'xGuest'}
                        'V-205717' = @{ValueData   = '2'}
                    }
                }
                else
                {
                    $orgSettings = @{
                        'V-205910'   = @{OptionValue = 'xGuest'}
                        'V-205717'   = @{ValueData   = '2'}
                        'V-205648.a' = @{Location = ($certificateTest | Where-Object FullName -match "8C941B34EA1EA6ED9AE2BC54CF687252B4C9B561.cer").FullName}
                        'V-205648.b' = @{Location = ($certificateTest | Where-Object FullName -match "D73CA91102A2204A36459ED32213B467D7CE97FB.cer").FullName}
                        'V-205648.c' = @{Location = ($certificateTest | Where-Object FullName -match "B8269F25DBD937ECAFD4C35A9838571723F2D026.cer").FullName}
                        'V-205648.d' = @{Location = ($certificateTest | Where-Object FullName -match "4ECB5CC3095670454DA1CBD410FC921F46B8564B.cer").FullName}
                        'V-205649.a' = @{Location = ($certificateTest | Where-Object FullName -match "AC06108CA348CC03B53795C64BF84403C1DBD341.cer").FullName}
                        'V-205649.b' = @{Location = ($certificateTest | Where-Object FullName -match "A8C27332CCB4CA49554CE55D34062A7DD2850C02.cer").FullName}
                        'V-205650.a' = @{Location = ($certificateTest | Where-Object FullName -match "AF132AC65DE86FC4FB3FE51FD637EBA0FF0B12A9.cer").FullName}
                        'V-205650.b' = @{Location = ($certificateTest | Where-Object FullName -match "929BF3196896994C0A201DF4A5B71F603FEFBF2E.cer").FullName}
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
        $windowsStig.invoke()
        $ie11Stig.invoke()
        $dotnetFrameworkStig.invoke()
        $windowsDefenderStig.invoke()
        $windowsFirewallStig.invoke()
        $microsoftEdgeStig.invoke()
        $windowsSqlServer2016InstanceStig.invoke()
    }
}