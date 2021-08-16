param (
    [Parameter(Mandatory=$true)] [string] $PowershellCorePath
)

[string] $MinimumRequiredVersion = "2.0.76"
[bool] $InstallRequired = $false
Write-Output "Checking installed Azure CLI version"
if (Test-Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Microsoft Azure CLI")
{
    $installedVersion = (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Microsoft Azure CLI").Version
    if ($installedVersion -ge $MinimumRequiredVersion)
    {
        Write-Output "Azure CLI version $installedVersion found and is above required version $MinimumRequiredVersion"
        Write-Output "Continuing installation."
    }
    else
    {
        $InstallRequired = $true
        Write-Output "Found existing installtion, but installed version [$installedVersion] is below minimum required version [$MinimumRequiredVersion]"
        Write-Output "Upgrading existing installation."
    }
}
else
{
    $InstallRequired = $true
    Write-Output "No existing Azure CLI instance found.  Installing."
}

if ($InstallRequired)
{
    Set-Location "./artifacts/"
    Write-Output "Installing AZ CLI. Please wait a minute or three.";
    Write-Output "$(Get-Date)";
    Start-Process msiexec.exe -Wait -Verb runAs -ArgumentList '/I azure-cli.msi /quiet /L*V AZ-install-log.log'
    Write-Output "$(Get-Date)";
    Write-Output "Azure CLI install complete"
    Write-Output ""
    Write-Output "Waiting for it to be ready"
    Start-Sleep -Seconds 20
    Write-Output ""
    Write-Output "This just takes time"
    Start-Sleep -Seconds 20
    Write-Output ""
    Write-Output "We should about be ready now"
    Start-Sleep -Seconds 20
    $AzureCli = Get-ItemPropertyValue 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Microsoft Azure CLI' 'version'
    Write-Output "We have Azure CLI version $AzureCli installed!"
}







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqB/5s5UXqHJ3PcYrfQ5E00fk
# V3CgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBQe6XP6G4z7TucpkKMjEqnGYrkonDANBgkqhkiG
# 9w0BAQEFAASCAgAGXCHHp43ynvPQ4bgp5RyWHbztsMRDfP5oS4q2zmXJ8s4ZcuhK
# IuWs1RzIniOSxiAQJo3FFckQjKEuMX+hfvNV5vhbftK1q5HIZP7DjEQW15+hB+Qz
# udsKsuw6O4cnSK96iQPChDqYCflN05pM2+DFZHRZt673D8jljYZGtPxGeDcDB/v8
# JuWc7TSyp66rRt0wj1Ni7Jjxna4VT64ka220hBJokCdcyj7u++5lPbICQW+1Tm0U
# GPDLEIza2D0ubX8EEgYe4OLmASta1FS1Wx2d8e6q3i+469Iua4QjW+SJVGLWReJg
# aYTcrsT7AwYCTJOUcvwZJGEewvo/FBuusBEKBjbO+yd1Vscf/yZ7oJBeCJg1cKeu
# TVvuEfXlscz1bUPNFsKdwz/xWPXnwV9vIJ+WolKf/0tA6jGoFbNMq5b7jS8GuTfo
# LiHMji6SFlWZGyw1AgqjLsXVAku2nfFtSJ4uQatzZrEPxHZrqxFt5vMhVTpwpqEt
# jF9VjoicNZUHuGMI9wOjomxF4dApC3BZYS13iSI1xaos+6ctwg/ns6czW/OrySq6
# AgNqwsWC+jmWm3a1dqmPQ+13s3VluBe+hczqeI/a9kXm+NhzVHXbjBJJG8tsLtAR
# mVV9iZhrMANbjtJTTiRn5sLtsfX5iqcX/nzseWfBsSSwEyh4XzgNqJ2kkA==
# SIG # End signature block
