param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [string] $TenantId,
    [Parameter(Mandatory=$true)] [string] $ClusterType,
    [Parameter(Mandatory=$true)] [string] $AppName,
    [Parameter(Mandatory=$true)] [string] $AppUrl,
    [Parameter(Mandatory=$true)] [string] $ContainerRegistry,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $BastionMachineName,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$false)] [string] $BastionProxyUsername,
    [Parameter(Mandatory=$false)] [string] $BastionProxyIp,
    [Parameter(Mandatory=$false)] [string] $UseRegistryCredential,
    [Parameter(Mandatory=$false)] [string] $RegistryUsername,
    [Parameter(Mandatory=$false)] [string] $RegistryUserEmail
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
            "name": "repo",
            "source": {
                "value": "$AppName"
            }
        },
        {
            "name": "tag",
            "source": {
                "value": "latest"
            }
        },
        {
            "name": "applicationuri",
            "source": {
                "value": "$AppUrl"
            }
        },
        {
            "name": "useregistrycredential",
            "source": {
                "value": "$($UseRegistryCredential.ToString())"
            }
        },
        {
            "name": "registryusername",
            "source": {
                "value": "$RegistryUsername"
            }
        },
        {
            "name": "registryuseremail",
            "source": {
                "value": "$RegistryUserEmail"
            }
        }    
    ]
}
"@

if ($DeploymentType -eq [DeploymentType]::Disconnected)
{
    $IsInsecureRegistry = $true
}

$IsInsecureRegistry = $true

Log-Information "Logging in to az cli for tenant [$TenantId] and subscription [$SubscriptionId]"
Confirm-DsopAzLogin `
    -TenantId $TenantId `
    -SubscriptionId $SubscriptionId `
    -DeploymentType $DeploymentType

Log-Information "Installing Nessus via CNAB bundle."
Log-Information "This will take some time to deploy with no visual output until process is complete."
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUujQl+DqjXgsIMMZIGcztXFjn
# 7S6gggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBQHV9+DXab7DUo8YYNxRpN0OHYCGzANBgkqhkiG
# 9w0BAQEFAASCAgAI0xA+5HaHlVmWcXOCNnILPJB9wAQsVOJHFHFDM9nEV1iOf057
# TwjHryaGuSu2N/3GH59580uoBv5NPgTetVJDrk8pFkI5Wyy+54cYPzGZ2uamDR1s
# IZHeBzdXeNEPTgpagjZlyT2q/W3wTEM3c+mr57PdqCmsQ4uspYZ6K9ZREkYB6MDZ
# 3HS4/vdNtp3EnR0pI+pz+v8x4MnWwCOmgOMlFdQ6vrTImkk6Nv76tnyYaTmpYk0x
# veaVXxeadHocUxrW3wiwOcEFGH9fDAbv6pk3+DuZW0yoP40ZlqNjjQjVO82ZJir1
# nddg7WJWbsMRMAJwuXIcx5GR5tULCOvwvvRf0XBglq/lfSuPddOneRiFrlVNFmmm
# +2D/c3GNoHQdtxmnO8+53772+3kgtpQVSpPywn85F4vaUmBQ2InoYdx9X1QhZF+L
# pBtAttoBy44lDtSFlx6zuKy6wjvGJMogLsAB2ds9s2y2edm/r2eErsMg+GOJZ28V
# khiJm40HWFeKUwKtSd9onNj3EPe5lOLwwqWsAqsbEQIhxUfkMvQtnBYm31bISYSI
# 5P3AjgLMteN4nCAMiHfZfKjtnsxpbS10nMknIpOq7NQrX1txW38I7vpfShQ7swOy
# fxfe+XwIWJcuMW/LHN2dBY0tqRoku+DHTmgD53nh5Ujp/z2SgtHxgjsqTQ==
# SIG # End signature block
