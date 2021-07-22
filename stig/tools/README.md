# Azure STIG Templates for (Linux & Windows) Scale Deployment

Based on community feedback, **Scale Deployment** scripts have been created for the ATO Toolkit. The scripts included in the tools directory can be used to scaled VM deployment with the included ARM Templates and associated artifacts. Scale deployment can be enabled by supplying the required data via script parameters or a specially crafted PowerShell data file.

## Prerequisites

To use the scale deployment scripts included with the ATO Toolkit, the following requirements must be met.

* Azure Subscription in a supported region
  * AzureCloud
  * AzureUSGovernment
  * AzureGermanCloud
* Existing Azure Resource Group
* Existing Azure Storage Account
* Windows PowerShell v5 or PowerShell v7
* Azure PowerShell Modules
  * Az v5.9.0 or greater
  * Az.Resources v3.5.0 or greater, ***which will be included with the Az module install***

## Included Components

* **publish-to-blob.ps1:** This script can be used to upload the included template json files and supporting automation artifacts to a specified Azure Storage Account.
* **scale-deployment.ps1:** This script is used to create STIG VM deployments based on the included mainTemplate.json files for Linux and Windows.
* **kick-start-scaled-deployment.ps1:** This script couples both the publish-to-blob and scale-deployment scripts to copy the needed artifacts and invoke a scaled VM deployment.

## Data file structure

While the scale-deployment.ps1 can be used for single VM deployments, it can also be used at scale by specifying all VM deployment data in a single PowerShell data file. When the scale-deployment.ps1 script is invoked with **DataFilePath** parameter, the script will import the data file and loop through each deployment (hash table) in the array. The data file structure requires a key/value pair (hash table). There can be only one key defined with its associated value an array of hash tables. Each hash table defines a single deployment using parameters from **scale-deployment.ps1**.

### Data file example

```PowerShell
@{
    # Data file structure is single key/value pair, where the "value" is an array of hash tables describing each VM deployment.
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
            Count                         = 1 # Number of unique VMs or VM Availability Sets to deploy, i.e.: 2
            InstanceCount                 = 2 # Number of VMs to deploy per Availability Set (valid range 1-5), i.e.: 2
            FaultDomains                  = 2 # Fault domains (valid range 1-3), i.e.: 2
            UpdateDomains                 = 3 # Update domains (valid range 1-5), i.e.: 3
            AvailabilityOptions           = 'availabilitySet' # if 'availabilitySet' is specified, AvailabilitySet is created. 'default' no AvailabilitySet is created
            AvailabilitySetNameSuffix     = '-as' # AvailabilitySetName Suffix to be used with scaled deployment, i.e.: '-as'
            TimeInSecondsBetweenJobs      = 30 # Specify, in seconds, how long to wait before executing the next deployment. This is useful when creating a new vNet with the first deployment, min/default value is 10
        },
        @{
            # Additional deployments can follow, given scale-deployment.ps1 parameters within this hash table and following hash tables.
        }
    )
}
```

## Examples

Copy ATO Toolkit STIG Solution Templates to an Azure Storage Account using publish-to-blob.ps1 and display Azure portal Deployment Uris.

```PowerShell
$publishBlobParams = @{
    ResourceGroupName  = 'atotoolkit'
    StorageAccountName = 'atotoolkitscale'
    ContainerName      = 'artifacts'
    Environment        = 'AzureUSGovernment'
}
.\publish-to-blob.ps1 @publishBlobParams
```

The screenshot below displays the results of the above code example. The links generated can be copied/pasted into a browser to step through an Azure portal deployment. ![publishtoblobexample](https://raw.githubusercontent.com/wiki/azure/ato-toolkit/images/publishtoblobsmall.png)

Copy ATO Toolkit STIG Solution Templates to an Azure Storage Account and invoke a scale deployment with deployments from a PowerShell Data File.

```PowerShell
$kickStartParams = @{
    ResourceGroupName  = 'atotoolkit'
    StorageAccountName = 'atotoolkitscale'
    ContainerName      = 'artifacts'
    DataFilePath       = '.\examples\scale-deployment-data-1.psd1'
    Verbose            = $true
}
.\kick-start-scaled-deployment.ps1 @kickStartParams
```
