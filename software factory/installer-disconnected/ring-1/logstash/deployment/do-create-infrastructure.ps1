param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $BastionShortname,
    [Parameter(Mandatory=$true)] [string] $BastionHostname,
    [Parameter(Mandatory=$true)] [string] $LogstashHostname,
    [Parameter(Mandatory=$true)] [string] $LogstashAvailabilitySet,
    [Parameter(Mandatory=$true)] [string] $LogstashLoadBalancer,
    [Parameter(Mandatory=$true)] [string] $LogstashPorts,
    [Parameter(Mandatory=$true)] [string] $clusterNsg,
    [Parameter(Mandatory=$true)] [string] $clusterSubnetName,
    [Parameter(Mandatory=$true)] [string] $MarketplacePublisher,
    [Parameter(Mandatory=$true)] [string] $MarketplaceOffer,
    [Parameter(Mandatory=$true)] [string] $MarketplaceSku,
    [Parameter(Mandatory=$true)] [string] $MarketplaceVersion,
    [Parameter(Mandatory=$true)] [string] $VmSize,
    [Parameter(Mandatory=$true)] [string] $VnetName,
    [Parameter(Mandatory=$true)] [string] $VnetRange,
    [Parameter(Mandatory=$true)] [string] $OCPResourceGroup,
    [Parameter(Mandatory=$true)] [string] $ClusterSubnetRange,
    [Parameter(Mandatory=$true)] [string] $VnetPeeringName,
    [Parameter(Mandatory=$true)] [string] $ElasticVnetName,
    [Parameter(Mandatory=$true)] [string] $ElasticResourceGroup,
    [Parameter(Mandatory=$true)] [int] $Nodes,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $TenantId,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $StorageAccount,
    [Parameter(Mandatory=$true)] [string] $DiagnosticsStorage
)

Set-LogFile "./deployment-output/create_infra_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$bastionNsg = "$($BastionHostname)-NSG"
$publicIpName = "$LogstashLoadBalancer-PIP"
$loadBalancerBackEnd = "loadBalancerBackEnd"
$proc = "az"

1..5 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            Set-LogFile -LogFile "./deployment-output/nsg-cluster-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            
            Log-Information "Creating NSG $using:clusterNsg" 
            $argList = "network nsg create " +
                "-g $using:ResourceGroup " +
                "-n $using:clusterNsg "
            
            $retVal = Run-Command -Process $using:proc -Arguments $argList
        }
        2 {
            Set-LogFile -LogFile "./deployment-output/nsg-bastion-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            
            Log-Information "Creating NSG $using:bastionNsg" 
            $argList = "network nsg create " +
                "-g $using:ResourceGroup " +
                "-n $using:bastionNsg "
            
            $retVal = Run-Command -Process $using:proc -Arguments $argList
        }
        3 {
            Set-LogFile -LogFile "./deployment-output/availability-set-logstash-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            
            Log-Information "Creating node availability set"
            $argList = "vm availability-set create " +
                "-g $using:ResourceGroup " +
                "-n $using:LogstashAvailabilitySet "
            
            $retVal = Run-Command -Process $using:proc -Arguments $argList
        }
        4 {
            Set-LogFile -LogFile "./deployment-output/diagnostics-account-storage-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            
            Log-Information "Create the storage account"
            $argList = "storage account create -l `"$using:AzureLocation`" " +
                "--resource-group $using:ResourceGroup " +
                "-n $using:DiagnosticsStorage " +
                "--sku Standard_LRS"
        
            $retVal = Run-Command -Process $using:proc -Arguments $argList
        }
        5 {
            Set-LogFile -LogFile "./deployment-output/storage-account-storage-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            
            Log-Information "Create the storage account"
            $argList = "storage account create " +
                "-g $using:ResourceGroup " +
                "--location `"$using:AzureLocation`" " +
                "-n $using:StorageAccount " +
                "--sku Standard_LRS"

            $retVal = Run-Command -Process $using:proc -Arguments $argList
        }
    }
} -AsJob -ThrottleLimit 5 | Receive-Job -Wait

if ($DeploymentType -ne [DeploymentType]::DisconnectedLite)
{
    Log-Information "Creating vnet $vnetName" 
    $argList = "network vnet create " +
        "-n $vnetName " +
        "-g $ResourceGroup " +
        "--address-prefix $VnetRange "
    
    $retVal = Run-Command -Process $proc -Arguments $argList

    1..2 | ForEach-Object -Parallel {
        switch ($_) {
            1 {
                Set-LogFile -LogFile "./deployment-output/public-ip-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
                
                Log-Information "Creating load balancer public IP address"
                $argList = "network public-ip create " +
                    "-g $using:ResourceGroup " +
                    "-n $using:publicIpName " +
                    "--allocation-method Static"
            
                $retVal = Run-Command -Process $using:proc -Arguments $argList
            }
            2 {
                Log-Information "Creating subnet $using:clusterSubnetName" 
                $argList = "network vnet subnet create " +
                    "-n $using:clusterSubnetName " +
                    "-g $using:ResourceGroup " +
                    "--vnet-name $using:vnetName " +
                    "--address-prefix $using:clusterSubnetRange "
                
                $retVal = Run-Command -Process $using:proc -Arguments $argList
            }
        }
    }


}

1..3 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            Set-LogFile -LogFile "./deployment-output/nsg-rule-cluster-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            
            Log-Information "Configuring NSG rules for $using:clusterNsg"
            $argList = "network nsg rule create " +
                "-g $using:ResourceGroup " +
                "--nsg-name $using:clusterNsg " +
                "-n allow_health_probes " +
                "--priority 100 " +
                "--destination-port-ranges `"65200-65535`" "
        
            $retVal = Run-Command -Process $using:proc -Arguments $argList
        }
        2 {
            Set-LogFile -LogFile "./deployment-output/nsg-rule-bastion-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"        
            
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

            $retVal = Run-Command -Process $using:proc -Arguments $argList
        }
        3 {
            Set-LogFile -LogFile "./deployment-output/lb-create-$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"        
            
            Log-Information "Creating load balancer"
            $argList = "network lb create -n $using:LogstashLoadBalancer " +
                "-g $using:ResourceGroup " +
                "--location `"$using:AzureLocation`" " +
                "--backend-pool-name $using:loadBalancerBackEnd " +
                "--public-ip-address `"$using:PublicIpName`" "

            $retVal = Run-Command -Process $using:proc -Arguments $argList
        }
    }
} -AsJob -ThrottleLimit 5 | Receive-Job -Wait

$loadBalancerFrontEnd = "LoadBalancerFrontEnd"
ForEach ($port in $LogstashPorts.Split(",")) {
    $argList = "network lb rule create " +
        "--resource-group $ResourceGroup " +
        "--lb-name $LogstashLoadBalancer " +
        "--name $port " +
        "--protocol tcp " +
        "--frontend-port $port " +
        "--backend-port $port " +
        "--frontend-ip-name $loadBalancerFrontEnd " +
        "--backend-pool-name $loadBalancerBackEnd"
    $retVal = Run-Command -Process $proc -Arguments $argList
}


$image = "$($MarketplacePublisher):$($MarketplaceOffer):$($MarketplaceSku):$($MarketplaceVersion)"

$MachineNumberPadded = "1".PadLeft(3,'0')

$BastionVmName = "$BastionHostname-$($MachineNumberPadded)v"
$BastionOsDiskName = "$BastionHostname-$($MachineNumberPadded)v-OSDISK"
$BastionNicName = "$BastionHostname-$($MachineNumberPadded)v-NIC-001"
$BastionPublicIpName = "$BastionHostname-PIP"

Log-Information "Creating bastion machine"
# check if it exists before doing this
New-DsopVm -ResourceGroup $ResourceGroup `
    -AzureLocation $AzureLocation `
    -VmName $BastionVmName `
    -OsDiskName $BastionOsDiskName `
    -NicName $BastionNicName `
    -DiagnosticsStorage $DiagnosticsStorage `
    -AdminUsername $AdminUsername `
    -SshKey $SshKey `
    -SubnetName $clusterSubnetName `
    -VnetName $VnetName `
    -NetworkSecurityGroup $bastionNsg `
    -MarketplacePublisher $MarketplacePublisher `
    -MarketplaceOffer $MarketplaceOffer `
    -MarketplaceSku $MarketplaceSku `
    -MarketplaceVersion $MarketplaceVersion `
    -PublicIpName $BastionPublicIpName `
    -VmSize $VmSize `
    -VhdImageName "/subscriptions/$SubscriptionId/resourceGroups/$OCPResourceGroup/providers/Microsoft.Compute/images/RHEL77" `
    -OsImageType "vhd"

Log-Information "Deploying Logstash nodes"
1..$Nodes | ForEach-Object -Parallel {

    $MachineNumberPadded = "$_".PadLeft(3,'0')
    $hostname = "$using:LogstashHostname-$($MachineNumberPadded)v"
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
        -SubnetName $using:clusterSubnetName `
        -VnetName $using:VnetName `
        -NetworkSecurityGroup $using:clusterNsg `
        -MarketplacePublisher $using:MarketplacePublisher `
        -MarketplaceOffer $using:MarketplaceOffer `
        -MarketplaceSku $using:MarketplaceSku `
        -MarketplaceVersion $using:MarketplaceVersion `
        -VmSize $using:VmSize `
        -AvailabilitySet $using:LogstashAvailabilitySet `
        -VhdImageName "/subscriptions/$SubscriptionId/resourceGroups/$OCPResourceGroup/providers/Microsoft.Compute/images/RHEL77" `
        -OsImageType "vhd"
    # potential workaround for thread locks
    Start-Sleep -Seconds 5

} -AsJob -ThrottleLimit $Nodes | Receive-Job -Wait

    Log-Information "Creating vnet peering $vnetPeeringName for $vnetName to $ElasticVnetName"
    $elasticVnetFqdn = "/subscriptions/$SubscriptionId/resourceGroups/$ElasticResourceGroup/providers/Microsoft.Network/VirtualNetworks/$ElasticVnetName"
    $argList = "network vnet peering create " +
        "-n $vnetPeeringName " +
        "--remote-vnet $elasticVnetFqdn " +
        "-g $ResourceGroup " +
        "--vnet-name $vnetName " +
        "--allow-vnet-access " 
    
    $retVal = Run-Command -Process $proc -Arguments $argList

    # https://docs.microsoft.com/en-us/cli/azure/network/vnet/peering?view-azure-cli-latest
    # To successfully peer two virtual networks this command must be called twice with the values to --vnet-name and --remove-vnet-name reversed
    Log-Information "Creating vnet peering $vnetPeeringName for $ElasticVnetName to $vnetName"
    $logstashVnetFqdn = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Network/VirtualNetworks/$vnetName"
    $argList = "network vnet peering create " +
        "-n $vnetPeeringName " +
        "--remote-vnet $logstashVnetFqdn " +
        "-g $ElasticResourceGroup " +
        "--vnet-name $ElasticVnetName " +
        "--allow-vnet-access " 
    
    $retVal = Run-Command -Process $proc -Arguments $argList

Log-Information "Logstash infrastructure deployment complete"

Log-ScriptEnd




# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUg/OfqJkgR0KrzV0kZdbNctYF
# FdWgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBRWg+n2eMDp0PjiQuJd7B5DrU+PBjANBgkqhkiG
# 9w0BAQEFAASCAgCLRcjYqjW0y5TlOAK7pmgKdpivhjxQ0dD/Cx6V/HCec3sHrTyv
# 7X5keSzWEWd/m6hM3/GPtl8hbx+bDIzumBDtzG+q/c/kDG8aoPN90contN9WSfYm
# DV1fEEhtzfQqLULQyUz7x+Xk9Yg0IDuzC9Zk0ka8AGVBI0ZU472e3ZCAhq/N051F
# Ll8kG9cmDtlutzbh80b7aXIj/chUMGNyV7ogfrU70U/6c2QGxD9rhO6f19bU/PR6
# rXx8tSBxRMlfGPFB2JxBg6H2o2FyAY0HIXy5lsTkk1yUbsS/R4ulL5hr0XVUBh9q
# tmtnSejZWD+wD5NO4b8hpc5BPfCTs21lBOPT9qYJFHoLTHjm4cNW73qmPilsgTv/
# BegQQtqSdlvjRyuCUT2KjdRVzojSIsV8EFgqkKkyIX7UbN2E9XF1nr516BLSFVNH
# ZUHAeolA/coPG+joZAl0fOfDfCoBA8PYHEhbqB4/sdMP8fp5qKSYcBCF6xEeCr3l
# mDxGmDiXtpuXc7GyTw2lHQU3LzmTiF5eX9blmvkLPUGKnGWfLge86EJmuDCP2BuK
# 4gg4v7499iSvnKfvZtbz9rg4WNyEjqX0gP6IIM5FcwoPJq/fPuRIIsYBfcxTN3zN
# TtWqNgOlWSFIid1p5zTXXy1hve0HtToO9ekytddwY9N8H6/5qziIVscCew==
# SIG # End signature block
