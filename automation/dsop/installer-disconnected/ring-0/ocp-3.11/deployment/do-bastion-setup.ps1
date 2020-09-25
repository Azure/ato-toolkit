param (
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $BastionMachineName,
    [string] $RawSshKey = $(Get-Content -path "./certs/$SshKey" -raw)
)

$scriptsPath = "$($(Get-Location).Path)/Ring-0/extra-scripts"
$rawSshScriptPath = "$scriptsPath/rawssh.sh"
if (Test-Path $rawSshScriptPath)
{
    Remove-Item $rawSshScriptPath -Force -Confirm:$false
}

New-Item -Path $rawSshScriptPath -ItemType file -Value @"
runuser -l ocpadmin -c "cat >> ~/.ssh/id_rsa << EOF
$RawSshKey
EOF"
runuser -l ocpadmin -c "chmod 600 ~/.ssh/id_rsa*"
"@
$jsonFile = New-Base64EncodedJson -ScriptPath $scriptsPath -ScriptFileName "rawssh.sh"

New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $BastionMachineName -JsonFile $jsonFile







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4lV7f4izoIv2Jbr4FkUflgHa
# OaigggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBS/7VnFEKOufHKOohC1h4dz3ODOizANBgkqhkiG
# 9w0BAQEFAASCAgA5cwmhoP0ILMahRzDupl7oJtn0shOIWgx3QM+jUkmYCyvVBsdT
# m2Q4jDr2W3GuA/ULUoc7EYrPUdVkfSrCVd8BpiYYAHCwHc7ZOx2G2awAIG21NM16
# yKs+ThUlBKMDoGgGvVG5EVvq9AxdDTh27BuDV3K3suQkAggIoySUafFC7qWzE0BP
# O3ZqBgSJon7kVdzkfyiHUu/7Z0BTMxAgFrEYw99rl+7xYHMEXZevqGQ9g49E/AL1
# REgQApnSQwr3iz00lPri7UFUVEsWVi6mlATW4oAYjnWGuyFSSe+LXSBnrsTtPSdd
# IIwztZzwzVU5JxtqszSqyxwk2iak5oo2vPxVe+BOnOf+r5I4zdyPII+klwd0MvO2
# JIIavON7bhS73MsDsft053S/dqmI93asCFyHrlqR94gepDFXuyjcZezYogNIX2uF
# D3tFfvMh0tpjlZ5ZPfrbHGk3quZ9qImfp9ayHkuqT7n5AseRMgC8UfS7Zi6YnkMR
# KQfURFljujHB0ZBVQmQCqkLwTg3v6YFV0W2cPtZh20mbmlqjgJP0N3B3CPyQBcdO
# cfSYibvbj+B5zbfLw9fZjLfsvxSBikSpp/FGZBJ9EDAv8v1HV8WX9/SDo5BPIVmd
# Y4MjnyHbXy7N7x4oIO+Z11Onv+WjB9H4OLwd6h6RNt+FIYm0A+rSmYuoGA==
# SIG # End signature block
