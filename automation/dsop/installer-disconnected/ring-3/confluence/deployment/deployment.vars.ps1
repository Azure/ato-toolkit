$DepArgs = @{}

[string] $DepArgs.SubscriptionId = ""
[string] $DepArgs.TenantId = ""
[string] $DepArgs.AppUrl = ""
[string] $DepArgs.ContainerRegistry = "10.3.103.4:5000"
[string] $DepArgs.SshKey = "cfs-gPfAo"

# Below this line be dragons
[DeploymentType] $DepArgs.DeploymentType = [DeploymentType]::Disconnected

[string] $DepArgs.AppName = "confluence"
[string] $DepArgs.ConfluenceVersion = "7.5.0"
[string] $DepArgs.ContainerTag = "latest"
[string] $DepArgs.DatabaseName = "postgres"
[string] $DepArgs.PostgresPassword = Get-RandomString 15 -IncludeNumber

[string] $DepArgs.AdminUsername = "ocpadmin"

[string] $DepArgs.ProductLine = "FF".ToUpper()
[string] $DepArgs.Environment = "BETA".ToUpper()
[string] $DepArgs.RegionLocation = "EAST".ToUpper()

[string] $DepArgs.ResourceGroup = "$($DepArgs.ProductLine)-$($DepArgs.Environment)-OCP-RG01"

$BastionShortname = "BSTN".ToUpper()

$Prefix = "$($DepArgs.Environment)-$($DepArgs.RegionLocation)"
[string] $DepArgs.BastionHostname = "$($Prefix)-$($BastionShortname)"







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtGPkQfoxLXK9tkzE6XmfB+xY
# vMSgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBTpRahppEJx8anT7fE/9+Zg5xO6nDANBgkqhkiG
# 9w0BAQEFAASCAgCBWs93kp1HlGChJCEpR4Lu6WLHA8nr9CesYP5qV48DBXc2dmtG
# +Y2o1AaHP9TvozodwUpajOs4VS3HbSi6yCQ/G1kR1Xp1HQaeVYLwblZWC3sh3RKq
# OMWNIemvKF2DJszpXxl5Gt9+7kmOc9cWnKayqo5/+DoDvQJn9SOAUZD90WnIwXuV
# chKLjH2WRTVTkvfzZqB8cK+eBtAfCpXHCxna24VjmgB8gD0zJejU5pE1QSqZGKIQ
# GlmT0EjS6QMXuheCB68eEgteA410/1F+0+fJVVEAz6RoujS4HRLMjqGFf6r/27VC
# vHRYzNadQz+AQuMLiqSBzEHhn2iV4CcE9VKndH5/5pK8/djANY1qgeJT7Et3AkfA
# FLlwlK7UVbN2EbM6YKuP3kFp7jWx6OC/bsYTBqNWTpkonRbgZ37KK4EnBo6rSD6L
# QUFWTxcYvFMixoSe0zV7QiNyEzMhgN+o9H+2DFCeqMuDvLLMaXGCr8D0LqK+RJHe
# vNzUUbamfI3pHczSAJDtscWEhDlmSJvaFWmgLfFjz/N3LW/NgoaqGqSSmEntYxKD
# pPuOzML00BKnyR4xpqHITDQWf6coPWJJG7ODvTIWLJA5oCrgOdFAotYD/2m7sQyZ
# ZUCnHTBbt/K1RMIgn72lTxs0FdJ3Fc1rqovQjIgsRHHwEuwocebvWcRqdw==
# SIG # End signature block
