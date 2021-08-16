param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $TenantId,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [string] $ClusterType,
    [Parameter(Mandatory=$true)] [string] $AppName,
    [Parameter(Mandatory=$true)] [string] $AppUrl,
    [Parameter(Mandatory=$true)] [string] $ContainerRegistry,
    [Parameter(Mandatory=$true)] [bool] $UsePrivateReg,
    [Parameter(Mandatory=$true)] [string] $PrivateRegUn,
    [Parameter(Mandatory=$true)] [string] $PrivateRegPw,
    [Parameter(Mandatory=$true)] [string] $PrivateRegEmail,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $BastionMachineName,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$false)] [string] $BastionProxyUsername,
    [Parameter(Mandatory=$false)] [string] $BastionProxyIp
)

$parameterJson = @"
{
    "name": "myparams",
    "parameters": [
        {
            "name": "namespace",
            "source": {
                "value": "$AppName"
            }
        },
        {
            "name": "registry",
            "source": {
                "value": "$ContainerRegistry"
            }
        },
        {
            "name": "sscrepo",
            "source": {
                "value": "$AppName"
            }
        },
        {
            "name": "ssctag",
            "source": {
                "value": "latest"
            }
        },
        {
            "name": "mysqlrepo",
            "source": {
                "value": "$AppName"
            }
        },
        {
            "name": "mysqltag",
            "source": {
                "value": "latest"
            }
        },
        {
            "name": "privreg",
            "source": {
                "value": "$UsePrivateReg"
            }
        },
        {
            "name": "regusername",
            "source": {
                "value": "$PrivateRegUn"
            }
        },
        {
            "name": "regpassword",
            "source": {
                "value": "$PrivateRegPw"
            }
        },
        {
            "name": "regemail",
            "source": {
                "value": "$PrivateRegEmail"
            }
        },
        {
            "name": "dbclaimsize",
            "source": {
                "value": "50Gi"
            }
        },
        {
            "name": "dbstorageclass",
            "source": {
                "value": "glusterfs-storage"
            }
        },
        {
            "name": "applicationuri",
            "source": {
                "value": "$AppUrl"
            }
        },
        {
            "name": "ssclicensepath",
            "source": {
                "value": "/home/ocpadmin/fortify.license"
            }
        }
    ]
}
"@

#
if ($DeploymentType -eq [DeploymentType]::Disconnected)
{
    $IsInsecureRegistry = $true
}
#

$IsInsecureRegistry = $true

Log-Information "Logging in to az cli for tenant [$TenantId] and subscription [$SubscriptionId]"
Confirm-DsopAzLogin `
    -TenantId $TenantId `
    -SubscriptionId $SubscriptionId `
    -DeploymentType $DeploymentType

Install-PorterFromBastion `
    -DeploymentType $DeploymentType `
    -AppName $AppName `
    -ContainerRegistry $ContainerRegistry `
    -ResourceGroup $ResourceGroup `
    -BastionMachineName $BastionMachineName `
    -AdminUsername $AdminUsername `
    -SshKey $SshKey `
    -BastionProxyUsername $BastionProxyUsername `
    -BastionProxyIp $BastionProxyIp `
    -ParameterJson $parameterJson `
    -BundlePath "$($(Get-Location).Path)/$AppName.tgz" `
    -IsInsecureRegistry:$IsInsecureRegistry






# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdEx1MlsgjxY4LdXQ0Xt+dIhm
# VIKgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBS1bGJpqxvpfI44Oa6w25GYBJLkMTANBgkqhkiG
# 9w0BAQEFAASCAgBdul5KOTHPNEWgOa7zoLh1Qtwmeu/c73WeCw70fkZzG9Zwmt4z
# QsYpDa48qs2SP1krP8xVFfLV5ZfCktdIw9qh5Nk0ibcGcDiGJ7EXOpAWnKLZqaAC
# GEQwAQwJl6GoEInugn3wk/38unTWdlCVfAwa5z7qG1UoT5gZ3lmdBtmAgyrdPUG+
# 9d9GzwZnU4u+liyObnL61pCZt+DNRYTtHj5+tMH/O0Z+GWQfofHnTjn/j2ubXuHk
# 91fDk7sRskQuc/C4eytzPkBqr2FnBQZ0wQzT2gHpg6q+hUbQTP0VZTEdzApwCqlH
# 99Yy2AunMii2msfPNJeCbrdjQGOUBfv+fDhe1fB7o16uuY9mADi8ICpXLI+9tJhC
# kE56mCBCabRID40Xm2lHwpDCz9jS5ozx88e8cDAfNDF5TLACzGtuveiVNTxxBNZI
# ZPyh9bGb3ixpSsqoYNwnkrFnhLQ8C4J5NGQRpMtUJwTyDTzu0QsEFFCP8y7OhNT3
# YCBwzJWP6RyZ/T50nb6vjT92nsXLn/N79xYo1jWA1ZUYQOwb8+/cFVKrGJlqCBpH
# H4Ner3BzTZOa/8WL+l957oMos8n0QJZIyCEyNOJH0xPDNXvE0qarH7UhtP4dyYyC
# Pa4whgoDhI+/GdUDV2bsrd/14jTNEEx0T20tC9bMGRrVfSVlIyXYdAIhJA==
# SIG # End signature block
