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
Set-LogFile -LogFile "./output/fortifysscdeployment.log"

$VariableFile = Get-ChildItem $VariableFile
. $VariableFile

./do-deployment.ps1 @DepArgs
#./do-deployment.ps1 @DepArgs | Tee-Object -FilePath ./output/do-elastic.txt






# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUxVbEkRcfR7BxPk1Y4rmB6+wg
# ICegggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBTKAVuOggknNajqJ2TOVOgDwtIV5TANBgkqhkiG
# 9w0BAQEFAASCAgA7/wCyrv3T3UpUZkYWU/sf9YGkvqK2jIaXP9N2asdnvyfik6vY
# hP43KlDH6k7XirAcoV6vH/TQSIX9EtNdoFz2YgkdYfOv/V77YOqaF77cM/7TNbQo
# 2XCfhXculN8qssthMFSqOpM6H7Lkh78Au45MnnwGnXhqBp4XKwRF3+Tzw2z/jtWj
# 6dQUVeYHsa/QPrSl2N/5/r8xqf1vAXGbFiX5t0IrgMOEVu2u4SJ0OFmFsgXiEZ1R
# M49JIC1rXfT6Iqmrmezsyb5pdhOtpDtweTLBTj0zmRh/zNwIluwtwN9tjE2DtQTf
# 43JGC1zRcjpj9+iECEy9HlNotbWMkHjSSm/2VQ/iw5Y7RtIiuuYBTBndZL9SgP0E
# wRgqgtMm1CE4HkL0i+96ea6ZlxBbsJ3mUcIdcjkeprguWMDyWWOl0n5oGHO7+H/E
# cD8ngXgUnterCwHDyxAiLQ12CusJdwrTsTQ1ddg53LnNqOAiCv9S0Ff2dtEQOmIa
# /Bme/ta5F8KoPOhAm0e/IDgAPDmCoEk3KPgtv2gQm57ckW4nSiZUyIAdG1OPJL6A
# 7pQCvwuBQ/ba+IpqBiLlWpz3whEHg1FufiruV8I6UHol95dhcYseJ51iWGWTDymM
# vDQDYZEXaKMyx+dbDtpT6fqGGLLqKkwIatJBNddPHb6izBcHspVqAwX4tQ==
# SIG # End signature block
