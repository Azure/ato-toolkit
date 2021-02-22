$DepArgs = @{}
[string] $DepArgs.AzureCloud = "AzureCloud"
[string] $DepArgs.AzureLocation = "eastus"
[string] $DepArgs.SubscriptionId = "aeb097ab-91db-407b-8644-b9874321d163"
[string] $DepArgs.TenantId = "8a70434e-63d4-417b-970f-ac10f6b188fa"
[string] $DepArgs.KeyVaultEndpoint = "vault.azure.net"
# core.usgovcloudapi.net | core.microsoft.scloud
[string] $DepArgs.StorageEndpoint = "core.windows.net"

[string] $DepArgs.VnetName = '"elastic"'
[string] $DepArgs.VnetRange = "172.17.0.0/16"
[string] $DepArgs.ClusterSubnetRange = "172.17.5.0/24"
[string] $DepArgs.GatewaySubnetRange = "172.17.2.0/24"

[string] $DepArgs.VmSize = "Standard_DS2_v2" #stack:"Standard_DS13_v2" #azure:Standard_E8s_v3

$ProductLine = "FF".ToUpper()
$Environment = "BETA".ToUpper()
$RegionLocation = "EAST".ToUpper()

[string] $DepArgs.ResourceGroup = "$($ProductLine)-$($Environment)-ELK-RG01"
$StorageAccountPrefix = "$($Environment)$($RegionLocation)".ToLower()
[string] $DepArgs.DiagnosticsStorage = "$($StorageAccountPrefix)`diagst001".ToLower()

[string] $DepArgs.AdminUsername = "ocpadmin"

[string] $DepArgs.StorageAccount = "thisisforelastic"

[string] $DepArgs.MarketplacePublisher = "RedHat"
[string] $DepArgs.MarketplaceOffer = "RHEL"
[string] $DepArgs.MarketplaceSku = "7-RAW"
[string] $DepArgs.MarketplaceVersion = "latest"

# File path to pfx certificate file
# [string] $DepArgs.PathToCert = "./star.cloudfitdsop.com.pfx"
# certificate password
# [string] $DepArgs.CertKey = "xxxxxxxxx"

[int] $DepArgs.MasterNodes = 3
[int] $DepArgs.DataNodes = 5

[string] $DepArgs.ElasticClusterName = "es-IL4"
[string] $DepArgs.ElasticVersion = "7.6.2"
[int] $DepArgs.ElasticDataDiskSize = 64
[int] $DepArgs.ElasticPublicPort = 9200
[int] $DepArgs.ElasticPrivatePort = 9300
[string] $DepArgs.ElasticKeyVault = "$($DepArgs.ResourceGroup)-KV"

# currently for sequoia when needing to have a jump host to get into the environment
[string] $DepArgs.BastionProxyUsername = "proxy"
[string] $DepArgs.BastionProxyIp = "52.170.33.214"

# naming #
[string] $DepArgs.BastionShortname = "BSTN"
[string] $DepArgs.MasterShortname = "ESNM"
[string] $DepArgs.DataShortname = "ESND"

$Prefix = "$($Environment)-$($RegionLocation)"
[string] $DepArgs.BastionHostname = "$($Prefix)-$($DepArgs.BastionShortname)"
[string] $DepArgs.MasterHostname = "$($Prefix)-$($DepArgs.MasterShortname)"
[string] $DepArgs.DataHostname = "$($Prefix)-$($DepArgs.DataShortname)"

[string] $DepArgs.MasterAvailabilitySet = "$($DepArgs.MasterHostname)-AS01"
[string] $DepArgs.DataAvailabilitySet = "$($DepArgs.DataHostname)-AS01"
[string] $DepArgs.MasterLoadBalancer = "$($Prefix)-$($DepArgs.MasterShortname)-LB"

[string] $DepArgs.clusterNsg = "$($Prefix)-$($DepArgs.DataShortname)-NSG"
[string] $DepArgs.clusterSubnetName = "$($Prefix)-ESC"
[string] $DepArgs.appGatewaySubnetName = "$($Prefix)-ESGW"
[string] $DepArgs.gatewayNsg = "$($Prefix)-$($DepArgs.MasterShortname)-NSG"

[DeploymentType] $DepArgs.DeploymentType = [DeploymentType]::Disconnected

# Do Not Touch. This will get generated when the artifacts are created
# [string] $DepArgs.SshKey = "cfs-btdDG"

[string] $DepArgs.SshKey = "cfs-CzbhU"

#Peering and OCP vars
[string] $DepArgs.VnetPeeringName = "elastic2ocp"
[string] $DepArgs.OCPVnetName = "OcpVNet"
[string] $DepArgs.OCPResourceGroup = "$($ProductLine)-$($Environment)-UMGFD-OCP-RG01"






# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZqTYBN70J2lQlQoXnaFZpU27
# jw2gggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBTPx34Y/EvLs/2XycjnM5aMVW1udTANBgkqhkiG
# 9w0BAQEFAASCAgAtFezmaSVUP97GTLQ0jIhMr1djE/Q10vTbWd2YoD81LFl+uSL5
# dgjguy1Vajva8WoWaRO3xvO8UroE8D+xCLP2KyZjWMIyly2BynvyMbKQ40szyGdh
# X6ATyu+WfvqbnzTIddv2w52JNJ6HRV8TpO63r3IuCdDW2rhWvTJr4RPF/sukYChP
# hssFz1iaP0SBMLTLRSYWW5nId/aPV+YPIaR1htOJHIwMtazYwj9gMfMSsUwHoTuD
# c9DGZc7LAQD8F6tGRgFzpsH79g09XxvXT8YRa53SdrDPG5aQZU8RnXEVlKGu/ArJ
# 1VMfL2TPWsKIcbCQN2HjOaC5aIRtm/qYfhAuDc9XKAUuQPbbZU3okg/jSYfpRxSh
# 7ddMPY8Q+bQwFm1wPsbczHZiwvm7TTXuDxSKJH8m7Tf4nm9GGnyymOPHmQutKoqx
# l1dKMSFrgQPsIIYdoc/rG7BeO9HfGjWAHYOZ1M2w0Yjts1TPWx0pIJ2vcVM2diIq
# H0HpDNnIceb6b7x2zXLRx2b5sojD/rRNmwRM2Gj8zN5iDGdInf1iU88HLtxwergb
# ocnotCoMbWPEpmY311cA2KbWiADuwSdl1L7dT6qggQIXqL5d47yDKya6ehA5/toD
# 588LVGZNtYursx/5mGUd20+JLWa/qj7n47b7g0/VhssaP1psBWKS1rbAhA==
# SIG # End signature block
