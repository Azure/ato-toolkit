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

    #Get OS to determine which config to apply
    $osVersion = (Get-WmiObject Win32_OperatingSystem).Caption

    if ($osversion -match "Server 2019")
    {
        Node localhost
        {
            $localConfigurationManager.invoke()

            WindowsServer BaseLine
            {
                OsVersion    = '2019'
                OsRole       = 'MS'

                Exception   = @{
                    'V-205733' = @{
                        Identity = 'Guests'
                    }
                    'V-205672' = @{
                        Identity = 'Guests'
                    }
                    'V-205673' = @{
                        Identity = 'Guests'
                    }
                    'V-205675' = @{
                        Identity = 'Guests'
                    }
                }

                OrgSettings = @{
                    'V-205909' = @{
                        OptionValue = 'xAdmin'
                    }
                    'V-205910' = @{
                        OptionValue = 'xGuest'
                    }
                }
            }

            if (!$IsOffline) {
                $dodCertificates.invoke()
            }
        }
    }
    elseif ($osversion -match "Server 2016")
    {
        $localConfigurationManager.invoke()

        WindowsServer BaseLine
        {
            OsVersion   = '2016'
            OsRole      = 'MS'

            Exception   = @{
                'V-225019' = @{
                    Identity = 'Guests'
                }
                'V-225016' = @{
                    Identity = 'Guests'
                }
                'V-225018' = @{
                    Identity = 'Guests'
                }
            }

            OrgSettings = @{
                'V-225015' = @{
                    Identity = 'Guests'
                }
                'V-225026' = @{
                    OptionValue = 'xAdmin'
                }
                'V-225027' = @{
                    OptionValue = 'xGuest'
                }
            }
        }

        if (!$IsOffline) {
            $dodCertificates.invoke()
        }
    }
}