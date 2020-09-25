param (
    [bool] $GenerateSshKey = $false,
    [string] $SshKey = "cfs",
    [bool] $UseBastionSshKey = $false,
    [string] $BastionSshKey = "cloudfit-linux-bastion"
)

Write-Output ""
Write-Output "Create the folders needed"
New-Item -path ~\.ssh\ -ItemType "directory" -Force
New-Item -path ~\.ssh\authorized_keys\ -ItemType "directory" -Force

$SshKeyPath=".\certs"
try {
    Write-Output ""
    if ($GenerateSshKey)
    {
        $GeneratedPath="generated-$((Get-Date).ToString(“yyyyMMdd.HHMM”))"
        $SshKeyPath= "./certs/$GeneratedPath"
        New-Item -path $SshKeyPath -ItemType "directory" -Force
        if ($PSVersionTable.PSVersion.Major -ge "6")
        {
            if ($IsWindows)
            {
                Write-Output "windows"
                ssh-keygen -f "$SshKeyPath/$SshKey" -t rsa -P """"
            }
            elseif ($IsMacOS) {
                Write-Output "macOS"
                ssh-keygen -f "$SshKeyPath/$SshKey" -t rsa -P """"
            }
            elseif ($IsLinux) {
                Write-Output "linux"
                Write-Error "not implemented"
                throw
            }
            else {
                Write-Error "you're not supported. also, how did you get here?"
                throw
            }
        }
        else {
            Write-Error "you're not supported"
            throw
        }
    }

    if ((Test-Path $SshKeyPath\$SshKey) -and (Test-Path $SshKeyPath\$SshKey.pub))
    {
        Write-Output "Copy the cfs key"
        Copy-Item $SshKeyPath\$SshKey ~\.ssh\authorized_keys\
        Write-Output "Copy the $SshKey.pub"
        Copy-Item $SshKeyPath\$SshKey.pub ~\.ssh\
    }
    else 
    {
        throw "Unable to find $SshKeyPath\$SshKey"    
    }


    if ($UseBastionSshKey)
    {
        Write-Output ""
        Write-Output "Copy the $BastionSshKey key"
        if ((Test-Path ".\certs\$BastionSshKey"))
        {
            Copy-Item ".\certs\$BastionSshKey" ~\.ssh\authorized_keys\
        }
        else 
        {
            throw "Cannot find the bastion key, $BastionSshKey"
        }
        
    }
} catch {
    Write-Output $_
}







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUUQ25lNgtJpRDJxwb3X7XoYxN
# KrSgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBQz2V8pLszrkjIzSfqCtQva3LN5yDANBgkqhkiG
# 9w0BAQEFAASCAgB1N6RpfDDfWgiFHeU5aZm0ybm2ZzJdKqHgP22bKQMgdds2uIZy
# 8ucoOuYtbrava2ZMf0naKF8Q/5eD74fydVl/Vh7p2QP//+2EYW3mnkGvkRKa74GT
# TTECn6erpvvMF2Nhl6GCTRv2OnI9Ob3t6n6W0GA0vruv7kIOoBT+NyWFkHRyZOIt
# 4HGik1GZJgyGaM5X8deGbyOb5/wvsao+9ukOrzQlloRraiprRghYaczXBAcaWav8
# VU+PXhhpVl0xOwB+Vs+w5NBWsJnzU5Pt7r1g/cGcW1WF5kyGhmGXJ6mPW1Z4lAX8
# /bpz1ytx52rPTlPr8hOQfgqfqTz45ejCB9lbdwt7Rxiu4Yzox6l8Aqpap37zCaFG
# 49adQZqSYDKrHnzBYcjx/s43lNDKOwDqLqSM0Wcz0LQ3MgzCDjJ8IPoAPxWsHoY6
# nYqq9AvMY3QzL29JKr73EnB6/+e04qIkLoZkOytRnjhpb/cpup91C2VjzkFpVbYr
# FP+rIcwQZWAgbBnqRkLnslKt7wtqMjElxcF+0jwyFyJoBp7zdHDCF2Wt5wec7A1c
# lzeF8Hl+26A3Wbx+Sd5oXZtR577qHJDgzASkD8V8ex0YqmfYAAjPXF+gKSc68OuH
# Y1CqMmO2fCjdmGWGB/bVLfLYcmUnbzJfzTt5bMunUA0UXRohUBOm+AT2tA==
# SIG # End signature block
