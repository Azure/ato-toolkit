param (
    # Mandatory Parameters
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $Environment,
    [Parameter(Mandatory=$true)] [string] $RegionLocation,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [string] $DiagnosticsStorage,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$true)] [string] $SubnetName,
    [Parameter(Mandatory=$true)] [int] $DataDiskSize,
    [Parameter(Mandatory=$true)] [string] $MachineTypeShortname,
    [Parameter(Mandatory=$true)] [string] $NetworkSecurityGroup,
    [Parameter(Mandatory=$true)] [string] $MarketplacePublisher,
    [Parameter(Mandatory=$true)] [string] $MarketplaceOffer,
    [Parameter(Mandatory=$true)] [string] $MarketplaceSku,
    [Parameter(Mandatory=$true)] [string] $MarketplaceVersion,
    [Parameter(Mandatory=$true)] [string] $VmSize,
    [Parameter(Mandatory=$true)] [int] $InstanceCount,
    [Parameter(Mandatory=$true)] [string] $OsImageType,
    [Parameter(Mandatory=$true)] [string] $VhdImageName,
    #Optional Parameters
    [Parameter(Mandatory=$false)] [string] $LoadBalancerName,
    [Parameter(Mandatory=$false)] [string] $LoadBalancerBackEnd,
    [Parameter(Mandatory=$false)] [string] $AvailabilitySet,
    [Parameter(Mandatory=$false)] [int] $CnsGlusterDiskSize = 0,
    [Parameter(Mandatory=$false)] [string] $PublicIpName
)

1..$InstanceCount | ForEach-Object -Parallel {
    ./do-vm-creation.ps1 -ResourceGroup $using:ResourceGroup `
        -Environment $using:Environment `
        -RegionLocation $using:RegionLocation `
        -AzureLocation $using:AzureLocation `
        -DiagnosticsStorage $using:DiagnosticsStorage `
        -AdminUsername $using:AdminUsername `
        -SshKey $using:SshKey `
        -SubnetName $using:SubnetName `
        -MachineNumber $_ `
        -DataDiskSize $using:DataDiskSize `
        -MachineTypeShortname $using:MachineTypeShortname `
        -NetworkSecurityGroup $using:NetworkSecurityGroup `
        -MarketplacePublisher $using:MarketplacePublisher `
        -MarketplaceOffer $using:MarketplaceOffer `
        -MarketplaceSku $using:MarketplaceSku `
        -MarketplaceVersion $using:MarketplaceVersion `
        -LoadBalancerName $using:LoadBalancerName `
        -LoadBalancerBackEnd $using:LoadBalancerBackEnd `
        -AvailabilitySet $using:AvailabilitySet `
        -CnsGlusterDiskSize $using:CnsGlusterDiskSize `
        -PublicIpName $using:PublicIpName `
        -VmSize $using:VmSize `
        -OsImageType $using:OsImageType `
        -VhdImageName $using:VhdImageName `
        -LogFile "./deployment-output/vm-creation-$($using:MachineTypeShortname)_$($_)_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
    # potential workaround for thread locks
    Start-Sleep -Seconds 5
} -AsJob -ThrottleLimit 10 | Receive-Job -Wait
