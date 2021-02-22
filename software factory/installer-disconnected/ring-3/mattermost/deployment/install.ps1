param (
    [ValidateNotNullOrEmpty()]
    [string] $VariableFile = ".\deployment.vars.ps1"
)
$CommonLibraryVersionRequirement = "0.0.1"


if (-not (Test-Path $VariableFile))
{
    Throw "Variable file, $VariableFile, not found.  Please double check the path"
    exit
}

Get-Command Log-Information -ErrorAction SilentlyContinue | Out-Null

$installedModule = Get-Module -Name CloudFit.Dsop.Common
if ($installedModule)
{
    Write-Output "Found CloudFit.Dsop.Common module. Checking version requirements."
    if ($installedModule.Version -ge $CommonLibraryVersionRequirement)
    {
        Write-Output "Found version $($installedModule.Version)"
    }
    else
    {
        throw "$($installedModule.Version) is less than minimum required version: $CommandLibraryVersionRequirement"
    }
}
else
{
    throw "Cannot find CloudFit.Dsop.Common library.  Cannot continue."
}

New-Item -Path "./output" -ItemType "directory"
Set-LogFile -LogFile "./output/mattermostdeployment.log"

$VariableFile = Get-ChildItem $VariableFile
Log-Information "Loading variable file, $VariableFile"
. $VariableFile

Log-Information "Pre install checks complete. Running deployment."
./do-deployment.ps1 @DepArgs | Tee-Object -FilePath ./output/do-mattermost.txt







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUGXt1gbXv7ZENUvYL/gMIoHB0
# 2QygggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBSiuQfGgU9G8n3VOrrQO7l7swGLTjANBgkqhkiG
# 9w0BAQEFAASCAgBwBsY1QHnCK2L7uIYUpvkl0OSAfOQPlGBDdtryjysvkn9pzxBO
# OrdvxpI8M+aX4RtEaF/B5A4uXXNUESRntsh/x7/lFnfwFshrb/EN/BB3H8P9kJGG
# NTsbjFQ5FV5xynwc6AIS+pQvI+qfbVFq8SBtf6M3U/1M2CDK7hnw2W7y6o/22M8+
# yVyme8CzRVJqjO1Kq22KEnSJJ5svoAcaK6HGIl2KxSHg6Ob/wv2tBxbalpcx3SRn
# gj7WgVMZFi2XZL7T5rjAqjIdIrBx1aEOGPJUQMfQjeeKRrUzFW/ezt/eJyGUDsXu
# AWhfsxT/aTuCVSo7zmLs1SxKCZmzFCzf9RZ4gzzAQMTj82ROIgoS7kHyQfBqBn9N
# EQi7g/uV7QweyU+nRko6wTe2Rw+g26sazi5ZrUhQLgnm/9IymtfcabxDwBgoADv0
# VqsGwUUEvUuIOUnOSYb5kPfZJ30I47tmlTuJfwhN6kN54dKdT7QkNKRuKJ3kGCh5
# uf7zyLlbrbwq6/5R5cQixjXgsQ/mTozo3axYqMF+M/szt0nwi+LfW4wxSR5/UFgC
# vEMhFTQ1rwBSjjBI6fW0C+pspwCKCMoG0iuFgrQPfGVFLjNlAn25cKifsXVnqY7o
# 5OLdehW6wYJ61DA7Kw4te4j0nmLR3iGzqd+8Gg/lVRDGucao5cWnOPSvUg==
# SIG # End signature block
