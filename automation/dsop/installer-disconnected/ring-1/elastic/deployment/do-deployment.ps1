param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $BastionShortname,
    [Parameter(Mandatory=$true)] [string] $MasterShortname,
    [Parameter(Mandatory=$true)] [string] $DataShortname,
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
    [Parameter(Mandatory=$true)] [string] $ElasticClusterName,
    [Parameter(Mandatory=$true)] [int] $ElasticDataDiskSize,
    [Parameter(Mandatory=$true)] [string] $ElasticVersion,
    [Parameter(Mandatory=$true)] [int] $ElasticPublicPort,
    [Parameter(Mandatory=$true)] [int] $ElasticPrivatePort,
    [Parameter(Mandatory=$true)] [string] $ElasticKeyVault,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $TenantId,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [string] $AzureCloud,
    [Parameter(Mandatory=$true)] [string] $KeyVaultEndpoint,
    [Parameter(Mandatory=$true)] [string] $StorageEndpoint,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $StorageAccount,
    [Parameter(Mandatory=$true)] [string] $DiagnosticsStorage,
    [Parameter(Mandatory=$true)] [string] $BastionProxyUsername,
    [Parameter(Mandatory=$true)] [string] $BastionProxyIp
)

Set-LogFile -LogFile "./deployment-output/deployment_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

# ./do-parameter-validation.ps1

Log-Information "Confirm login"
Confirm-DsopAzLogin `
    -TenantId $TenantId `
    -SubscriptionId $SubscriptionId `
    -DeploymentType $DeploymentType

Log-Information "Generate the ansible hosts file"
./do-generate-ansible-hosts.ps1 `
    -MasterHostname $MasterHostname `
    -MasterNodes $MasterNodes `
    -DataHostname $DataHostname `
    -DataNodes $DataNodes `
    -AdminUsername $AdminUsername `
    -SshKey $SshKey

Log-Information "Creating Resource Group $ResourceGroup"
$argList = "group create -n $ResourceGroup -l $AzureLocation"
Run-Command -Process "az" -Arguments $argList

Log-Information "Create the infrastructure"
./do-create-infrastructure.ps1 `
    -DeploymentType $DeploymentType `
    -BastionShortname $BastionShortname `
    -BastionHostname $BastionHostname `
    -MasterHostname $MasterHostname `
    -DataHostname $DataHostname `
    -MasterAvailabilitySet $MasterAvailabilitySet `
    -DataAvailabilitySet $DataAvailabilitySet `
    -MasterLoadBalancer $MasterLoadBalancer `
    -clusterNsg $clusterNsg `
    -clusterSubnetName $clusterSubnetName `
    -appGatewaySubnetName $appGatewaySubnetName `
    -gatewayNsg $gatewayNsg `
    -MarketplacePublisher $MarketplacePublisher `
    -MarketplaceOffer $MarketplaceOffer `
    -MarketplaceSku $MarketplaceSku `
    -MarketplaceVersion $MarketplaceVersion `
    -VmSize $VmSize `
    -VnetName $VnetName `
    -VnetRange $VnetRange `
    -ClusterSubnetRange $ClusterSubnetRange `
    -GatewaySubnetRange $GatewaySubnetRange `
    -MasterNodes $MasterNodes `
    -DataNodes $DataNodes `
    -SshKey $SshKey `
    -AdminUsername $AdminUsername `
    -SubscriptionId $SubscriptionId `
    -TenantId $TenantId `
    -AzureLocation $AzureLocation `
    -ResourceGroup $ResourceGroup `
    -StorageAccount $StorageAccount `
    -DiagnosticsStorage $DiagnosticsStorage `
    -ElasticDataDiskSize $ElasticDataDiskSize `
    -ElasticKeyVault $ElasticKeyVault `
    -VnetPeeringName $VnetPeeringName `
    -OCPVnetName $OCPVnetName `
    -OCPResourceGroup $OCPResourceGroup

Log-Information "Obtaining Master IP Address"
$masterIpAddress=( az vm show -g $ResourceGroup -n "$MasterHostname-001v" -d --query privateIps -o tsv )
Log-Information "Master IP Address: $masterIpAddress"
Log-Information "Generating the ansible var file"
./do-generate-ansible-vars.ps1 `
    -KeyVaultEndpoint $KeyVaultEndpoint `
    -MasterHostname $MasterHostname `
    -MasterIpAddress $masterIpAddress `
    -StorageAccount $StorageAccount `
    -StorageEndpoint $StorageEndpoint `
    -DeploymentType $DeploymentType `
    -ElasticClusterName $ElasticClusterName `
    -ElasticDataDiskSize $ElasticDataDiskSize `
    -ElasticVersion $ElasticVersion `
    -ElasticPublicPort $ElasticPublicPort `
    -ElasticPrivatePort $ElasticPrivatePort `
    -ElasticKeyVault $ElasticKeyVault
    
Log-Information "Deploying Ansible"
./do-deploy-elastic-ansible.ps1 `
    -DeploymentType $DeploymentType `
    -ResourceGroup $ResourceGroup `
    -BastionHostname $BastionHostname `
    -AdminUsername $AdminUsername `
    -SshKey $SshKey `
    -BastionProxyUsername $BastionProxyUsername `
    -BastionProxyIp $BastionProxyIp `
    -ElasticKeyVault $ElasticKeyVault

Log-Information "Elastic has been deployed! Please check the log file above for usernames and passwords."
Log-ScriptEnd







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtpPl8t/zZsM2M6sRy+85Pv5r
# XrqgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBTH0BkgNKmt9WPlRTDnuIHm1WLY1TANBgkqhkiG
# 9w0BAQEFAASCAgBaPYNItvmrC9yu8Um110sUJH+1Ln4yG5NBUn0RV4gLDgDm7j9+
# 0bnzrjyq7PDZldetH067B6oCLGbpNhQEeu2lVQe2ziAhsc+Rt7tEGaLaQdtSQtaw
# BZEMQSQ3xiRiFIEmRp1AIWG5Men7nVc8WAIsKfHRS6OKBKUpbcp5QSnV4T2rcMbH
# JwGNh99REc/luBV/fyKfxWJXt9IxNGHs2OAh872xenIQA6QdffpN95XAzMFqwMUX
# VBqkIzfq8+S4+uwWpV7VUbrFCo5HWYwFk2FVv7Jbr5d4WKLnCvfp3tAmmysZkoru
# MUIFNXNYCsSotiQpPRe6IHTtjaSGJvjPraklpZH/TtP6yPBkJ7uzrvGz6dBpf5HN
# /SykccyeMLhEy1Ci2LqaPPGTgsjevg3DrcejUpDBv7zglrRgsA+zPIhGF78M9I8B
# 3arfN2Z4REKA0qc683HZVSGUzCc0xuGWyPZCEClz7enben/pphAjoLkYjzzIlh+3
# Scu98xwxio+2VjyP41jrPaRjc0nXWV/2eHtTKVgTqgc5+uvCpEtn/3JuV9oL/iOt
# m0gvxveH3BzxQCgwzFWQTLBPOxXt9xCH7Q2j2/QsS3auVYjhSXq4ZW8Z0rN2s4xs
# lNAVC/5ZFyh7s6QapjC1AqKBJnCHHyzqV8FA3cJYl+bXZsS3W49/Dj8XkA==
# SIG # End signature block
