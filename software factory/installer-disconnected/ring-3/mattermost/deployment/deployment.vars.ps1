$DepArgs = @{}

[DeploymentType] $DepArgs.DeploymentType = [DeploymentType]::Disconnected
[string] $DepArgs.SubscriptionId = ""
[string] $DepArgs.TenantId = ""
[string] $DepArgs.ClusterType = "ocp3"

[string] $DepArgs.AppName = "mattermost"
[string] $DepArgs.PostgresUsername = "postgres"
[string] $DepArgs.PostgresPassword = Get-RandomString 15 -IncludeNumber

[string] $DepArgs.Namespace = "ns-mattermost"

[string] $DepArgs.AppUrl = "mattermost.apps.dev-openshift.com"

[string] $DepArgs.ContainerRegistry = "10.3.103.4:5000"
[string] $DepArgs.AdminUsername = "ocpadmin"
[string] $DepArgs.SshKey = "cfs-gPfAo"

[bool] $DepArgs.EmailNotifications = $false
[bool] $DepArgs.EnableSmtpAuth = $false
# If EnableSmptAuth == $true, apply values below
[string] $DepArgs.SmtpUsername = ""
[string] $DepArgs.SmtpPassword = ""
[string] $DepArgs.SmtpServer = "smtp.office365.com"
[int] $DepArgs.SmtpPort = 587

[string] $DepArgs.ProductLine = "FF".ToUpper()
[string] $DepArgs.Environment = "BETA".ToUpper()
[string] $DepArgs.RegionLocation = "EAST".ToUpper()

[string] $DepArgs.ResourceGroup = "$($DepArgs.ProductLine)-$($DepArgs.Environment)-OCP-RG01"

$BastionShortname = "BSTN".ToUpper()

$Prefix = "$($DepArgs.Environment)-$($DepArgs.RegionLocation)"
[string] $DepArgs.BastionMachineName = "$($Prefix)-$($BastionShortname)-001v"

[string] $DepArgs.BastionProxyUsername = ""
[string] $DepArgs.BastionProxyIp = ""







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUEoQ94lK5FX+HO+6YMTfXaxRN
# 6YmgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBSdMMKvohvsXkSTWonLV4L8p/rwRTANBgkqhkiG
# 9w0BAQEFAASCAgCExL9bUhNKs2H9rMXvCqOYWNPD60dIm2wOpZ3mrSle9r+7BhZ7
# eU/hNEMtCoucrgyquuPMnMpTLTypoxtHU/HPLbsEx40Y/XdzyDR+tbpFk22Xb5Ed
# n1IIxlQ1LLqwX6V99Ak4HiJqUGkX1QtJ/pNBSBr0TLngZ/AL3Jqw0OO0/WzJaJPL
# zeya4rk+liWNLo15VXBjIGOaFnNcHVbdZPPolwkszXat9Z/T1z5MJ8zok7bD59Sa
# 8+GlmBddR7j1NqLrjciRtZUySDW8ILDvbZrQLFVBG18GR9ybXVD0X4q3wII29YX4
# z9+h9pHRsis2lPvMNpuOZixSunfqS2BQmcH1hB1DYAAFF4P4FCwJCOAexZFQOI7j
# ChLk+Z3n+12WhS7poecHWORaiUbg1lWY1J/DeXAq/U9RWQJx2Laf+43ZJqSIgiZF
# Q57ptO1kHIwJ0mNj7IuPM39m2Ok94NKIsrGaMPBrrR7KMEV6j7IAf5KG1aA647oa
# A0Bev/5AQD0KxW6QUa5vPak8UakhSEZLzOrDugPkK1NdCOS08CX/hNaUcRvoFZO0
# OJni/7t+7F+qeoZvTdvRKR23ybGQfjpc88Wkly2ENJaVMyw/54zcNwv3HPhvAFlt
# k3UMQLsv34HeyXfPVnFOIHr+6nn0xjCJwIRIai0tsum8yOJ3x48ks1hcIg==
# SIG # End signature block
