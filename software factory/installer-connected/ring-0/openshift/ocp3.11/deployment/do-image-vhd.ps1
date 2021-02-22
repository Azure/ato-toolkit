param (
    [Parameter(Mandatory=$true)] [string] $OsImageType,
    [Parameter(Mandatory=$true)] [string] $UploadVhd,
    [Parameter(Mandatory=$true)] [string] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [string] $TenantId,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [string] $SetupStorage,
    [Parameter(Mandatory=$true)] [string] $SetupBlobContainer,
    [Parameter(Mandatory=$true)] [string] $VhdDiskName,
    [Parameter(Mandatory=$true)] [string] $VhdImageName
)

if ($OsImageType.ToLower() -eq "vhd")
{
    if ($UploadVhd)
    {
        Log-Information "Upload the vhd for vm image"
        ./do-deployment-vhd-upload.ps1 -DeploymentType $DeploymentType `
            -SubscriptionId $SubscriptionId `
            -TenantId $TenantId `
            -ResourceGroup $ResourceGroup `
            -AzureLocation $AzureLocation `
            -StorageAccount $SetupStorage `
            -Container $SetupBlobContainer `
            -VhdName $VhdDiskName `
            -VhdPath "/vhd-base/"
    }

    Log-Information "Get endpoint to use for the image"
    $StorageEndpoint=( az storage account show -n $SetupStorage --query primaryEndpoints.blob -o tsv )
    Log-Information "$StorageEndpoint"

    Log-Information "Create the image for VMs"
    $argList = "image create " +
        "--resource-group $ResourceGroup " +
        "--location $AzureLocation " +
        "--name $VhdImageName " +
        "--os-type linux " +
        "--source $StorageEndpoint$SetupBlobContainer/$VhdDiskName " +
        "--os-disk-caching ReadWrite " +
        "-o table"
    $retVal = Run-Command -Process "az" -Arguments $argList
}
