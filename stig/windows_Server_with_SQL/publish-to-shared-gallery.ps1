<#
    .SYNOPSIS
        This script is designed to take a snapshot of an existing VM and deploy the specialized image to a shared gallery.

    .DESCRIPTION
        This script is designed to take a snapshot of an existing VM and deploy the specialized image to a shared gallery.

    .PARAMETER ResourceGroupName
        Specifies the Resource group to deploy all resources in this script.

    .PARAMETER VmName
        Specifies the name of the host Virtual machine to snapshot.

    .PARAMETER GalleryName
        Specifies the name of the shared gallery

    .PARAMETER RegionSelection
        Specifies the region of the shared gallery .

    .PARAMETER ImageVersion
        Specifies the version of the image in format 1.0.0 (Major.Minor.Hotfix).

    .PARAMETER OsType
        Specifies the version operating system (Windows or Linux).

    .PARAMETER Publisher
        Specifies a custom Publisher name for the Gallery Image.

    .PARAMETER Offer
        Specifies a custom Offer name for the Gallery Image.

    .PARAMETER Sku
        Specifies a custom Sku name for the Gallery Image.

    .NOTES
        This script is included to assist  with the deployment of an image to be shared in your organization
    .EXAMPLE
        .\publish-to-shared-gallery.ps1 -ResourceGroupName "TestRG" -VmName "TestVM" -GalleryName "TestGallery" -RegionSelection "USGov Virginia" -ImageVersion "1.0.0" -osType "Windows"
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
    $GalleryName,

    [Parameter(Mandatory = $true)]
    [string]
    $RegionSelection,

    [Parameter(Mandatory = $true)]
    [string]
    $ImageVersion,

    [Parameter(Mandatory = $true)]
    [string]
    $OsType,

    [Parameter(Mandatory = $false)]
    [string]
    $Publisher = 'TestPublisher',

    [Parameter(Mandatory = $false)]
    [string]
    $Offer = 'testOffer',

    [Parameter(Mandatory = $false)]
    [string]
    $Sku = 'Test_SKU'
)

$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName
if ($null -eq $vm)
{
    Write-Host "VM not found in Resource Group"
    break
}

$currentRegions = (Get-AzLocation).DisplayName
if ($currentRegions -notcontains $RegionSelection)
{
    Write-Host "Region Not Valid please chose from the following :"
    Write-Host $currentRegions
    break
}

# Create Shared Image Gallery
$gallery = New-AzGallery -GalleryName $GalleryName -ResourceGroupName $ResourceGroupName -Location $vm.Location -Description 'Shared Image Gallery for my organization'

# Get OS Disk
$disk = Get-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $vm.StorageProfile.OsDisk.Name

# Generate Snapshot Configuraiton
Write-Host "Creating Snapshot Configuration..."
$snapshotConfig = New-AzSnapshotConfig -SourceUri $Disk.Id -CreateOption Copy -Location $vm.Location

# Create Snapshot
Write-Host "Creating VM Snapshot..."
$snapshotName = '{0}_{1}' -f $vm.Name, (Get-Date -Format "MM_dd_yyyy_HH_mm")
$null = New-AzSnapshot -Snapshot $snapshotConfig -SnapshotName $snapshotName -ResourceGroupName $ResourceGroupName

# Get Snapshot
$snapshot = Get-AzSnapshot -ResourceGroup $ResourceGroupName -SnapshotName $snapshotName

# Create the Image Configuration
Write-Host "Creating Image Configuration..."
$imageConfig = New-AzImageConfig -Location $vm.location
$imageConfig = Set-AzImageOsDisk -Image $imageConfig -OsState Specialized -OsType $OsType -SnapshotId $snapshot.Id -StorageAccountType Premium_LRS

# Create Image Definition
Write-Host "Creating Image Definition..."
$newAzGalleryImageDefParams = @{
    ResourceGroupName = $ResourceGroupName
    GalleryName       = $gallery.Name
    Name              = $snapShotName
    Location          = $vm.Location
    Publisher         = $Publisher
    Offer             = $Offer
    Sku               = $Sku
    OsState           = 'Specialized'
    OsType            = $OsType
    Description       = "Image Created from $snapShotName"
}
$null = New-AzGalleryImageDefinition @newAzGalleryImageDefParams

# Create Image Version
Write-Host "Creating Image Version, this may take several minutes..."
$targetRegions = @(
    @{
        Name         = $RegionSelection
        ReplicaCount = 1
    }
)

$osDiskImage = @{
    HostCaching = "ReadOnly"
    Source      = @{
        Id = $snapshot.Id
    }
}

$newAzGalleryImageVerParams = @{
    ResourceGroupName          = $ResourceGroupName
    GalleryName                = $gallery.Name
    GalleryImageDefinitionName = $snapShotName
    Name                       = $ImageVersion
    Location                   = $vm.Location
    TargetRegion               = $targetRegions
    OSDiskImage                = $osDiskImage
}
$null = New-AzGalleryImageVersion @newAzGalleryImageVerParams

# Remove Snapshot
Write-Host "Removing VM Snapshot..."
$null = $snapshot | Remove-AzSnapshot -Force
