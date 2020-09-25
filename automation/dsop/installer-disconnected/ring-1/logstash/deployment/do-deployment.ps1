param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $BastionShortname,
    [Parameter(Mandatory=$true)] [string] $LogstashShortname,
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
    [Parameter(Mandatory=$true)] [string] $ClusterSubnetRange,
    [Parameter(Mandatory=$true)] [string] $VnetPeeringName,
    [Parameter(Mandatory=$true)] [string] $ElasticVnetName,
    [Parameter(Mandatory=$true)] [int] $Nodes,
    [Parameter(Mandatory=$true)] [string] $LogstashVersion,
    [Parameter(Mandatory=$true)] [string] $ElasticResourceGroup,
    [Parameter(Mandatory=$true)] [string] $ElasticMasterLoadBalancer,
    [Parameter(Mandatory=$true)] [string] $ElasticMasterHostname,
    [Parameter(Mandatory=$true)] [int] $ElasticPrivatePort,
    [Parameter(Mandatory=$true)] [string] $ElasticKeyVault,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [string] $TenantId,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $StorageAccount,
    [Parameter(Mandatory=$true)] [string] $DiagnosticsStorage,
    [Parameter(Mandatory=$true)] [string] $BastionProxyUsername,
    [Parameter(Mandatory=$true)] [string] $OCPResourceGroup,
    [Parameter(Mandatory=$true)] [string] $BastionProxyIp
)

Set-LogFile "./deployment-output/deployment_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

# ./do-parameter-validation.ps1

Log-Information "Confirm login"
Confirm-DsopAzLogin `
    -TenantId $TenantId `
    -SubscriptionId $SubscriptionId `
    -DeploymentType $DeploymentType

Log-Information "Creating Resource Group $ResourceGroup"
$argList = "group create -n $ResourceGroup -l $AzureLocation"
Run-Command -Process "az" -Arguments $argList

Log-Information "Create the infrastructure"
./do-create-infrastructure.ps1 `
    -DeploymentType $DeploymentType `
    -BastionShortname $BastionShortname `
    -BastionHostname $BastionHostname `
    -LogstashHostname $LogstashHostname `
    -LogstashAvailabilitySet $LogstashAvailabilitySet `
    -LogstashLoadBalancer $LogstashLoadBalancer `
    -LogstashPorts $LogstashPorts `
    -clusterNsg $clusterNsg `
    -clusterSubnetName $clusterSubnetName `
    -MarketplacePublisher $MarketplacePublisher `
    -MarketplaceOffer $MarketplaceOffer `
    -MarketplaceSku $MarketplaceSku `
    -MarketplaceVersion $MarketplaceVersion `
    -VmSize $VmSize `
    -VnetName $VnetName `
    -VnetRange $VnetRange `
    -ClusterSubnetRange $ClusterSubnetRange `
    -VnetPeeringName $VnetPeeringName `
    -ElasticVnetName $ElasticVnetName `
    -ElasticResourceGroup $ElasticResourceGroup `
    -Nodes $Nodes `
    -SshKey $SshKey `
    -AdminUsername $AdminUsername `
    -TenantId $TenantId `
    -SubscriptionId $SubscriptionId `
    -AzureLocation $AzureLocation `
    -ResourceGroup $ResourceGroup `
    -StorageAccount $StorageAccount `
    -DiagnosticsStorage $DiagnosticsStorage `
    -OCPResourceGroup $OCPResourceGroup

Log-Information "Generating the ansible var file"
./do-generate-ansible-vars.ps1 `
    -DeploymentType $DeploymentType `
    -LogstashVersion $LogstashVersion `
    -ElasticResourceGroup $ElasticResourceGroup `
    -ElasticMasterLoadBalancer $ElasticMasterLoadBalancer `
    -ElasticMasterHostname $ElasticMasterHostname `
    -ElasticPort $ElasticPrivatePort `
    -ElasticKeyVault $ElasticKeyVault

Log-Information "Generate the ansible hosts file"
./do-generate-ansible-hosts.ps1 `
    -ResourceGroup $ResourceGroup `
    -LogstashHostname $LogstashHostname `
    -Nodes $Nodes `
    -AdminUsername $AdminUsername `
    -SshKey $SshKey
    
Log-Information "Deploying Ansible"
./do-deploy-logstash-ansible.ps1 `
    -DeploymentType $DeploymentType `
    -ResourceGroup $ResourceGroup `
    -BastionHostname $BastionHostname `
    -AdminUsername $AdminUsername `
    -SshKey $SshKey `
    -BastionProxyUsername $BastionProxyUsername `
    -BastionProxyIp $BastionProxyIp

Log-Information "Logstash has been deployed!"
Log-ScriptEnd




# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU0t2w2Qbwt9/3t9D4fEhNiGMO
# j9OgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBSrkgyjr1+EZ1+JFtH97TGUcIoJRTANBgkqhkiG
# 9w0BAQEFAASCAgAdl7RjGF+LUsl/HltCpJm/IIFi9r7346X6/xvqCX86UcOyhRXH
# uIklU9gl7D5rcG+Bo8PfVEmn4D9Mu+Wlkzawik0D6IGX0kJdM0GLXl480jCnNvyl
# xVEde6pfGYeoSkhdYlq8BKRRq5t8VtrD72xzFRSbIzEwRdbez8vfujf6zutr+h2/
# umFS2P0488585diokt31GP11QNKexJaMql0vXKFmVJ94zjOwPS7dX91RpNMyio3s
# GVq/di9xxrw53ECqNH97yRew9RsmkQ+lWqk2aaxP/l7aH2NUSt5x5479U4fHMAhR
# Orjsk5osc8va34mS2LSiiGl2loN9pJUfuC41waaNel47C6flzWCT2FuTA00mImzU
# h95zj78tz9fC9duVefa0l3S8bGHmtyv5DvsyHPWlhawBKA6FmqDhAQyzDYv44VnA
# PQYwsvfZHGF76k7+fajMPtbrOfSs75RRUn7Ro5IdIfBqgv/l8vCWtRTQJqNNUf6y
# rO6ZiTxNmC1grXzNp+doqj1Q8GAvVnVguXHm5RMEwZXcUSit2OCKaNiDtHSttzHQ
# homKblWo0PKEV5Ql2xFVEm2pa9W34D+2MwQrQhRArv/g1oBDyhi/Mh6PlzmlhHVM
# dXickFymkpWqD/KFgC/PzKKQ5Fqq7WZwoDRu3xtW+jq5ftGtUHjNueRaBw==
# SIG # End signature block
