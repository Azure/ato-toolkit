param (
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [int] $DataDiskSize,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $DiagnosticsStorage,
    [Parameter(Mandatory=$true)] [string] $Environment,
    [Parameter(Mandatory=$true)] [string] $MarketplaceOffer,
    [Parameter(Mandatory=$true)] [string] $MarketplacePublisher,
    [Parameter(Mandatory=$true)] [string] $MarketplaceSku,
    [Parameter(Mandatory=$true)] [string] $MarketplaceVersion,
    [Parameter(Mandatory=$true)] [string] $RegionLocation,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$true)] [string] $MasterInfraSubnetReference,
    [Parameter(Mandatory=$true)] [string] $OsImageType,
    [Parameter(Mandatory=$true)] [string] $VhdImageName,
    [Parameter(Mandatory=$true)] [int] $MasterInstanceCount,
    [Parameter(Mandatory=$true)] [int] $InfraInstanceCount,
    [Parameter(Mandatory=$true)] [int] $NodeInstanceCount,
    [Parameter(Mandatory=$true)] [int] $CnsInstanceCount,
    [Parameter(Mandatory=$true)] [string] $ClusterType,
    [Parameter(Mandatory=$true)] [string] $MasterVmSize,
    [Parameter(Mandatory=$true)] [string] $InfraVmSize,
    [Parameter(Mandatory=$true)] [string] $NodeVmSize,
    [Parameter(Mandatory=$true)] [string] $CnsVmSize,
    [Parameter(Mandatory=$true)] [string] $BastionShortname,
    [Parameter(Mandatory=$true)] [string] $MasterShortname,
    [Parameter(Mandatory=$true)] [string] $NodeShortname,
    [Parameter(Mandatory=$true)] [string] $InfraShortname,
    [Parameter(Mandatory=$true)] [string] $CnsShortname,
    [Parameter(Mandatory=$true)] [bool] $EnableCns,
    [Parameter(Mandatory=$true)] [int] $CnsGlusterDiskSize
)

$AllParams = @{}
$AllParams.AdminUsername = $AdminUsername
$AllParams.AzureLocation = $AzureLocation
$AllParams.DataDiskSize = $DataDiskSize
$AllParams.ResourceGroup = $ResourceGroup
$AllParams.DiagnosticsStorage = $DiagnosticsStorage
$AllParams.Environment = $Environment
$AllParams.MarketplaceOffer = $MarketplaceOffer
$AllParams.MarketplacePublisher = $MarketplacePublisher
$AllParams.MarketplaceSku = $MarketplaceSku
$AllParams.MarketplaceVersion = $MarketplaceVersion
$AllParams.RegionLocation = $RegionLocation
$AllParams.SshKey = $SshKey
$AllParams.SubnetName = $MasterInfraSubnetReference
$AllParams.OsImageType = $OsImageType
$AllParams.VhdImageName = $VhdImageName

$Job = 1..5 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            if ($using:ClusterType -eq "public")
            {
                $PublicIpName = "$using:Environment-$using:RegionLocation-$using:BastionShortName-PIP"
            }
            # Bastion
            ./do-vm-creation-shim.ps1 @using:AllParams `
                -InstanceCount 1 `
                -MachineTypeShortname $using:BastionShortname `
                -VmSize $using:NodeVmSize `
                -PublicIpName $PublicIpName `
                -NetworkSecurityGroup "$using:Environment-$using:RegionLocation-$using:BastionShortName-NSG"
        }
        2 {
            # Master
            ./do-vm-creation-shim.ps1 @using:AllParams `
                -MachineTypeShortname $using:MasterShortname `
                -InstanceCount $using:MasterInstanceCount `
                -LoadBalancerName "$using:Environment-$using:RegionLocation-$using:MasterShortname-LB" `
                -LoadBalancerBackEnd "loadBalancerBackEnd" `
                -VmSize $using:MasterVmSize `
                -AvailabilitySet "$using:Environment-$using:RegionLocation-$using:MasterShortname-AS01" `
                -NetworkSecurityGroup "$using:Environment-$using:RegionLocation-$using:MasterShortname-NSG"
        }
        3 {
            # Infra
            ./do-vm-creation-shim.ps1 @using:AllParams `
                -MachineTypeShortname $using:InfraShortname `
                -InstanceCount $using:InfraInstanceCount `
                -LoadBalancerName "$using:Environment-$using:RegionLocation-$using:InfraShortname-LB" `
                -LoadBalancerBackEnd "loadBalancerBackEnd" `
                -VmSize $using:InfraVmSize `
                -AvailabilitySet "$using:Environment-$using:RegionLocation-$using:InfraShortname-AS01" `
                -NetworkSecurityGroup "$using:Environment-$using:RegionLocation-$using:InfraShortname-NSG"
        }
        4 {
            # Node
            ./do-vm-creation-shim.ps1 @using:AllParams `
                -MachineTypeShortname $using:NodeShortname `
                -InstanceCount $using:NodeInstanceCount `
                -VmSize $using:NodeVmSize `
                -AvailabilitySet "$using:Environment-$using:RegionLocation-$using:NodeShortname-AS01" `
                -NetworkSecurityGroup "$using:Environment-$using:RegionLocation-$using:NodeShortname-NSG"
        }
        5 {
            # CNS
            if ($using:EnableCns)
            {
                ./do-vm-creation-shim.ps1 @using:AllParams `
                    -MachineTypeShortname $using:CnsShortname `
                    -InstanceCount $using:CnsInstanceCount `
                    -CnsGlusterDiskSize $using:CnsGlusterDiskSize `
                    -VmSize $using:CnsVmSize `
                    -AvailabilitySet "$using:Environment-$using:RegionLocation-$using:CnsShortname-AS01" `
                    -NetworkSecurityGroup "$using:Environment-$using:RegionLocation-$using:CnsShortname-NSG"
            }
        }
    }

    # potential workaround for thread locks
    Start-Sleep -Seconds 5
} -AsJob -ThrottleLimit 5
$Job | Receive-Job -Wait

