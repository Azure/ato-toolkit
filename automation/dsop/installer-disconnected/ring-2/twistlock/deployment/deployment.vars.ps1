$DepArgs = @{}

[DeploymentType] $DepArgs.DeploymentType = [DeploymentType]::Disconnected
[string] $DepArgs.SubscriptionId = ""
[string] $DepArgs.TenantId = ""
[string] $DepArgs.ClusterType = "ocp3"
[string] $DepArgs.AppName = "twistlock"

[string] $DepArgs.AppUrl = "twistlock.apps.dev-openshift.com"
[string] $DepArgs.ConsoleUser = "anyOldJoe"

[string] $DepArgs.ContainerRegistry = "10.50.101.4:5000"
[string] $DepArgs.SshKey = "cfs-gPfAo"

[bool] $DepArgs.UsePrivateReg = $False
[bool] $DepArgs.UseRegistryCredential = $False
[string] $DepArgs.PrivateRegUn = "aUser"
[string] $DepArgs.PrivateRegPw = "aPassword"
[string] $DepArgs.PrivateRegEmail = "user@company.com"

[string] $DepArgs.ConsoleTag = "latest"
[string] $DepArgs.DefenderTag = "latest"

[string] $DepArgs.TwistlockLicense = "ThisIsNotALicense"

$ProductLine = "FF".ToUpper()
$Environment = "BETA".ToUpper()
$RegionLocation = "EAST".ToUpper()

[string] $DepArgs.ResourceGroup = "$($ProductLine)-$($Environment)-[YourRandomValue]-OCP-RG01"

$BastionShortname = "BSTN"
[string] $DepArgs.AdminUsername = "ocpadmin"

$Prefix = "$($Environment)-$($RegionLocation)"
[string] $DepArgs.BastionMachineName = "$($Prefix)-[YourRandomValue]-$($BastionShortname)-001v"

[string] $DepArgs.BastionProxyUsername = "1"
[string] $DepArgs.BastionProxyIp = "1"




# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUd194bskxD1SI32F42qVtn3x6
# k9mgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBSfuW2UUtxjOSKri346cPjdWxmcFDANBgkqhkiG
# 9w0BAQEFAASCAgBxDMJScjV+3V04mWeGHmwc1x4AItQigboRDQahDGmdrC0smr6l
# DSCWTUPR22ruPJuM1cfCH1fD18+amGydQuwzLIr3Spv1R1pOWBzAvE0a7W67Tf3F
# BU6091F4JiVrLZ6xf6JhnUADLczoInpEqZ7MriCNkVMPY8RIDmwWQIBVlEC6M/2c
# aj8arEjd0Cx1kQCPoRYkqzGXD2LywaO7e47b9N4zHKrhuA8twnkCPnkJbHoWabWr
# vylEZ/pPJKcAN9gLutbfZUXzK0JBp5LHBeEFtUVvRlStRPC5H2QLGnfYd78PK+Wi
# 3JPUTBE3CjuvpNlOqlZ8fEJzQ385j3XGowJaNESlfr6nC/HQ6nSOyfnqIUUbqPFh
# n861jjjeRLodai8+BZg5bUajf+zUKGm41kf2bYmBSFcqU3rFzkf5T1PdNiokeJcN
# yCBtI5MS3aBVsOEf26/V4vcBqIwK6kXqESjjoe69EibbSbzZWtzphbQAcTTNfFAW
# MX3Ccc2haYmHQU4olC1hsM3zdab56ewwcB1H6cFlywGoxZySrkavMfcXLP97rBfY
# 5is158HpMHIAunUMZ0KZdPrlKnjXQCtHpwVh1mnNq07E2YhrfIReBFqgF4RhFGfV
# nww19+dYA4NWPydcVKqobCMnsky8avdF4Pd8SLP5oD+uv+QBUg/ZBadP/Q==
# SIG # End signature block
