param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [string] $StorageAccount,
    [Parameter(Mandatory=$true)] [string] $Container,
    [Parameter(Mandatory=$true)] [string] $VhdName,
    [Parameter(Mandatory=$true)] [string] $VmName,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$true)] [string] $VirtualNetworkResourceGroup,
    [Parameter(Mandatory=$true)] [string] $VirtualNetworkName,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [string] $MasterInfraSubnetName
)

Log-Parameters -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$proc = "az"

[string] $SshKeyPath = "./certs/$SshKey"
Log-Information "Verifying the ssh key $SshKeyPath exists"
if (-not (Test-Path $SshKeyPath))
{
    Log-Error "The ssh key was not found ($SshKeyPath)"
    throw
}

Log-Information "Create resource group for upload: $ResourceGroup"
$retVal = Run-Command -Process $proc -Arguments "group create -l `"$AzureLocation`" -n $ResourceGroup -o table"

Log-Information "Get endpoint to use for the image"
$StorageEndpoint=( az storage account show -n $StorageAccount --query primaryEndpoints.blob -o tsv )
Log-Information "$StorageEndpoint"

Log-Information "Create the image"
$argList = "image create " +
    "--resource-group $ResourceGroup " +
    "--location `"$AzureLocation`" " +
    "--name $VmName " +
    "--os-type linux " +
    "--source $StorageEndpoint$Container/$VhdName " +
    "--os-disk-caching ReadWrite " +
    "-o table"
$retVal = Run-Command -Process $proc -Arguments $argList

$PublicIpAddress = '""'
$AuthType = "ssh"
if ($DeploymentType -eq [DeploymentType]::DisconnectedLite)
{
    Log-Information "Create the VM with emulated subnet"
    $argList = "vm create " +
        "-g $ResourceGroup " +
        "-n $VmName " +
        "--location `"$AzureLocation`" " +
        "--image $VmName " +
        "--admin-username $AdminUsername " +
        "--public-ip-address $PublicIpAddress " +
        "--authentication-type $AuthType " +
        "--subnet `"/subscriptions/$SubscriptionId/resourceGroups/$VirtualNetworkResourceGroup/providers/Microsoft.Network/virtualNetworks/$VirtualNetworkName/subnets/Combine-Private-C`" " +
        "--generate-ssh-keys " +
        "-o table"
    $retVal = Run-Command -Process $proc -Arguments $argList
}
elseif(($DeploymentType -eq [DeploymentType]::DisconnectedStack) -or ($DeploymentType -eq [DeploymentType]::Disconnected))
{
    Log-Information "Create the VM with emulated subnet"
    $argList = "vm create " +
        "-g $ResourceGroup " +
        "-n $VmName " +
        "--location `"$AzureLocation`" " +
        "--image $VmName " +
        "--admin-username $AdminUsername " +
        "--public-ip-address $PublicIpAddress " +
        "--authentication-type $AuthType " +
        "--subnet `"/subscriptions/$SubscriptionId/resourceGroups/$VirtualNetworkResourceGroup/providers/Microsoft.Network/virtualNetworks/$VirtualNetworkName/subnets/$MasterInfraSubnetName`" " +
        "--generate-ssh-keys " +
        "-o table"
    $retVal = Run-Command -Process $proc -Arguments $argList
}

Log-Information "Set the vm ssh key user"
$argList = "vm user update " +
    "--resource-group $ResourceGroup " +
    "--name $VmName " +
    "--username $AdminUsername " +
    "--ssh-key-value $SshKeyPath " +
    "-o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Footer -ScriptName $MyInvocation.MyCommand
