param ( [string] $Path = "./" )

$Files = Get-ChildItem -Path "$Path*.*.part" | Sort-Object -Property @{Expression={
    $ShortName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    $Extension = [System.IO.Path]::GetExtension($ShortName)
    if ($Extension -ne $null -and $Extension -ne '')
    {
        $Extension = $Extension.Substring(1)
    }
    [System.Convert]::ToInt32($Extension)
}}
$Writer = [System.IO.File]::OpenWrite("./artifact-out.zip")
foreach ($File in $Files)
{
    $Bytes = [System.IO.File]::ReadAllBytes($File)
    $Writer.Write($Bytes, 0, $Bytes.Length)
}
$Writer.Close()







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlafJB51kHcBpicec/e06OMw2
# seugggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBTj29CFIMlXaXYQtt8IeTNAy64GqTANBgkqhkiG
# 9w0BAQEFAASCAgAp2wCdpa5UCrxjo4kw/aT0ai7U6hPVRtsC1lR5j6oNjEWCVyW/
# Vte9J9iDSe4hP1eYIOM1Rxq/8nq4Sap36rBswR3+FaiTYw7lsc/r3k/Rf3uyrm5I
# aHbGALbSZBcVDJ3hB0UBN+fa8Ye1l+mEuEDnaiw67PQXB4eW0td+AvD7ixFXejID
# 9p/umbjpfBGiYdCdV2FEffqDSyMpgyBB/McZB+sZ5oHtbPiin1tWziR+77P6tAVB
# q7bINT1t4qR2AzH1gopHBca9DHMS5wZ1aKCpJaBkW6KJyMZTBfBkinVqSI040bnC
# 9AhQJiYryRsMe7R9a0+u8pcVeVWeSyDpodfB8abiCyhm5q4UWp87Sns1004Kuh+E
# ed73tZ4B2sGMeG/cYbHOq+xzOpF8ZZo8/MEpuihhcb9El22HqtAXOLec3W0yQkBu
# oFYEqC8rMuc6OD4EWRt/IgH/BcKXaM/IT/klblOPGrglpaO155wO1RxEQspTMnZE
# whxmpKEEBFN/DOl41gRe31qHBRXjt2Z1LrskUq8koUdQwpTL+eimWmWLUg7fbdXB
# DtEqacn2XPAjCLdVph6cgb6X6qGU9pvszFLzrle95r9MSQSmr0MMCQaAhZBGxX1p
# oBYMZveQpp0bpAPa6FEqJZxqPHznOHfkua0yhaRAcF6X7M1qSOLDo3hafg==
# SIG # End signature block
