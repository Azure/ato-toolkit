param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $BastionShortname,
    [Parameter(Mandatory=$true)] [string] $BastionHostname,
    [Parameter(Mandatory=$true)] [string] $MasterHostname,
    [Parameter(Mandatory=$true)] [string] $DataHostname,
    [Parameter(Mandatory=$true)] [string] $MasterAvailabilitySet,
    [Parameter(Mandatory=$true)] [string] $DataAvailabilitySet,
    [Parameter(Mandatory=$true)] [string] $MasterLoadBalancer,
    [Parameter(Mandatory=$true)] [string] $clusterNsg,
    [Parameter(Mandatory=$true)] [string] $clusterSubnetName,
    [Parameter(Mandatory=$true)] [string] $appGatewaySubnetName,
    [Parameter(Mandatory=$true)] [string] $gatewayNsg,
    [Parameter(Mandatory=$true)] [string] $MarketplacePublisher,
    [Parameter(Mandatory=$true)] [string] $MarketplaceOffer,
    [Parameter(Mandatory=$true)] [string] $MarketplaceSku,
    [Parameter(Mandatory=$true)] [string] $MarketplaceVersion,
    [Parameter(Mandatory=$true)] [string] $VmSize,
    [Parameter(Mandatory=$true)] [string] $VnetName,
    [Parameter(Mandatory=$true)] [string] $VnetRange,
    [Parameter(Mandatory=$true)] [string] $OCPVnetName,
    [Parameter(Mandatory=$true)] [string] $VnetPeeringName,
    [Parameter(Mandatory=$true)] [string] $OCPResourceGroup,
    [Parameter(Mandatory=$true)] [string] $ClusterSubnetRange,
    [Parameter(Mandatory=$true)] [string] $GatewaySubnetRange,
    [Parameter(Mandatory=$true)] [int] $MasterNodes,
    [Parameter(Mandatory=$true)] [int] $DataNodes,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [string] $TenantId,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $StorageAccount,
    [Parameter(Mandatory=$true)] [string] $DiagnosticsStorage,
    [Parameter(Mandatory=$true)] [int] $ElasticDataDiskSize,
    [Parameter(Mandatory=$true)] [string] $ElasticKeyVault
)

Set-LogFile "./deployment-output/deploy-elastic-infra_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters
$proc = "az"

$softDeletedKeyvault = (az keyvault list-deleted --query "[?name == '$ElasticKeyVault'].name" -o tsv)
if ($softDeletedKeyvault)
{
    Log-Information "Found a soft-deleted keyvault, $softDeletedKeyvault.  Purging keyvault"
    $argList = "keyvault purge --name $ElasticKeyVault"
    $retVal = Run-Command -Process $proc -Arguments $argList

    if ($retVal -ne 0)
    {
        Log-Error "There was an error purging the keyvault, $ElasticKeyVault"
        throw
    }
    else 
    {
        Log-Information "Successfully purged the keyvault, $ElasticKeyVault"
    }
}

Log-Information "Create the KeyVault"
$argList = "keyvault create -l `"$AzureLocation`" -n $ElasticKeyVault -g $ResourceGroup --enable-soft-delete true"
$retVal = Run-Command -Process $proc -Arguments $argList

1..2 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            Log-Information "Creating NSG $using:clusterNsg" 
            $argList = "network nsg create " +
                "-g $using:ResourceGroup " +
                "-n $using:clusterNsg "
            
            Set-LogFile -LogFile "./deployment-output/nsg-cluster-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            $retVal = Run-Command -Process $using:proc -Arguments $argList
        }
        2 {
            Log-Information "Creating NSG $using:gatewayNsg" 
            $argList = "network nsg create " +
                "-g $using:ResourceGroup " +
                "-n $using:gatewayNsg "
            
            Set-LogFile -LogFile "./deployment-output/nsg-gateway-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            $retVal = Run-Command -Process $using:proc -Arguments $argList
        }
    }
} -AsJob -ThrottleLimit 5 | Receive-Job -Wait

Log-Information "Configuring NSG rules for $gatewayNsg"
$argList = "network nsg rule create " +
    "-g $ResourceGroup " +
    "--nsg-name $gatewayNsg " +
    "-n allow_health_probes " +
    "--priority 100 " +
    "--destination-port-ranges `"65200-65535`" "

Set-LogFile -LogFile "./deployment-output/nsg-rule-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
$retVal = Run-Command -Process $proc -Arguments $argList

if ($DeploymentType -ne [DeploymentType]::DisconnectedLite)
{
    Log-Information "Creating vnet $vnetName" 
    $argList = "network vnet create " +
        "-n $vnetName " +
        "-g $ResourceGroup " +
        "--address-prefix $VnetRange "
    
    $retVal = Run-Command -Process $proc -Arguments $argList

    Log-Information "Creating subnet $clusterSubnetName" 
    $argList = "network vnet subnet create " +
        "-n $clusterSubnetName " +
        "-g $ResourceGroup " +
        "--vnet-name $vnetName " +
        "--address-prefix $clusterSubnetRange "
    
    $retVal = Run-Command -Process $proc -Arguments $argList

    Log-Information "Creating subnet $appGatewaySubnetName" 
    $argList = "network vnet subnet create " +
        "-n $appGatewaySubnetName " +
        "-g $ResourceGroup " +
        "--vnet-name $vnetName " +
        "--address-prefix $GatewaySubnetRange "

    $retVal = Run-Command -Process $proc -Arguments $argList
}

$bastionNsg = "$($BastionHostname)-NSG"
$publicIpName = "$MasterLoadBalancer-PIP"

1..5 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            Log-Information "Creating master node availability set"
            $argList = "vm availability-set create " +
                "-g $using:ResourceGroup " +
                "-n $using:MasterAvailabilitySet "
            
            Set-LogFile -LogFile "./deployment-output/nsg-av-master-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            $retVal = Run-Command -Process $using:proc -Arguments $ArgList
        }
        2 {
            Log-Information "Creating data node availability set"
            $argList = "vm availability-set create " +
                "-g $using:ResourceGroup " +
                "-n $using:DataAvailabilitySet "
            
            Set-LogFile -LogFile "./deployment-output/nsg-av-data-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            $retVal = Run-Command -Process $using:proc -Arguments $ArgList
        }
        3 {
            Log-Information "Creating Elasticsearch load balancer public IP address"
            $argList = "network public-ip create " +
                "-g $using:ResourceGroup " +
                "-n $using:publicIpName " +
                "--allocation-method Static "
            
            Set-LogFile -LogFile "./deployment-output/nsg-pip-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            $retVal = Run-Command -Process $using:proc -Arguments $ArgList
        }
        4 {
            Log-Information "Create the storage account for elastic"
            $argList = "storage account create " +
                "-l `"$using:AzureLocation`" " +
                "--resource-group $using:ResourceGroup " +
                "-n $using:DiagnosticsStorage " +
                "--sku Standard_LRS"
        
            Set-LogFile -LogFile "./deployment-output/nsg-storage-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            $retVal = Run-Command -Process $using:proc -Arguments $ArgList
        }
        5 {
            Log-Information "Creating NSG $using:bastionNsg" 
            $argList = "network nsg create " +
                "-g $using:ResourceGroup " +
                "-n $using:bastionNsg "
            
            Set-LogFile -LogFile "./deployment-output/nsg-nsg-bastion-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            $retVal = Run-Command -Process $using:proc -Arguments $ArgList
        }
    }
} -AsJob -ThrottleLimit 5 | Receive-Job -Wait

$loadBalancerBackEnd = "loadBalancerBackEnd"

1..5 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            Log-Information "Configuring NSG rule for $using:bastionNsg"
            $argList = "network nsg rule create " +
                "-g $using:ResourceGroup " +
                "--nsg-name $using:bastionNsg " +
                "-n `"ssh`" " +
                "--priority 100 " +
                "--access Allow " +
                "--direction Inbound " +
                "--protocol Tcp " +
                "--destination-address-prefixes * " +
                "--source-address-prefixes * " +
                "--source-port-ranges * " +
                "--destination-port-ranges 22"

            Set-LogFile -LogFile "./deployment-output/nsg-nsg-bastion-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            $retVal = Run-Command -Process $using:proc -Arguments $ArgList
        }
        2 {
            Log-Information "Creating load balancer"
            $argList = "network lb create " +
                "-n $using:MasterLoadBalancer " +
                "-g $using:ResourceGroup " +
                "--location $using:AzureLocation " +
                "--backend-pool-name $using:loadBalancerBackEnd " +
                "--public-ip-address `"$using:PublicIpName`" "

            Set-LogFile -LogFile "./deployment-output/nsg-lb-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            $retVal = Run-Command -Process $using:proc -Arguments $ArgList
        }
    }
} -AsJob -ThrottleLimit 5 | Receive-Job -Wait


Log-Information "Create the storage account for elastic"
$argList = "storage account create " +
    "-l `"$AzureLocation`" " +
    "--resource-group $ResourceGroup " +
    "-n $StorageAccount " +
    "--sku Standard_LRS"

Set-LogFile -LogFile "./deployment-output/nsg-storage-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
$retVal = Run-Command -Process $proc -Arguments $ArgList


$MachineNumberPadded = "1".PadLeft(3,'0')

$BastionVmName = "$Environment-$RegionLocation-$BastionShortname-$($MachineNumberPadded)v"
$BastionOsDiskName = "$Environment-$RegionLocation-$BastionShortname-$($MachineNumberPadded)v-OSDISK"
$BastionNicName = "$Environment-$RegionLocation-$BastionShortname-$($MachineNumberPadded)v-NIC-001"
$PublicIpName = "$Environment-$RegionLocation-$BastionShortname-PIP"
$fullClusterSubnetName = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Network/virtualNetworks/$vnetName/subnets/$clusterSubnetName"

# STOP FOR NOW BECAUSE I DON'T WHAT THE KEY FOR THE OTHER BASTION IS VIA THIS DEPLOYMENT
# Log-Information "Checking if bastion exists"
# $doesBastionExist=( az vm list -o tsv --query "[?name=='$BastionVmName']" )
# if ($doesBastionExist)
# {
#     Log-Information "Bastion already exists, skipping create"
# }
# else
# {
    Log-Information "Creating bastion machine"
    New-DsopVm -ResourceGroup $ResourceGroup `
        -AzureLocation $AzureLocation `
        -VmName $BastionVmName `
        -OsDiskName $BastionOsDiskName `
        -NicName $BastionNicName `
        -DiagnosticsStorage $DiagnosticsStorage `
        -AdminUsername $AdminUsername `
        -SshKey $SshKey `
        -SubnetName $fullClusterSubnetName `
        -NetworkSecurityGroup $bastionNsg `
        -MarketplacePublisher $MarketplacePublisher `
        -MarketplaceOffer $MarketplaceOffer `
        -MarketplaceSku $MarketplaceSku `
        -MarketplaceVersion $MarketplaceVersion `
        -PublicIpName $PublicIpName `
        -VmSize $VmSize `
        -VhdImageName "/subscriptions/$SubscriptionId/resourceGroups/$OCPResourceGroup/providers/Microsoft.Compute/images/RHEL77" `
        -OsImageType "vhd"
# }

Log-Information "Deploying Elasticsearch master nodes"
1..$MasterNodes | ForEach-Object -Parallel {

    $MachineNumberPadded = "$_".PadLeft(3,'0')
    $hostname = "$using:MasterHostname-$($MachineNumberPadded)v"
    $osDiskName = "$hostname-OSDISK"
    $nicName = "$hostname-NIC"
    New-DsopVm -ResourceGroup $using:ResourceGroup `
        -AzureLocation $using:AzureLocation `
        -VmName $hostname `
        -OsDiskName $osDiskName `
        -NicName $nicName `
        -DiagnosticsStorage $using:DiagnosticsStorage `
        -AdminUsername $using:AdminUsername `
        -SshKey $using:SshKey `
        -SubnetName $using:fullClusterSubnetName `
        -NetworkSecurityGroup $using:gatewayNsg `
        -MarketplacePublisher $using:MarketplacePublisher `
        -MarketplaceOffer $using:MarketplaceOffer `
        -MarketplaceSku $using:MarketplaceSku `
        -MarketplaceVersion $using:MarketplaceVersion `
        -VmSize $using:VmSize `
        -LoadBalancerName $using:MasterLoadBalancer `
        -LoadBalancerBackEnd $using:loadBalancerBackEnd `
        -AvailabilitySet $using:MasterAvailabilitySet `
        -VhdImageName "/subscriptions/$SubscriptionId/resourceGroups/$OCPResourceGroup/providers/Microsoft.Compute/images/RHEL77" `
        -OsImageType "vhd"
    # potential workaround for thread locks
    Start-Sleep -Seconds 5

} -AsJob -ThrottleLimit $MasterNodes | Receive-Job -Wait

Log-Information "Deploying Elasticsearch data nodes"
1..$DataNodes | ForEach-Object -Parallel {

    $MachineNumberPadded = "$_".PadLeft(3,'0')
    $hostname = "$using:DataHostname-$($MachineNumberPadded)v"
    $osDiskName = "$hostname-OSDISK"
    $nicName = "$hostname-NIC"
    $dataDiskName = "$hostname-DATA"
    New-DsopVm -ResourceGroup $using:ResourceGroup `
        -AzureLocation $using:AzureLocation `
        -VmName $hostname `
        -OsDiskName $osDiskName `
        -NicName $nicName `
        -DiagnosticsStorage $using:DiagnosticsStorage `
        -AdminUsername $using:AdminUsername `
        -SshKey $using:SshKey `
        -SubnetName $using:fullClusterSubnetName `
        -NetworkSecurityGroup $using:clusterNsg `
        -MarketplacePublisher $using:MarketplacePublisher `
        -MarketplaceOffer $using:MarketplaceOffer `
        -MarketplaceSku $using:MarketplaceSku `
        -MarketplaceVersion $using:MarketplaceVersion `
        -VmSize $using:VmSize `
        -DataDiskSize $using:ElasticDataDiskSize `
        -DataDiskName $dataDiskName `
        -AvailabilitySet $using:DataAvailabilitySet `
        -VhdImageName "/subscriptions/$SubscriptionId/resourceGroups/$OCPResourceGroup/providers/Microsoft.Compute/images/RHEL77" `
        -OsImageType "vhd"
    # potential workaround for thread locks
    Start-Sleep -Seconds 5

} -AsJob -ThrottleLimit $DataNodes | Receive-Job -Wait


Log-Information "Creating vnet peering $VnetPeeringName for $vnetName to $OCPVnetName"
$OCPVnetFqdn = "/subscriptions/$SubscriptionId/resourceGroups/$OCPResourceGroup/providers/Microsoft.Network/VirtualNetworks/$OCPVnetName"
$argList = "network vnet peering create " +
    "-n $VnetPeeringName " +
    "--remote-vnet $OCPVnetFqdn " +
    "-g $ResourceGroup " +
    "--vnet-name $vnetName " +
    "--allow-vnet-access " 

$retVal = Run-Command -Process $proc -Arguments $argList
# https://docs.microsoft.com/en-us/cli/azure/network/vnet/peering?view-azure-cli-latest
# To successfully peer two virtual networks this command must be called twice with the values to --vnet-name and --remove-vnet-name reversed
Log-Information "Creating vnet peering $VnetPeeringName for $OCPVnetName to $vnetName"
$elasticVnetFqdn = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Network/VirtualNetworks/$vnetName"
$argList = "network vnet peering create " +
    "-n $VnetPeeringName " +
    "--remote-vnet $elasticVnetFqdn " +
    "-g $OCPResourceGroup " +
    "--vnet-name $OCPVnetName " +
    "--allow-vnet-access " 

$retVal = Run-Command -Process $proc -Arguments $argList

Log-Information "Elastic infrastructure deployment complete"

Log-ScriptEnd







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUwqHwQW9Yh569mXEssmQI+bOH
# buSgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
# AQsFADAYMRYwFAYDVQQDDA1KZXJlbXlPbGFjaGVhMB4XDTIwMDgzMTIxMTUxMFoX
# DTIxMDgzMTIxMjQ1OVowGDEWMBQGA1UEAwwNSmVyZW15T2xhY2hlYTCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBAJu5Y9YhmKGhwU+/kj7dsj1OvrliwUCe
# kdPsfdTAPh9peuKKF+ye8U3l3UT8luf5nCYlG/eKe5YxI3pBYhfZwy7yKZpsx5Tn
# ST7t38owgktj0W6YYfoDgfR4zwLtRk3taNWiZeyHu/UhszNs4d3L9wl6Ei/otfRt
# jyz1UO40361YWriD43jbnsCLjVpIfiwW2LH1H9cVoCLnbMZ217rpVxDiTlFPBGeW
# Bk2pxPn5Z2Ly1j6q/SlliEOKDXXrPQZz+sSc3L/ZXBl7D2/ua4+xJmDw/XE1GUBA
# Pldde/IHAzmp6lHHgdQLjCaks//cucDeYBzVTD8XZo8T9WIWU6o6I6SRzGKSIHcX
# SoKVy1hjaW14wJHImw/nlnCgDLMcBBpnRFo6UHAAUzpWlcgqCC+johdXVSa62+hP
# bLwgqfm6uty0rJRwkhbm1Qi0w6HOUZiIkBIz/5Q83t9nLhWL+uWndKIe9BiVfl1f
# x0p5Ax5hzWD5PV1rjrXSQLpL9PRLKcEAy7EoXa/5VGGKSAOrUZdey39vL3AOct0w
# i3vh49DTfWXuxxHbiWz2VEIZqNWQu/rIi9uiCvzaFUo19DwSZrv1ac+OOmZsloqB
# yDugGWFmxiQjEFWtGxEqwDXPDsJE/gKEPvUha37YCI6iQTtcwiwJpnPfGWODqUHH
# 0/NuToVp4ci5AgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
# BgEFBQcDAzAdBgNVHQ4EFgQU16Rx2qHCuXNeExsbMFbSE/Io0NYwDQYJKoZIhvcN
# AQELBQADggIBAG+8jfz9QCzSUK5WGIW0gnEK3rN8oxmSax7C6HJfGPMLXHBEWtBt
# ZCeD8XXkTMu8fhvQDseGgxJ4NmRR+s1d8YtnVgtDbEhO/FHSpOPonTvIx13t37Uz
# Tbvq0ZLeB6z55noAOIhXBs9or1pzxio71sDNfYpIB6s41X5/m1UZk8toxcPDqQGL
# Kg3C3xqgg9+2kQ16flYKvZh2UoK5Y0EyEb8rMc+6AFH3GgcP7yoUsUENP9vkLbXm
# 2VRMIzd/Tee7oKQK50K1GxtlWLUUjuAUMCQh+9K/JyAUro9jfMNHCGcPTaayXBvl
# kaCOjb1IrKgtsS/c2p7mgbssdFHHGPBlbggogGFxYof+6SDI2YB8AqT3RYJdJH4c
# 6StsYUka1faCYcZfz+DIm2+avSCKdliOb285WT8yqoh7P2qN6bLt2au0IsfUKR+d
# EgSL3waCmT+xUI6BI6mpnSjgA0/Hr6I/wkxHu/hk0G0q4OdBpXpSzCzurKPdQWB+
# K/PaQSCyEGk4IGqFrHMx863mtW+mlm6jCM/5/b5ugAmF4XoNkVzdmfFhepqq4h0v
# ioKE+1sLxgq2lFtKAZMjpJB7HZ9KVQcb/hSYlgms/mG6P+4GIhf7ZfvlI2LsCdbV
# 42kEAfDVDuHcCqWyJr43vm+vY6xzjDRnNmaqVJgH1sZO0kwajDOKkm/JMYICzTCC
# AskCAQEwLDAYMRYwFAYDVQQDDA1KZXJlbXlPbGFjaGVhAhAVrGjoMQw2rkF3eYcz
# j/kHMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqG
# SIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3
# AgEVMCMGCSqGSIb3DQEJBDEWBBQyXclaQ/fsCQgpJJjwQ8VCCFnhaDANBgkqhkiG
# 9w0BAQEFAASCAgAnl5HxXuy+m1Z0iT+HZ9q4IFhcnohAPM4QoQmFTXuAB3ZJEwiJ
# sxNXXg9+82GRMlkebGrOD+bEaVkMzN8mcO8wTQUbj9xqhzhBcJfvnH2DnEZsO2yJ
# TL6ADy502Kwa/CXyMZFhpSKy2NswcZ68qJFkVVvjVoUDm+lLcyuIJt60lez7iobn
# fnA3UH18pAY4kVPz2EJMNm21asoldakVhuGsX07w6aoq0bgyqcCemXhHaA1M7e21
# 7PDCdzJ4uLk346E5OTPulM7dmOuth2W46Nh4Ux3kfoaA+SGulrH6Rdeb3LIIZdCg
# tGqi1dPq9Ng4E1VeU+saGqTWSy+zYi25oQiYznrwCNCTqm1A3aYAe+JI8nBP0ZnS
# XGnIrP8bJE+Ni6eopxnrbN9sSLAwqMpB9maT9A9Er6qsG6z11bmgmx3ZxKmQHkn4
# wbka2ck9/6veUmAl5/vxMKz0K6IIE7nMBculZcJZ8SNXwcIwdajwf/QToNz13oDj
# h4Z/hhQfNr3gJdyUl2X0eRwQmMp5/FrNloLcxrPBQC4gDiy0J9qRioOdawtVx/uv
# EzRnWrSf0+8bENqWs0tz/p5Pc5/z9a/X+VSP9WbxgNC7kMxwUTV6SPXd2xp01haU
# q/Z6rTtTVFUHVihfTcnowryoOijDImU1aP6Q/ygltVSvulPgcRwTnpTGAg==
# SIG # End signature block
