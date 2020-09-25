$DepArgs = @{}

[string] $DepArgs.AppName = "jira"
[string] $DepArgs.AppUrl = "jira.apps.dev-openshift.com"
[string] $DepArgs.ContainerTag = "latest"
[string] $DepArgs.DatabaseName = "postgres"
[string] $DepArgs.JiraVersion = "8.8.1"
[string] $DepArgs.PostgresHostname = "postgres-jira-postgresql.jira.svc.cluster.local"
[string] $DepArgs.PostgresPassword = Get-RandomString 15 -IncludeNumber
[string] $DepArgs.StorageClass = "openebs-sc-statefulset"
[string] $DepArgs.AccessMode = "ReadWriteOnce"

# Below this line be dragons
[DeploymentType] $DepArgs.DeploymentType = [DeploymentType]::Disconnected

[string] $DepArgs.ContainerRegistry = "10.3.103.4:5000"
[string] $DepArgs.AdminUsername = "ocpadmin"
[string] $DepArgs.SshKey = "cfs-gPfAo"

[string] $DepArgs.SubscriptionId = ""
[string] $DepArgs.TenantId = ""

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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUTOFKsSSBlQioYjhfa+YnnM4C
# AK6gggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBS6PLPg1o71ADDzVmpuV7YQtdz+TDANBgkqhkiG
# 9w0BAQEFAASCAgBXyTBPdq8/WPqq1ogyZKyYeptfYG25Pv/jHc76cfKxwu4QQOjF
# msIuY9vncuYgXFUz2+GTC4IY/uNMKSwhJCIqxxlBNwwhLbBUdE24R9FvGRsEDIFO
# KqgKj5RW4D26Yi3jJL4Vx33c9XCI7r9nQWskEDnQJh/pag20Wfq+0kQXGlAigwyk
# zaGYL1kcuPobqDGskuMOoYW4muBJNTDlPx8x8k3ATvNpw0Adkt6j7PWiIrm9DM3+
# YumrodOADwxtwwo/UKtP2XnwPmKIxmaGz/z3qFhfj84113AMigemmjW3nxXzRblv
# Q6/FyP1UYbEk1qjp1/XsK4SINwTPATZEfMjLs2Lf3L1FUkqXV8XueAFe2Sl+KrIg
# wGCGVQr6XlACloI7aUCmIXaKAm42I48mWcZcjDpdrt0FF86wJDa1t1JKabkZZtxT
# POtWKKtmc2aCXgW7ZasXmQZN+mYr42PPa5QKGoQYj40+jtrDMXoQAueWRb/2R2lI
# 4NREQRYORi1dK0wsGe/Shar8o4Q2FZPM4fm99jE1fmfrvNylZ0C5yjlvV31Rb4dX
# 6LDMc4XbidrynjlSo5M703BLGLZhpZEWIb7pa6WYqy9lBkmal8GVr/n1LKvEgyGw
# +q1IuY9ssSSxIKtpN/M6064LyBant97EtOBsgaSmqlHJrLF/Lx1EV+JEqg==
# SIG # End signature block
