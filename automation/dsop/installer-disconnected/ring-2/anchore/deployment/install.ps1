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
Set-LogFile -LogFile "./output/anchoredeployment.log"

$VariableFile = Get-ChildItem $VariableFile
. $VariableFile

./do-deployment.ps1 @DepArgs | Tee-Object -FilePath ./output/do-anchore.txt




# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU5phOfdyROiPr8yiLA1cDE+8y
# dJmgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBRAFwN0rW2Ng9IhQggy+gB8AUsNuzANBgkqhkiG
# 9w0BAQEFAASCAgCIll4p8kXv1UpUzJkNznwABFhJ8ZpgVmncjc+oTLq5lY7TcZ6l
# 3C1IQE2djEvAFV4oZuiOSSQ68nnxVPWYJ7X5FjG+F9tpB+35AXsRyjoaOHN2ew+o
# GCZmqPEu14UPzocq2Q6Pd9ruHtfOx1cw5J1C/qmDizQTtGAJCItLV4CTn9iAHwMq
# TZDfTjPoR+yj63Xs0AcZgIs9EpzILTfI0XZcKjHnQQSz7x4h72sqY7ix+JrKLO2E
# 3Y2vVIzvBcZjpi03Qph7Q84956XOoUDVZ9DAUkALEVXARosNaq7QkpQIJKaGu6km
# YbzcOOyXzbtZttXhHSb9gHAkQukj2OnAoGUPQbxmUBfCw0SZQGephJ9aIPtmLeBN
# Rb4ZV9AXSqFCddDCxr7WYVk3siRHhWgUjT+6Zi1OP/nVZik9108dzLXLbpH75p7r
# FP2mDFyAjpOKD2PYCvFj1o9uUoKv/8+CJ5c5GGiZW7QLmx0Ni4Qb3X+GchGR+EnC
# ZGXjSBiq/oLyvl83hezKSAZW7fEFaUUdXRI84ONoq/6DDqKNxx6TRFVRLfKWjPXP
# /3nWsKCUJfFOD22msWsznkqueh+9rv1H1lf7/xvoqAva9zCyEwy+UZR5I8fgo7Bb
# 81aFaW+k/MboYZyWrVTw65AaxHL7FmtovpzXCMVtkISgL10wRNyMArhb9g==
# SIG # End signature block
