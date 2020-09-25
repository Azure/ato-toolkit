if ($IsWindows)
{
    [string] $MinimumRequiredVersion = "2.10.0"
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
        Set-Location "./tools/az-cli/"
        Write-Output "Installing AZ CLI. Please wait a minute or three.";
        Write-Output "$(Get-Date)";
        Start-Process msiexec.exe -Wait -Verb runAs -ArgumentList '/I azure-cli.msi /quiet /L*V AZ-install-log.log'
        Write-Output "$(Get-Date)";
        Write-Output "Azure CLI install complete"
        Write-Output ""
        $AzureCli = Get-ItemPropertyValue 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Microsoft Azure CLI' 'version'
        Write-Output "We have Azure CLI version $AzureCli installed!"
        Set-Location "../../"

        $env:Path += "C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\wbin;"
    }
}







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIyNySel//MW0f2iU5dlOStxS
# 6lmgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBTRTYWj8/t8DOU/E+q2+q+7/fL6LjANBgkqhkiG
# 9w0BAQEFAASCAgAQxwG5hmYtDiocmRouhxkgbpVb47rr4LAh2d455HU6TFrbxwkw
# DvQ20bkyKGGSvhMn9AI76SQz+VC8jOkqf9UNbznCmdlOJ/af/rGMWahmIYH/TpZ4
# ZzENO3BzjQ1kv+nhR7KUnj3EqIct/RDW7ix3bL9sEokmeFGiF9smCbtesmbvJ/zr
# 1i3yfqNUx5nssC1pRlFYt+d0uEKYWOImZqu9qnmufzyaJnO07MQt5BfUjpZ+LLPL
# EtZ1KJY1VqcND89lsH/g9k5aS8W2/IKHRPw5oBeqOIz2lw51ITTQqOZKdYNiRsKn
# aAO8Ny1miDodUEAmpoPwfip+NUaA+kuv5UfwX4x/+oV5CzFAfC1H6HJDA7Bxecu6
# PUGWTcKRu7FrFdjbqTGgrnVyDXYKpFLKGa6qEEo3/MDPlGS+0o0CV6aZ54wx+jRO
# xSno254PLGe8TcAcir1KfbcIW45mBkR2xX73j/vaBCi16FWrnRE542pAr4VtT7z3
# 6PRe8XD+X81/mUGb/tC45G0BZPHKzBuv/ERonFczle0LJdk5KPXVon/6tVR5M2gA
# bV2rVhjdAOCuNe2qDFL9KVkTTtUOMjNtapOmDJcEhjauYYJilo8kqBWffG1vAKxl
# 7xUb5rWQulJMcUCVNhDuekg5fqVnGFuV2gz0kdCY0iPzWwll8csX6Dr9wQ==
# SIG # End signature block
