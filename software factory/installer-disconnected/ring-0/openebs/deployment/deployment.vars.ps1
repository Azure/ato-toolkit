$DepArgs = @{}


#less Commonly changed vars
[DeploymentType] $DepArgs.DeploymentType = [DeploymentType]::Disconnected
[string] $DepArgs.ClusterType = "ocp3"
[string] $DepArgs.AppName = "openebs"
[string] $DepArgs.DriveName = "OpenEBSDisk00"
[string] $DepArgs.StringMatch = "NODE"
[bool] $DepArgs.IsInsecureRegistry = $true
[string] $DepArgs.AdminUsername = "ocpadmin"
[string] $DepArgs.NSSCertPath = "/foo/bar/fizz/buzz.pem"

#EnvName Vars
$ProductLine = "FF".ToUpper()
$Environment = "BETA".ToUpper()
$RegionLocation = "EAST".ToUpper()


#Container Regsitry Vars
[string] $DepArgs.ContainerRegistry = "10.50.101.4:5000"
#[string] $DepArgs.RegistryUsername = ""
#[string] $DepArgs.RegistryPswd = ""

#placeholders
[string] $DepArgs.BastionProxyUsername = "1"
[string] $DepArgs.BastionProxyIp = "1"

#Bastion IP
[string] $DepArgs.BastionMachineIp = ""

#SSH Key Name
[string] $DepArgs.SshKey = "cfs-cert"

#AZ service principal
[string] $DepArgs.Username = ""
[string] $DepArgs.Tenant = ""
[string] $DepArgs.Paswd = ""
[string] $DepArgs.AzArgs = "--service-principal"

#Variables that need changing based on environment name randomness
#[string] $DepArgs.EBSResourceGroup = "FF-BETA-YNGRY-OCP-RG01"
[string] $DepArgs.ResourceGroup = "$($ProductLine)-$($Environment)-YNGRY-OCP-RG01"
#[string] $DepArgs.ResourceGroup = "$($ProductLine)-$($Environment)-OCP-RG01"

$BastionShortname = "BSTN"

$Prefix = "$($Environment)-$($RegionLocation)"
[string] $DepArgs.BastionMachineName = "$($Prefix)-$($BastionShortname)"

# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU6eG0se2gzlz3MDXIj2fz+SVD
# DRSgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBRXoeYllLjToTjrESrBhuDJEgEblzANBgkqhkiG
# 9w0BAQEFAASCAgBPow0gnTHShzTdmAwPFjF5whwukYCp7/7mmGEm1+lpGRu5AtJD
# X3MSkg1A7WHLbIG4Mgdcx1QWs1LKu7MftQFJurK7UsIixxN2hoRcUoVN+8PcAKsF
# f60iF+D8nHd4ygNr8BUP8sPlLOv4em4aC4DOLcuVEylcQWfwOlILU1AkPWW1etii
# yrzeefgIB5pviz9MNkjycFoxpmOTo5EHLvKSEA5vMLDoGEuvMvh+PXfRZtnva4V5
# 2UboESKSzvreLuwdReQ0tj9+xaQWJIwv/dDhsdt5SNqBJ85jDS/BIvKq9FShR8un
# eJwlYy0P4bswo4aFCaZEMPS4lVksLYZfpK7LLGAPhmW7Yqj1B+3Vf6rnn4cIYqWP
# 9+Wt+TnEVfLeuszeMDoUiKFbxu0oUz2O0BBfLxY8ERvuv+lQ3dWoLUdSOm4KvVT0
# kd8HKJW8YGpNmCLwysWR+OuA7tyiNAJb+Qi6h8HNSio0nMEo+yJ9/fAenFZ5VQKC
# xmas4IYoxEZluzAjoqHZxGdbJBpw2TdGmP4+yucTYTzJsPO0bDxg92FFIR2S+6wA
# FAPxyjo6uoLZNzaTACuyyzAGonQ/rY+k94ZSEOAr3Qv0W9woNNtGNvJlbEZPLH5J
# xkX+g0VwlKQ00QbicEJP585r7IGuzMsmaqsKs+dBTPEzBzcNJJzrFQe8NQ==
# SIG # End signature block
