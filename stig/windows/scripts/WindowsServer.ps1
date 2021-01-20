configuration WindowsServer
{
    param
    (
        [Parameter(Mandatory=$false)]
        [String]$IsOffline = $false
    )

    Import-DscResource -ModuleName PowerSTIG -ModuleVersion 4.7.0
    Import-DscResource -Module cChoco -ModuleVersion 2.4.0.0
    Import-DscResource -ModuleName PSDscResources -ModuleVersion 2.12.0.0
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 9.1.0

    [scriptblock]$localConfigurationManager = {
        LocalConfigurationManager
        {
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }
    }

    [scriptblock]$dodCertificates = {
        # The InstallRoot software is installed and run to enforce SRG-OS-000066-GPOS-00034 and the
        # following STIG rules: V-93487, V-93489, V-93491
        cChocoInstaller InstallChoco
        {
            InstallDir = "c:\choco"
        }

        cChocoFeature EnableChocoFips
        {
            FeatureName = "useFipsCompliantChecksums"
            DependsOn   = "[cChocoInstaller]InstallChoco"
        }

        cChocoPackageInstaller InstallDoDInstallRoot
        {
            Name        = "installroot"
            Version     = "5.5"
            DependsOn   = "[cChocoFeature]EnableChocoFips"
        }

        Script InstallDoDCerts
        {
            GetScript   = {
                return @{}
            }
            SetScript   = {
                . "C:\Program Files\DoD-PKE\InstallRoot\installroot.exe" --insert
            }
            TestScript  = {
                # The test always returns false, which is not a good DSC resource
                # design, but in ZTA this configuration is pushed once so it
                # matters less.
                return $false
            }
            DependsOn   = "[cChocoPackageInstaller]InstallDoDInstallRoot"
        }

        # The Federal Bridge Certification Authority (FBCA) Cross-Certificate Remover Tool is
        # installed and run to enforce SRG-OS-000066-GPOS-00034 and the
        # following STIG rules: V-93491
        $fbcaCrossCertRemoverZipFilename = "unclass-fbca_crosscert_remover_v118.zip"
        $fbcaCrossCertRemoverZipLocalPath = "C:\$fbcaCrossCertRemoverZipFilename"
        $fbcaCrossCertRemoverLocalFolder = "C:\fbca_crosscert_remover"
        xRemoteFile DownloadFbcaCrossCertRemover
        {
            DestinationPath = $fbcaCrossCertRemoverZipLocalPath
            Uri             = "https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/$fbcaCrossCertRemoverZipFilename"
        }

        Archive UnzipFbcaCrossCertRemover {
            Ensure      = "Present"
            Path        = $fbcaCrossCertRemoverZipLocalPath
            Destination = $fbcaCrossCertRemoverLocalFolder
            DependsOn   = "[xRemoteFile]DownloadFbcaCrossCertRemover"
        }

        Script RunFbcaCrossCertRemover
        {
            GetScript   = {
                return @{}
            }
            SetScript   = {
                . "$($using:fbcaCrossCertRemoverLocalFolder)\FBCA_crosscert_remover.exe" /SILENT
            }
            TestScript  = {
                # The test always returns false, which is not a good DSC resource
                # design, but in ZTA this configuration is pushed once so it
                # matters less.
                return $false
            }
            DependsOn   = "[Archive]UnzipFbcaCrossCertRemover"
        }
    }

    [scriptblock]$ie11Stig = {

        InternetExplorer STIG_IE11
        {
            BrowserVersion  = '11'
            SkipRule        = 'V-46477'
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
            OrgSettings = @{
                'V-17425'   = @{ValueData = '16384'}
                'V-17425.b' = @{ValueData = '16384'}
                'V-17435'   = @{ValueData = '16384'}
                'V-17435.b' = @{ValueData = '16384'}
                'V-17445'   = @{ValueData = '16384'}
                'V-17445.b' = @{ValueData = '16384'}
            }
        }
    }

    [scriptblock]$windowsDefenderStig = {

        WindowsDefender STIG_WindowsDefender
        {
            OrgSettings = @{
                'V-213450' = @{ValueData = '1'}
                'V-213452' = @{ValueData = '1'}
                'V-213453' = @{ValueData = '1'}
                'V-213455' = @{ValueData = '2'}
                'V-213464' = @{ValueData = '2'}
                'V-213465' = @{ValueData = '2'}
                'V-213466' = @{ValueData = '2'}
            }
        }
    }

    [scriptblock]$windowsServerStig = {

        $osVersion              = (Get-WmiObject Win32_OperatingSystem).Caption
        $domainControllerCheck  = (Get-WindowsFeature -Name AD-Domain-Services) -eq 'Installed'
       
        switch ($domainControllerCheck)
        {
            $true   {$osRole = 'DC'}
            default {$osRole = 'MS'}
        }

        switch -Wildcard ($osVersion)
        {
            "*2016*"
            {
                $osVersion      = '2016'
                $exceptions   = @{
                    'V-225019'  = @{Identity = 'Guests' }
                    'V-225016'  = @{Identity = 'Guests'}
                    'V-225018'  = @{Identity = 'Guests'}
                }
                $orgSettings = @{
                    'V-225015'  = @{Identity    = 'Guests'}
                    'V-225026'  = @{OptionValue = 'xAdmin'}
                    'V-225027'  = @{OptionValue = 'Guests'}
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
                $orgSettings = @{
                    'V-205909' = @{OptionValue = 'xAdmin'}
                    'V-205910' = @{OptionValue = 'xGuest'}
                }
                break
            }
        }

        WindowsServer STIG_WindowsServer
        {
            OsVersion   = $osVersion
            OsRole      = $osRole
            Exception   = $exceptions
            OrgSettings = $orgSettings
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
