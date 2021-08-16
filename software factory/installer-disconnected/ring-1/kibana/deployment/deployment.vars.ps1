$DepArgs = @{}

[DeploymentType] $DepArgs.DeploymentType = [DeploymentType]::Disconnected
[string] $DepArgs.SubscriptionId = ""
[string] $DepArgs.TenantId = ""
[string] $DepArgs.ClusterType = "ocp3"
[string] $DepArgs.AppName = "kibana"
[string] $DepArgs.ElasticHostIp = "10.3.101.23"

[string] $DepArgs.AppUrl = "elastic-kibana.apps.dev-openshift.com"

[string] $DepArgs.ContainerRegistry = "10.3.103.4:5000"
[string] $DepArgs.AdminUsername = "ocpadmin"
[string] $DepArgs.SshKey = "cfs-cert"

$ProductLine = "FF".ToUpper()
$Environment = "BETA".ToUpper()
$RegionLocation = "EAST".ToUpper()

[string] $DepArgs.ResourceGroup = "$($ProductLine)-$($Environment)-YNGRY-OCP-RG01"
[string] $DepArgs.KeyVault = "$($ProductLine)-$($Environment)-OCP-RG94-KV"

$BastionShortname = "BSTN"

$Prefix = "$($Environment)-$($RegionLocation)"
[string] $DepArgs.BastionMachineName = "$($Prefix)-YNGRY-$($BastionShortname)-001v"

[string] $DepArgs.BastionProxyUsername = "1"
[string] $DepArgs.BastionProxyIp = "1"






# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUsgYcvgqs7V0eaBqmGDj+HrXn
# Pi2gggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBQTPfJSBuReqqmtYogVmS2sgTHYwzANBgkqhkiG
# 9w0BAQEFAASCAgA90kzDdJ4do2xobjb927UKAOv4vsus4mMbfrmWKbY3M+hmKdex
# ZzxMcLyY2DOTHYJqHTUIROPtt+KZeIhZnqY41N+bIuujevzVz6eLNDsS3hzUok62
# W30KZ8PwqiYgkQK4seF37qkF9140OF2RXFGluuf8JnqWpj+U7q3K0MwTKdSbjjK9
# l1GXH5rP5a610eckKBMDbBEGyTs2bfiIhd5L/4jzMcl3eSm/sCtDUhttgAD/ALJn
# QBy4iz0VSdB4W/kE9G+DaoIUL+QvePQgogPU4wv613lr5/XttYqw9faOkr8wEbAm
# EM5w+VWTSk8QNoodniNRpiW2nuRz65pMvef7SNXPPiXOSfqN9SJ5y5+NOX7db0i0
# lne/vM9Z18CHgUyGEcUJLgfhaV/FW8kmFWx8in8VMo6LpwGxUlllzI7XF2GShdl7
# ZyZKf836u/ibGtaBwaF1XlVb2NuWj0+yqVzTIbOWLhvywwgOKZJ1jGzORjWSk4qi
# fzwww6JFaoqeVPSs6PogBjIez/C14ii2uoZmdNsbdmfjFBRZwbreUDL/urDP8cER
# nlXO8SBr9MpV+JjzGb5RlUhSjW3up02YiHD9B7YIdVZTA63oSMDmrcnqaecI+pR3
# tbcm8rObqzNkLVIV3jipH/fZv0a2Gb/WMGTlg1cFUOyx5zeGYLulX6R0MQ==
# SIG # End signature block
