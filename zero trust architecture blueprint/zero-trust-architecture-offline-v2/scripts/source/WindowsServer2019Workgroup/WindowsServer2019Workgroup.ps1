configuration WindowsServer2019Workgroup
{
    param 
   ( 
        [Parameter(Mandatory=$false)]
        [String]$IsOffline = $false
    ) 

    Import-DscResource -ModuleName PowerSTIG -ModuleVersion 4.3.0
	Import-DscResource -ModuleName SecurityPolicyDsc -ModuleVersion 2.4.0.0
    Import-DscResource -Module cChoco -ModuleVersion 2.4.0.0
    Import-DscResource -ModuleName PSDscResources -ModuleVersion 2.10.0.0
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 9.1.0

    Node localhost
    {
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'            
            RebootNodeIfNeeded = $true            
        }

        WindowsServer BaseLine
        {
            OsVersion    = '2019'
            OsRole       = 'MS'
            StigVersion  = '1.2'
            DomainName   = 'WORKGROUP'
            ForestName   = 'WORKGROUP'
             
            SkipRule     = @(
                # The underlying resource [WindowsDefenderDsc]ProcessMitigation throws an error
                # when running Set-ProcessMitigation. This is a bug. For more info:
                # https://github.com/MicrosoftDocs/windows-itpro-docs/issues/2179
                # Skipping this rule does not affect the outcome of the vunerability scan. 
                "V-93335", 
                
                # Some rules fail to apply to WORKGROUP systems.
                # As a workaround, we ask PowerSTIG to skip them and 
                # enforce them ourselves in the following resources.
                "V-92965",
                "V-93009",
                "V-93011",
                "V-93015"
            )
        }

        UserRightsAssignment "V-92965_DenyGuestRemoteLogin"
        {
            Policy   = "Deny_log_on_through_Remote_Desktop_Services"
            Identity = @("Guests")
            Ensure   = "Present"
        }

        UserRightsAssignment "V-93009_DenyGuestNetworkAccess"
        {
            Policy   = "Deny_access_to_this_computer_from_the_network"
            Identity = @("Guests")
            Ensure   = "Present"
        }

        UserRightsAssignment "V-93011_DenyGuestLogonAsBatch"
        {
            Policy   = "Deny_log_on_as_a_batch_job"
            Identity = @("Guests")
            Ensure   = "Present"
        }

        UserRightsAssignment "V-93015_DenyGuestLogonLocally"
        {
            Policy   = "Deny_log_on_locally"
            Identity = @("Guests")
            Ensure   = "Present"
        }

        if(!$IsOffline) {
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
    }
}