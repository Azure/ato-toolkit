$DepArgs = @{}

[DeploymentType] $DepArgs.DeploymentType = [DeploymentType]::Disconnected
[string] $DepArgs.SubscriptionId = ""
[string] $DepArgs.TenantId = ""
[string] $DepArgs.ClusterType = "ocp3"

[string] $DepArgs.AppName = "nessus"
[string] $DepArgs.AppUrl = "nessus.apps.dev-openshift.com"
[bool] $DepArgs.UseRegistryCredential = $false
# if above value is true, modify the following two settings
[string] $DepArgs.RegistryUserName = "privateUser"
[string] $DepArgs.RegistryUserEmail = "user@company.com"

[string] $DepArgs.ContainerRegistry = "10.50.101.4:5000"
[string] $DepArgs.AdminUsername = "ocpadmin"
[string] $DepArgs.SshKey = "cfs-cert"

$ProductLine = "FF".ToUpper()
$Environment = "BETA".ToUpper()
$RegionLocation = "EAST".ToUpper()

[string] $DepArgs.ResourceGroup = "$($ProductLine)-$($Environment)-YNGRY-OCP-RG01"

$BastionShortname = "BSTN"

$Prefix = "$($Environment)-$($RegionLocation)"
[string] $DepArgs.BastionMachineName = "$($Prefix)-YNGRY-$($BastionShortname)-001v"

[string] $DepArgs.BastionProxyUsername = "1"
[string] $DepArgs.BastionProxyIp = "1"





# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQURQ0i2UtDIJu78UZdtwyGcKoD
# NVegggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBRHOUFP+zQnUpXxNrAgICHOSh9Y8DANBgkqhkiG
# 9w0BAQEFAASCAgAHS2hswDmWn5ldRjnk+4RLu5iHO2s7vZ1nMf7It0v7TER789zV
# 45CKt2D5W6Nam4reFohV/OMz/yEThm+pCrD3H7p3cvdDibk7FBxCAdKdpgJjQm/1
# E+32RUXACTFYXWg6usJHeyK0zbhqOWDR7Aj3jQ/eUKlQjEBfIIsYA2fWFBawNv5O
# NpqO00Qdg66L1R9Vh1bYcODh4rQftgpIdvRh2AKt8l2aP9Rt5LipvyCDgzq9SJvJ
# uk8nhV2YW8qA1sgDBjnlAlzTq1u8qaDv06orOQ98zjnWeyzzHEhaUAynbqD9jh0J
# dtmrzGYoT/EMbL+o5jZtAGDU7HFnOC3SW0g/PQnLmGjf6AL38axSGMq6rwCCHAtw
# /gWjcYB+8twZmR+JIe8nTci8R0//ojOMw8ovH1fiteLxehEdbdclpsqQWNk+m8D7
# +t+YoBRJXou1qnfcZRmIcQYzNyHTPF2rZnlbFFoI+ZwXzsNC5Ad+WjMx6CzaLFld
# qwl6Kx0qO8vzSrYqtWQpcXrIEUbd1yv0dvGdcSk1FA+EfbMe5WCpY5knRgeU2IGo
# DiK3Qhcq0+psnDKBogpjOFChwRyud7r7aA8ev2bcNEA2UCuD5j3v/BY1wBFD4f2a
# NV7nxJBWmam1ahGDF+xi+wwqfglffrEua1MXE+HhVdN6suk7NZ5WC6IDhg==
# SIG # End signature block
