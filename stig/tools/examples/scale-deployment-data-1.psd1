@{
    # Datafile structure is single key/value pair, where the "value" is an array of hashtables decribing each VM deployment.
    AllNodes =
    @(
        @{
            # Windows Deployment Example w/AvailabilitySet
            ResourceGroupName             = 'atoTesting' # Resource Group name
            adminUsername                 = 'testuser' # Admin user account name for VM
            virtualNetworkNewOrExisting   = 'new' # vNet 'new' or 'existing'
            vmVirtualNetwork              = 'ato-vm-vnet' # vNet name, creates new if not does exist
            subnetName                    = 'subnet1' # Subnet name within specified vNet
            diagnosticStorageResourceId   = '' # Diagnostic Storage Resource Id (Get-AzStorageAccount -ResourceGroupName <ResourceGroupName> -Name <diagStorageAcctName>).Id
            logAnalyticsWorkspaceId       = '' # Log Analytic Workspace Id (Get-AzOperationalInsightsWorkspace -ResourceGroupName <ResourceGroupName> -Name <WorkspaceName>).ResourceId
            osDiskEncryptionSetResourceId = '' # Disk Encryption Set Resource Id (Get-AzDiskEncryptionSet -ResourceGroupName <ResourceGroupName> -Name <DiskEncryptionSetName>).Id
            OsVersion                     = '2019-Datacenter' # OS Version, i.e.: '2019-Datacenter', '2016-Datacenter', '19h2-ent'
            VmName                        = 'win2019' # Virtual Machine Name, this will be the base name used in conjunction with VmNamePrefix, VmNameSuffixDelimiter and VmNameSuffixStartingNumber
            VmNamePrefix                  = 'ato-' # VM Name prefix, i.e.: 'ato-'
            VmNameSuffixDelimiter         = '-' # Delimiter used in conjunction with VmName and Suffix Starting Number, i.e.: '-'
            VmNameSuffixStartingNumber    = 1 # VM Name Suffix Starting number, used to create unique VM Name, i.e.: 1
            Count                         = 1 # Number of unque VMs or VM Availability Sets to deploy, i.e.: 2
            InstanceCount                 = 2 # Number of VMs to deploy per Availability Set (valid range 1-5), i.e.: 2
            FaultDomains                  = 2 # Fault domains (valid range 1-3), i.e.: 2
            UpdateDomains                 = 3 # Update domains (valid range 1-5), i.e.: 3
            AvailabilityOptions           = 'availabilitySet' # if 'availabilitySet' is specified, AvailabilitySet is created. 'default' no AvailabilitySet is created
            AvailabilitySetNameSuffix     = '-as' # AvailabilitySetName Suffix to be used with scaled deployment, i.e.: '-as'
            TimeInSecondsBetweenJobs      = 30 # Specify, in seconds, how long to wait before executing the next deployment. This is useful when creating a new vNet with the first deployment, min/default value is 10
        },
        @{
            # Windows Deployment Example w/o AvailabilitySet
            ResourceGroupName             = 'atoTesting' # Resource Group name
            adminUsername                 = 'testuser' # Admin user account name for VM
            virtualNetworkNewOrExisting   = 'existing' # vNet 'new' or 'existing'
            vmVirtualNetwork              = 'ato-vm-vnet' # vNet name, creates new if not does exist
            subnetName                    = 'subnet1' # Subnet name within specified vNet
            diagnosticStorageResourceId   = '' # Diagnostic Storage Resource Id (Get-AzStorageAccount -ResourceGroupName <ResourceGroupName> -Name <diagStorageAcctName>).Id
            logAnalyticsWorkspaceId       = '' # Log Analytic Workspace Id (Get-AzOperationalInsightsWorkspace -ResourceGroupName <ResourceGroupName> -Name <WorkspaceName>).ResourceId
            osDiskEncryptionSetResourceId = '' # Disk Encryption Set Resource Id (Get-AzDiskEncryptionSet -ResourceGroupName <ResourceGroupName> -Name <DiskEncryptionSetName>).Id
            OsVersion                     = '2016-Datacenter' # OS Version, i.e.: '2019-Datacenter', '2016-Datacenter', '19h2-ent'
            VmName                        = 'win2016' # Virtual Machine Name, this will be the base name used in conjunction with VmNamePrefix, VmNameSuffixDelimiter and VmNameSuffixStartingNumber
            VmNamePrefix                  = 'ato-' # VM Name prefix, i.e.: 'ato-'
            VmNameSuffixDelimiter         = '-' # Delimiter used in conjunction with VmName and Suffix Starting Number, i.e.: '-'
            VmNameSuffixStartingNumber    = 1 # VM Name Suffix Starting number, used to create unique VM Name, i.e.: 1
            Count                         = 1 # Number of unque VMs or VM Availability Sets to deploy, i.e.: 2
        },
        @{
            # Linux Deployment Example w/AvailabilitySet
            ResourceGroupName             = 'atoTesting' # Resource Group name
            adminUsername                 = 'testuser' # Admin user account name for VM
            virtualNetworkNewOrExisting   = 'existing' # vNet 'new' or 'existing'
            vmVirtualNetwork              = 'ato-vm-vnet' # vNet name, creates new if not does exist
            subnetName                    = 'subnet1' # Subnet name within specified vNet
            authenticationType            = 'password' # Type of authentication to use on the Virtual Machine (valid values 'sshPublicKey' and 'password')
            diagnosticStorageResourceId   = '' # Diagnostic Storage Resource Id (Get-AzStorageAccount -ResourceGroupName <ResourceGroupName> -Name <diagStorageAcctName>).Id
            logAnalyticsWorkspaceId       = '' # Log Analytic Workspace Id (Get-AzOperationalInsightsWorkspace -ResourceGroupName <ResourceGroupName> -Name <WorkspaceName>).ResourceId
            osDiskEncryptionSetResourceId = '' # Disk Encryption Set Resource Id (Get-AzDiskEncryptionSet -ResourceGroupName <ResourceGroupName> -Name <DiskEncryptionSetName>).Id
            OsVersion                     = 'RHEL79' # OS Verison, i.e.: 'CentOS79', 'RHEL79', 'Ubuntu1804'
            VmName                        = 'redhat' # Virtual Machine Name, this will be the base name used in conjunction with VmNamePrefix, VmNameSuffixDelimiter and VmNameSuffixStartingNumber
            VmNamePrefix                  = 'ato-' # VM Name prefix, i.e.: 'ato-'
            VmNameSuffixDelimiter         = '-' # Delimiter used in conjunction with VmName and Suffix Starting Number, i.e.: '-'
            VmNameSuffixStartingNumber    = 1 # VM Name Suffix Starting number, used to create unique VM Name, i.e.: 1
            Count                         = 1 # Number of unque VMs or VM Availability Sets to deploy, i.e.: 2
            InstanceCount                 = 2 # Number of VMs to deploy per Availability Set (valid range 1-5), i.e.: 2
            FaultDomains                  = 2 # Fault domains (valid range 1-3), i.e.: 2
            UpdateDomains                 = 3 # Update domains (valid range 1-5), i.e.: 3
            AvailabilityOptions           = 'availabilitySet' # if 'availabilitySet' is specified, AvailabilitySet is created. 'default' no AvailabilitySet is created
            AvailabilitySetNameSuffix     = '-as' # AvailabilitySetName Suffix to be used with scaled deployment, i.e.: '-as'
        },
        @{
            # Linux Deployment Example w/o AvailabilitySet
            ResourceGroupName             = 'atoTesting' # Resource Group name
            adminUsername                 = 'testuser' # Admin user account name for VM
            virtualNetworkNewOrExisting   = 'existing' # vNet 'new' or 'existing'
            vmVirtualNetwork              = 'ato-vm-vnet' # vNet name, creates new if not does exist
            subnetName                    = 'subnet1' # Subnet name within specified vNet
            authenticationType            = 'password' # Type of authentication to use on the Virtual Machine (valid values 'sshPublicKey' and 'password')
            diagnosticStorageResourceId   = '' # Diagnostic Storage Resource Id (Get-AzStorageAccount -ResourceGroupName <ResourceGroupName> -Name <diagStorageAcctName>).Id
            logAnalyticsWorkspaceId       = '' # Log Analytic Workspace Id (Get-AzOperationalInsightsWorkspace -ResourceGroupName <ResourceGroupName> -Name <WorkspaceName>).ResourceId
            osDiskEncryptionSetResourceId = '' # Disk Encryption Set Resource Id (Get-AzDiskEncryptionSet -ResourceGroupName <ResourceGroupName> -Name <DiskEncryptionSetName>).Id
            OsVersion                     = 'CentOS79' # OS Verison, i.e.: 'CentOS79', 'RHEL79', 'Ubuntu1804'
            VmName                        = 'centos' # Virtual Machine Name, this will be the base name used in conjunction with VmNamePrefix, VmNameSuffixDelimiter and VmNameSuffixStartingNumber
            VmNamePrefix                  = 'ato-' # VM Name prefix, i.e.: 'ato-'
            VmNameSuffixDelimiter         = '-' # Delimiter used in conjunction with VmName and Suffix Starting Number, i.e.: '-'
            VmNameSuffixStartingNumber    = 1 # VM Name Suffix Starting number, used to create unique VM Name, i.e.: 1
            Count                         = 1 # Number of unque VMs or VM Availability Sets to deploy, i.e.: 2
        }
    )
}