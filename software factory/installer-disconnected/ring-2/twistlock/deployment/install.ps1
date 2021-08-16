param (
    [string] $VariableFile = ".\deployment.vars.ps1"
)

if (-not (Test-Path $VariableFile))
{
    Throw "Variable file, $VariableFile, not found.  Please double check the path"
    exit
}

Get-Command Log-Information -ErrorAction SilentlyContinue | Out-Null

New-Item -Path "./output" -ItemType "directory"
Set-LogFile -LogFile "./output/twistlockdeployment.log"

$VariableFile = Get-ChildItem $VariableFile
. $VariableFile

./do-deployment.ps1 @DepArgs | Tee-Object -FilePath ./output/do-twistlock.txt




# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjhL3uur0IVGXTJoNxqkkZgg5
# fjOgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBRk9YdNXsxqSRMjLOWUatdUY8kUpzANBgkqhkiG
# 9w0BAQEFAASCAgBjkQyPBWXbYrAZSh8GI1M4P/FlFEclICCc+IuM6/e2Y/PM9HXx
# 29eIcSBdQjNC/GE19gQ3qEaabduEQKDPZo5iyWEtYNmstTdO1Ch+LWWRZVD079K7
# VrgPMloh8NKM4+OHaiOa88WPGMYOtyU4oFJDhQJFPbEUMet+EzHQD2IywFj4vpGx
# L8moOOdTjNe5eQ1kRuW28QbtDdEopfPkaSwiiboo7YQ+4s9TsZvu0R4Rkaa2Kyaz
# R1320ixJPI2Q/gWppNlMQgISSHYIItxnn2sR4sJSy+BViF6U6siEiRO7HPDvsO92
# 7cH6fAUtOf03Dj/l6W9rnKb/xOzPdNzdiLHAsvo4m3YXAi2AaMdn+KFeV+2QOzYS
# OczUqMI0HQvi+aRvrWAxKbhCpyge+wg9bKzuNa+s0QUIVQhi3k8ucsF9tIsgRfSk
# qz5+fx2PfdAMT4x9FMHTmCfXtT+8iYtINSELUOH7XdxveGYQzeHtPXF8SeUsWTNQ
# vzCBQATWmlCE4rbIRBcRaojpT4tclNvSWnAQy4RxgWkNrYsR371I+OwIAYmKFiMf
# aPqxtQCCA7R/QAJQEEKbOIztcFVsISZ9oP/ce3/taca0RktXfFMPUvWDEfMVST3v
# VPD9Q113Akb6BTvMt2w6Uzwn7BO2yQv2X8grAuPyZxrh9F3YiyRxwSVCoA==
# SIG # End signature block
