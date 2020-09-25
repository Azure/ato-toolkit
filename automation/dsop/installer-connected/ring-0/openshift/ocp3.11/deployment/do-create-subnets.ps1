param (
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string] $ResourceGroup,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string] $AddressPrefixes,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string] $VirtualNetworkName,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string] $MasterInfraSubnetName,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string] $MasterInfraSubnetPrefix,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string] $NodeSubnetName,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string] $NodeSubnetPrefix
)

Log-Parameters -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$proc = "az"

# if (($ResourceGroup -ne "contest-sharedsvcs-rg") -or ($VirtualNetworkName -ne "contest-sharedsvcs-vnet"))
# {
#     Log-Information "Create resource group for deployment: $ResourceGroup"
#     $retVal = Run-Command -Process $proc -Arguments "group create -l `"$AzureLocation`" -n $ResourceGroup -o table"

#     Log-Information "Create Virtual Network"
#     $argList = "network vnet create --resource-group $ResourceGroup " +
#                 "--name $VirtualNetworkName " +
#                 "--address-prefix $AddressPrefixes " +
#                 "-o table"
#     $retVal = Run-Command -Process $proc -Arguments $argList
# }

Log-Information "Creating Master Infra Subnet"
$argList = "network vnet subnet create --address-prefix $MasterInfraSubnetPrefix " +
            "--resource-group $ResourceGroup " +
            "--name $MasterInfraSubnetName " +
            "--vnet-name $VirtualNetworkName " +
            "-o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Information "Creating Node Infra Subnet"
$argList = "network vnet subnet create --address-prefix $NodeSubnetPrefix " +
            "--resource-group $ResourceGroup " +
            "--name $NodeSubnetName " +
            "--vnet-name $VirtualNetworkName " +
            "-o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Footer -ScriptName $MyInvocation.MyCommand
