# Publish to Shared Gallery Instructions

The following script was created to enable the usage of the STIG templates on an existing VM. This script should not be used in a production environment. 

#Notes
The script is dependent on first running publish-to-blob.ps1, to ensure all of the template files are available for automation.


```Powershell

<#
    .SYNOPSIS
        This script is designed deploy a the STIG configuration to an existing Server 2016 or Server 2019 instance.

    .DESCRIPTION
        This script is designed to apply the folling STIG configurations to Server 2019 or Server 2016

        WindowsServerStig (2016\2019)
        Internet Explorer 11
        DotnetFramework
        WindowsDefender
        WindowsFirewall

    .PARAMETER ResourceGroupName
        Specifies the Resource group to deploy all resources in this script.

    .PARAMETER VmName
        Specifies the name of the host Virtual machine to snapshot.

    .PARAMETER StorageAccountName
        Specifies the name the storage account created with "publish-to-blob.ps1"

    .PARAMETER ContainerName
        Specifies the name the container name created with "publish-to-blob.ps1"

    .NOTES
        This script is meant for use in a development environment
        This script is included to assist applying STIG to a single Server 2016 or Server 2019 VM
        *****You must run publish-to-blob.ps1 to move the essential files to blob storage*****

    .EXAMPLE
        .\push-to-existing-vm.ps1 -ResourceGroupName "TestRG" -VmName "TestVM" -StorageAccountName "Windows"
#>
[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]
    $VmName,

    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountName,

    [Parameter(Mandatory = $true)]
    [string]
    $ContainerName
)

# Custom script extension files
$requiredModulesFile = "RequiredModules.ps1"
$installPSModulesFile = "InstallModules.ps1"
$generateStigChecklist = "GenerateStigChecklist.ps1"

# Get VM details
$vm = Get-AzVM -Name $vmName
if($null -eq $vm)
{
    Write-Host "Invalid VM name"
    Break
}

# Get storage account details
$context = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName).Context
if($null -eq $vm)
{
    Write-Host "Invalid storage account name, please run publish-to-blob.ps1 to ensure dependencies are in cloud storage"
    Break
}

# Generate SAS tokens and Urls for files
$sasToken = New-AzStorageContainerSASToken -Context $context -Name $containerName -Permission rwdl
if($null -eq $vm)
{
    Write-Host "Invalid container name, please run publish-to-blob.ps1 to ensure dependencies are in cloud storage"
    Break
}
$requiredModulesFileUrl = (Get-AzStorageBlob -Context $context -Container $containerName -Blob $requiredModulesFile).ICloudBlob.Uri.AbsoluteUri + $sasToken
$installPSModulesFileUrl = (Get-AzStorageBlob -Context $context -Container $containerName -Blob $installPSModulesFile).ICloudBlob.Uri.AbsoluteUri + $sasToken
$generateStigChecklistUrl = (Get-AzStorageBlob -Context $context -Container $containerName -Blob $generateStigChecklist).ICloudBlob.Uri.AbsoluteUri + $sasToken

# CustomScript Extension install modules
$fileUriGroup = @($requiredModulesFileUrl,$installPSModulesFileUrl,$generateStigChecklistUrl)
Set-AzVMCustomScriptExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Name "install-powershell-modules" -FileUri $fileUriGroup -Run "$installPSModulesFile -autoInstallDependencies $true" -Location $vm.Location

# DSC extension Apply configuration
Set-AzVMDscExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -ArchiveBlobName "WindowsServer.ps1.zip" -ArchiveStorageAccountName $storageAccountName -ArchiveContainerName $containerName -ConfigurationName "WindowsServer" -Version "2.77" -Location $vm.Location
```