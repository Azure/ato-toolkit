$DepArgs = @{}

[DeploymentType] $DepArgs.DeploymentType = [DeploymentType]::Disconnected
[string] $DepArgs.SubscriptionId = ""
[string] $DepArgs.TenantId = ""
[string] $DepArgs.ClusterType = "ocp3"
[string] $DepArgs.AppName = "fortifyssc"

[string] $DepArgs.AppUrl = "fortifyssc.apps.dev-openshift.com"

[string] $DepArgs.ContainerRegistry ="10.50.101.4:5000"
[string] $DepArgs.SshKey = "cfs-cert"

[bool] $DepArgs.UsePrivateReg = $false
[string] $DepArgs.PrivateRegUn = "username"
[string] $DepArgs.PrivateRegPw = "password"
[string] $DepArgs.PrivateRegEmail = "registry@somecompany.com"

$ProductLine = "FF".ToUpper()
$Environment = "BETA".ToUpper()
$RegionLocation = "EAST".ToUpper()

[string] $DepArgs.ResourceGroup = "$($ProductLine)-$($Environment)-YNGRY-OCP-RG01"
[string] $DepArgs.AdminUsername = "ocpadmin"

$BastionShortname = "BSTN"

$Prefix = "$($Environment)-$($RegionLocation)"
[string] $DepArgs.BastionMachineName = "$($Prefix)-YNGRY-$($BastionShortname)-001v"

[string] $DepArgs.BastionProxyUsername = "1"
[string] $DepArgs.BastionProxyIp = "1"






# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAVDHXyBGLgWig3aGCt1JcXUq
# uOGgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBTAOmMmu48Ckn4lctPB2CWeaZsdbTANBgkqhkiG
# 9w0BAQEFAASCAgCSXRaRqEicA7KULXApf+1RonMPc/t4P9YAanYdLrCoM61b7Hu1
# kK+JfdgFa5zzQ4dYWnb+C06NrsKTytoJR6z5ba4kwvww01NSJcyF5kXLhcC0vJNS
# xbV0h+sC3uZnqVrvOZdvK1VG5Fj7/0OWl1VGwnwZnIhGL6RLDyBH+mzcinTvJGYD
# PWGXyGZXcELdaD8tLRPzlDUDtrLJscSTwWlmrA9YMnhO4J3QTT2ay6lYeR8zdHUT
# mYVulFM18YtPPAwg8D1+3KYzE2uz9uJIgt2tJhrIxr46SqLQrx3eKM98S87jsvJG
# 0+7b2IaeJ4OI49kbAfjB4ITBsXRyfDcqY5Vy1J8SoWIeEayp+I6m4LS+RvLSjpEY
# ylzkauMtJAKfpiWCRkDRZGLfFJGYTvd+PzHJ02SFnRAaKFIpba+CNJHWpyM9Fxfb
# pOXnZoN//9djOA0vzexLHd8qEdvDgeuTt4QOvTY+HNcjaQ2TzHUOc5Lxig17TOWK
# n07NgJZdIIUcJsgkc8urR60MbAZjI8gmb1+W1N1dEAgeiR1dIw5XJJwHtcn2hWIi
# a09COHjsdhK0lGP7rBluEhQJUMT5HO9fAyn/GEvImsVgVlRHCwPh8clCmMByEedk
# RqcPyU9LCh8ba77WQQXxHTvQ7jiV6VgXgmZ2LHHsZqfntvxIFK6ITcAv3Q==
# SIG # End signature block
