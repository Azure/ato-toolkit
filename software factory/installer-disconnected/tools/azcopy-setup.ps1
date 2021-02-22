if ($IsWindows)
{
    $AzCopyPath = "./tools/az-cli/azure-copy.zip"
    $AzCopyLocalPath = "~/.azcopy/"
    if (-not (Test-Path $AzCopyLocalPath))
    {
        Log-Information "Az Copy doesn't exist"
        New-Item -path $AzCopyLocalPath -ItemType "directory" | Out-Null
        Log-Information "Unzipping Az Copy"
        Expand-Archive $AzCopyPath ./ -Force -PassThru | out-null
        Log-Information "Copying Az Copy into place"
        Copy-Item ./*/azcopy.exe $AzCopyLocalPath | out-null
    }
    else
    {
        # need to add version check in the future or just always replace...
        Log-Information "Skipping install of Az Copy. It already exists."
    }
}
elseif ($IsMacOS)
{
    $AzCopyLocalPath = "~/.azcopy/"
    if (-not (Test-Path $AzCopyLocalPath))
    {
        throw "az copy has not yet been configured for macos"
    }
}
elseif ($IsLinux)
{
    throw "az copy has not yet been configured for linux"
}






# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUVWc4E/cPTIkdEoNTOgfzD0om
# ZHKgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBRmlnDKZIHevOya2gH9Dln10Aq4WDANBgkqhkiG
# 9w0BAQEFAASCAgBtH9ssKKoPvQ0lKHszJtFlOjnE3J0T3UloLaNpHwIPJpecoSlQ
# a4vObY3kYhSV4pAc1QPx7VcQz5Mva4kpXd/XWRKkckJRAep9KrAWcbFgAL0sSiO8
# ZHFRMYM4uSzbLfdWXC6BfZxh2/3oneavhOnMxHsORYmmjKjVoF+s45S1DSuzbhV1
# wJcnOSfnpBBJ5ucVa762rZwjE6NWq7EhLbaLvxCgTR4YX4jUOrDWIXMDoFU4EohB
# G1ZuNRzo6GzIKBd/QoRhbaBzl4GyukRBcaj1ZoY0wCxd+WPopmqciw4wZSExfZjp
# HM947QKHROUEMhPAJxb5oJJUzyp09EK9AVpOunHSobRQdlxGApfnAj7sNv4nsZPK
# PY7Qz6s5Jdt4Y9gE2j6PayfDQVac1w14T0TUIAzQXxsnQT2Bj9yjGZ9AYDvalmW6
# Eb18/mMdDScDNFNbZ0OOGXvxbyZbmVRI7lG0+uJMoMCcCru8cr/nDvEH58YtJ/d9
# 1NHPe4HbQL00B8F+LkOwP6c8HeS/1/qNMWlU+6cRLwhSyXM/FZwQ8oU5V1hOLorq
# 4KqE+HQwYIGrzXODmADVhfEVnyQ3oKs9+0c1JN26BMFSEvzqbTkYJTdmKzpt8/Pw
# j3xCHVZk6xwMSH6uPpydzb/6PT80gK1M4C5dyhECN4nhbTH1dmMtc5J5dg==
# SIG # End signature block
