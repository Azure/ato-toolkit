param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [string] $TenantId,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [string] $StorageAccount,
    [Parameter(Mandatory=$true)] [string] $Container,
    [Parameter(Mandatory=$true)] [string] $VhdName,
    [string] $VhdPath = "/repo/"
)

Log-Parameters -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$proc = "az"

$VhdPath = "$($(Get-Location).Path)$VhdPath"

Log-Information "Renaming VHD Image"
Move-Item "$($VhdPath)bravo*.vhd" -Destination "$($VhdPath)/$($VhdName)"

./do-confirm-login.ps1 -TenantId $TenantId `
    -SubscriptionId $SubscriptionId `
    -DeploymentType $DeploymentType

Log-Information "Create resource group for upload: $ResourceGroup"
$retVal = Run-Command -Process $proc -Arguments "group create -l `"$AzureLocation`" -n $ResourceGroup -o table"

Log-Information "Creating the storage account"
$retVal = Run-Command -Process $proc -Arguments "storage account create -l `"$AzureLocation`" --resource-group $ResourceGroup -n $StorageAccount --sku Standard_LRS -o table"

Log-Information "Creating the container in the account"
$retVal = Run-Command -Process $proc -Arguments "storage container create --account-name $StorageAccount -n $Container -o table"

if ($DeploymentType -eq [DeploymentType]::DisconnectedStack)
{
    Log-Information "Running in $DeploymentType, need to set an environment variable for the copy to work"
    $env:AZCOPY_DEFAULT_SERVICE_API_VERSION="2017-11-09" #2019-06-01
}

Log-Information "Acquiring the endpoint for copy"
$StorageEndpoint=( az storage account show -n $StorageAccount --query primaryEndpoints.blob -o tsv )
Log-Information "$StorageEndpoint"

Log-Information "Pushing the VHD file into Blob"
$retVal = Run-Command -Process $proc -Arguments "storage copy -s $VhdPath$VHDname -d $StorageEndpoint$Container --recursive --blob-type=PageBlob"

Log-Footer -ScriptName $MyInvocation.MyCommand
