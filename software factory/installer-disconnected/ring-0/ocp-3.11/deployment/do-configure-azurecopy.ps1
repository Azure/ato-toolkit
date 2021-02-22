param (
    [parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [parameter(Mandatory=$true)] [string] $AzCopyPath
)

Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

if ($DeploymentType -eq [DeploymentType]::DisconnectedStack -or $DeploymentType -eq [DeploymentType]::Disconnected)
{
    if ($IsWindows)
    {
        $AzCopyLocalPath = "~/.azcopy/"
        if (-not (Test-Path $AzCopyLocalPath))
        {
            Log-Information "Az Copy doesn't exist"
            New-Item -path $AzCopyLocalPath -ItemType "directory" | Out-Null
            Log-Information "Unzipping Az Copy"
            Expand-Archive $AzCopyPath ./ -Force -PassThru
            Log-Information "Copying Az Copy into place"
            Copy-Item ./*/azcopy.exe $AzCopyLocalPath
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
}

Log-Footer -ScriptName $MyInvocation.MyCommand







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUuq/Z7SYYhvWpQQgrAj7jgnR8
# YY2gggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBRoB5yP56r5cWwkZIleEifEXUr3szANBgkqhkiG
# 9w0BAQEFAASCAgAdtH+5KclT8ZmSoRhCjM6q+oswuu2l86iwmZ75rB7cTh5trHzK
# PYe5UDKkiMS1nxzDKE/uJIRU5K+J6jElO07cyr0ehXyODXGKGgxGRLRXBMNC8oDM
# SFbTJeg8wAQnYtL3mBS+YQXL2e2ZIWrEFJhnRqGFnq4YHUmQmP6g8itgM9Risnny
# l3WgWKwPzOpmg5Cd7+5GfY8sw7uXEHJptfwJDaTdtOBR7GOkgG+Mua2Htq6gruT6
# +H9jBtrBtX3ebFrhER+XLUoF0d7wAFsiH7MY8X/IGOzB1ZDYIqYWM7QwJHtLmFLV
# MAmeS/LbUSGXd/7/0aAmEUjfAj7LP7Gd2CgKj58LrmVEuKuVxfzqBTqY/irKhS5H
# RVC1pHDD4s8uMgtRQy9Zx/h3JCB0ZjquJdm3xbT4rWWh5hLHAHYblAP9vRZN4KLT
# pvnFh7PG0RGnsQhzbDZXDM1nlwoZnbjl5r1df+GO/H/u9LrHxqFF5wyHI6b7OhXR
# Tk0q4NzrxySX+UucQegbdfE1AOI0vN/0FuORvgJF9jUMFStNUvA5Yl8ZkKS1Z9KB
# lXgzbSn959GnwvqZtW2YLuYerIW35Q8njoY9TDBonoDbDfX4PDhBsfDlfVTkevIe
# 6Lj9Swqv7QZha1Ta39abwHscNbzb6fZQfjd51PDhg/dXXbOQZTqEPiek3g==
# SIG # End signature block
