$DepArgs = @{}
[DeploymentType] $DepArgs.DeploymentType = [DeploymentType]::Disconnected
[string] $DepArgs.SubscriptionId = "1276e393-6872-4200-9a18-eaf57f37a43c"
[string] $DepArgs.TenantId = "7a68be11-d228-4b69-bdd3-2395129e13c7"
[string] $DepArgs.AzureLocation = "usgovvirginia"

[string] $DepArgs.VnetName = '"logstash"'
[string] $DepArgs.VnetRange = "10.20.0.0/16"
[string] $DepArgs.ClusterSubnetRange = "10.20.6.0/24"


[string] $DepArgs.VmSize = "Standard_DS2_v2"

$ProductLine = "FF".ToUpper()
$Environment = "BETA".ToUpper()
$RegionLocation = "EAST".ToUpper()

[string] $DepArgs.ResourceGroup = "$($ProductLine)-$($Environment)-LGST-RG01"
$StorageAccountPrefix = "$($Environment)$($RegionLocation)".ToLower()
[string] $DepArgs.DiagnosticsStorage = "$($StorageAccountPrefix)`diaglst001".ToLower()

[string] $DepArgs.AdminUsername = "ocpadmin"

[string] $DepArgs.StorageAccount = "thisisforlogstash1"

[string] $DepArgs.MarketplacePublisher = "RedHat"
[string] $DepArgs.MarketplaceOffer = "RHEL"
[string] $DepArgs.MarketplaceSku = "7-RAW"
[string] $DepArgs.MarketplaceVersion = "latest"

# File path to pfx certificate file
# [string] $DepArgs.PathToCert = "./star.cloudfitdsop.com.pfx"
# certificate password
# [string] $DepArgs.CertKey = "xxxxxxxxx"

[int] $DepArgs.Nodes = 2

[string] $DepArgs.LogstashVersion = "7.6.2"
[string] $DepArgs.LogstashPorts = "5040,5041,5042,5043,5044,5045"

[int] $DepArgs.ElasticPrivatePort = 9300

# currently for sequoia when needing to have a jump host to get into the environment
[string] $DepArgs.BastionProxyUsername = "proxy"
[string] $DepArgs.BastionProxyIp = "52.170.33.214"

# naming #
[string] $DepArgs.BastionShortname = "BSTN"
[string] $DepArgs.LogstashShortname = "LS"

$Prefix = "$($Environment)-$($RegionLocation)"
[string] $DepArgs.BastionHostname = "$($Prefix)-$($DepArgs.BastionShortname)"
[string] $DepArgs.LogstashHostname = "$($Prefix)-$($DepArgs.LogstashShortname)"

[string] $DepArgs.LogstashAvailabilitySet = "$($DepArgs.LogstashHostname)-AS01"
[string] $DepArgs.LogstashLoadBalancer = "$($Prefix)-$($DepArgs.LogstashShortname)-LB"

$VirtualNetworkName = "IsolationVnet"
$MasterInfraSubnetName = "MasterInfraSubnet"
[string] $DepArgs.clusterNsg = "$($Prefix)-LGST-SN-NSG"
#[string] $DepArgs.clusterSubnetName = "/subscriptions/$($DepArgs.SubscriptionId)/resourceGroups/$($DepArgs.ResourceGroup)/providers/Microsoft.Network/virtualNetworks/$VirtualNetworkName/subnets/$MasterInfraSubnetName"
[string] $DepArgs.clusterSubnetName = "$($Prefix)-LGST"

##### Elastic Values
[string] $ElasticMasterShortname = "ESNM"
[string] $DepArgs.ElasticResourceGroup = "$($ProductLine)-$($Environment)-ELK-RG01"
[string] $DepArgs.ElasticMasterLoadBalancer = "$($Prefix)-$($ElasticMasterShortname)-LB-PIP"
[string] $DepArgs.ElasticMasterHostname = "$($Prefix)-$($ElasticMasterShortname)"
[string] $DepArgs.ElasticKeyVault = "$($ProductLine)-$($Environment)-ELK-RG01-KV" 
##### End Elastic Values

# Do Not Touch. This will get generated when the artifacts are created
# [string] $DepArgs.SshKey = "cfs-btdDG"

[string] $DepArgs.SshKey = "cfs-lVALy"

# Peering and OCP vars
[string] $DepArgs.VnetPeeringName = "logstash2elastic"
[string] $DepArgs.ElasticVnetName = "elastic"
[string] $DepArgs.OCPResourceGroup = "$($ProductLine)-$($Environment)-UMGFD-OCP-RG01"




# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUwfwT7r7EBlnn1TRbSnAyHx5s
# +3CgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBQqPvwV9OHsiB/KY96T+g4u9E+T8zANBgkqhkiG
# 9w0BAQEFAASCAgCCOkCbGTGCvTOgr2lh4R02Tx/5GvZG6lIi3sr/VG0qKb1SCZ9v
# iNdKbZIIbslY5xLewnJE2rhn/yMwcgtQi/EB3xvXkx55ZtYqwnyHcNyjLumflgbw
# OckxjLYrPZW1rEQGgPWUKkdzQ7dI12cYAm7i4cwW3YMBuhn8loMzDsHFawOOTVWo
# 5v9Zik+3QfFZ2ZczsMhBv7ffu1J+n2HNuS7r4VCDwjjVNNFw3A/gAkMjeUPA/fiK
# 7In4VhbPgLzRpRKEgmGNXSBilNtnGkWV39GsM6s24sPmXMREDSh+nT7AGAi+7ijy
# QhiAwVNWE2KTW5+3Sfz/Fmbsz4BkG3cozVmlaPK4WVfUW5MBe2ruAxmMyUu61oFm
# WWjZ0tmeIOwaax8LpF/p2j3Ug10axzvFhLy4fMN1fgnkAM64s7wCICu2wefGTIn+
# 1PsktvPTkmb9rDSJIU+IcGv5q13F2JlyYDjmDkSIj9VesSKOK4bEQ5vHLon53xMY
# OzatdgDY6HjnuyUuMIJO3pr5tbqvygj94GUq7hXOmaGgLJpp7+4tuleyLb3I07Eu
# 0/JN9QAuu0Vyi2Cn0+LfXkqVNDH3yoe9Al8dyVxBhzJWy8KW/lAJyrQmjNfXAtpi
# UXwY9cjfWfIjS/3ZFcfNPuWOEsEEsN9Vv3OjvNH5Y8mmMpxO4dlG2BMJIw==
# SIG # End signature block
