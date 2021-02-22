param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $TenantId,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [string] $ClusterType,
    [Parameter(Mandatory=$true)] [string] $Namespace,
    [Parameter(Mandatory=$true)] [string] $AppName,
    [Parameter(Mandatory=$true)] [string] $AppUrl,
    [Parameter(Mandatory=$true)] [string] $Backend,
    [Parameter(Mandatory=$true)] [string] $ContainerRegistry,
    [Parameter(Mandatory=$true)] [bool] $PrivRegCreds,
    [Parameter(Mandatory=$true)] [string] $PrivRegUn,
    [Parameter(Mandatory=$true)] [string] $PrivRegPw,
    [Parameter(Mandatory=$true)] [string] $PrivRegEmail,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $BastionMachineName,
    [Parameter(Mandatory=$false)] [string] $StorageClass,
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
                "value": "$Namespace"
            }
        },
        {
            "name": "registryurl",
            "source": {
                "value": "$ContainerRegistry"
            }
        },
        {
            "name": "repo",
            "source": {
                "value": "$AppName"
            }
        },
        {
            "name": "anchoretag",
            "source": {
                "value": "latest"
            }
        },
        {
            "name": "redistag",
            "source": {
                "value": "latest"
            }
        },
        {
            "name": "postgrestag",
            "source": {
                "value": "latest"
            }
        },
        {
            "name": "useprivateregcreds",
            "source": {
                "value": "$PrivRegCreds"
            }
        },
        {
            "name": "privregun",
            "source": {
                "value": "$PrivRegUn"
            }
        },
        {
            "name": "privregpw",
            "source": {
                "value": "$PrivRegPw"
            }
        },
        {
            "name": "privregmail",
            "source": {
                "value": "$PrivRegEmail"
            }
        },
        {
            "name": "isenterprise",
            "source": {
                "value": "false"
            }
        },
        {
            "name": "deploysql",
            "source": {
                "value": "false"
            }
        },
        {
            "name": "sqlpassword",
            "source": {
                "value": "defaultPasswordSQL"
            }
        },
        {
            "name": "sqlurl",
            "source": {
                "value": "postgres-svc"
            }
        },
        {
            "name": "deployredis",
            "source": {
                "value": "false"
            }
        },
        {
            "name": "applicationurl",
            "source": {
                "value": "$AppUrl"
            }
        },
        {
            "name": "dbclaimsize",
            "source": {
                "value": "50Gi"
            }
        },
        {
            "name": "deploymentartifacts",
            "source": {
                "value": "anchore-artifacts"
            }
        }
    ]
}
"@

$backendParameterJson = @"
{
    "name": "myparams",
    "parameters": [
        {
            "name": "namespace",
            "source": {
                "value": "$Namespace"
            }
        },
        {
            "name": "registryurl",
            "source": {
                "value": "$ContainerRegistry"
            }
        },
        {
            "name": "repo",
            "source": {
                "value": "$AppName-$Backend/postgres"
            }
        },
        {
            "name": "tag",
            "source": {
                "value": "latest"
            }
        },
        {
            "name": "useprivateregcreds",
            "source": {
                "value": "$PrivRegCreds"
            }
        },
        {
            "name": "privregun",
            "source": {
                "value": "$PrivRegUn"
            }
        },
        {
            "name": "privregpw",
            "source": {
                "value": "$PrivRegPw"
            }
        },
        {
            "name": "privregmail",
            "source": {
                "value": "$PrivRegEmail"
            }
        },
        {
            "name": "deploymentartifacts",
            "source": {
                "value": "postgres-artifacts"
            }
        },
        {
            "name": "applicationurl",
            "source": {
                "value": "$AppUrl"
            }
        },
        {
            "name": "storageclass",
            "source": {
                "value": "$StorageClass"
            }
        },
        {
            "name": "dbclaimsize",
            "source": {
                "value": "25Gi"
            }
        }
    ]
}
"@

if ($DeploymentType -eq [DeploymentType]::Disconnected)
{
    $IsInsecureRegistry = $true
}

#$IsInsecureRegistry = $true

Log-Information "Logging in to az cli for tenant [$TenantId] and subscription [$SubscriptionId]"
Confirm-DsopAzLogin `
    -TenantId $TenantId `
    -SubscriptionId $SubscriptionId `
    -DeploymentType $DeploymentType

Install-PorterFromBastion `
    -DeploymentType $DeploymentType `
    -AppName $AppName-$Backend `
    -ContainerRegistry $ContainerRegistry `
    -ResourceGroup $ResourceGroup `
    -BastionMachineName $BastionMachineName `
    -AdminUsername $AdminUsername `
    -SshKey $SshKey `
    -BastionProxyUsername $BastionProxyUsername `
    -BastionProxyIp $BastionProxyIp `
    -ParameterJson $backendParameterJson `
    -BundlePath "$($(Get-Location).Path)/$AppName-$Backend.tgz" `
    -IsInsecureRegistry:$IsInsecureRegistry
    
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU1Wg821D7pYng2cIIKVH8WDX8
# FqugggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBQFllEa4op10ZFL3lRNuiniLa2NczANBgkqhkiG
# 9w0BAQEFAASCAgAuPmq8mHZ1KsyQcaRQ6ye/40LcJinJIuHTg+IlMYgIYgzJW9fm
# +Rk0R/nyRRFI8JO3zigdAJa2lDjb9TjXJ1TkGgLcT1zt97WXNVcAbgHE+LD+VTYj
# YqHzzYiWZO07qgszfu95Sr3uwgCJcup/zHzhkuEN5BBDp2EVQ9hbRTX8Z0SBm4oA
# ZA4yUQLKXGGNELJrTGpCwxraoJ7GK+j46vKxLUcooSEOWUw34DqOw+x8WX5Qvfyx
# +3GWEASrQUpXHJ01UTqiBJOR6yYQWFT89LhSU1L6r2t4JeWbX7/hzudUeVmu7RtO
# f7Fh7PYQyzriUuxOzmNIJpDBl2d1K7MTL2havKCrRQrPgtS2VK2/FaI75St/rKag
# 6M1O/csQkN4uHYzpV7j+yQgD3JpHpEjkBTD5BQCwS8YJcCDlLSoQPd4gX5kbFKWg
# AK8u1L6JWIoce0dZotz1N6ZclxkFrkfTdxs5buQLRKMvmNMJ0jH9TlS9DDeHC7fj
# D+3++wqL0nR0sYWFdUYK+pm7ofhZVHQDKyfdrJGaRv8B00pMNCT+jfRdk41XABP/
# yXmhj/7AZlvfvE4//L+xg6mSvC11YxiTXv7z0ePSlN+t8JTeRqL3fvkIlp4doOu0
# WaTyNUxl7h6gthNSqhwEnPsCiI11bkAJBQP/3USif11oP/6+qNgUamD1aQ==
# SIG # End signature block
