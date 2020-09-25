param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $TenantId,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [string] $ClusterType,
    [Parameter(Mandatory=$true)] [string] $AppName,
    [Parameter(Mandatory=$true)] [string] $AppUrl,
    [Parameter(Mandatory=$true)] [string] $ConsoleUser,
    [Parameter(Mandatory=$true)] [string] $ContainerRegistry,
    [Parameter(Mandatory=$false)] [bool] $UsePrivateReg,
    [Parameter(Mandatory=$true)] [bool] $UseRegistryCredential,
    [Parameter(Mandatory=$true)] [string] $PrivateRegUn,
    [Parameter(Mandatory=$true)] [string] $PrivateRegPw,
    [Parameter(Mandatory=$true)] [string] $PrivateRegEmail,
    [Parameter(Mandatory=$false)] [string] $ConsoleTag,
    [Parameter(Mandatory=$false)] [string] $DefenderTag,
    [Parameter(Mandatory=$true)] [string] $TwistlockLicense,
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
            "name": "kubernetes",
            "source": {
                "value": "openshift"
            }
        },
        {
            "name": "namespace",
            "source": {
                "value": "$AppName"
            }
        },
        {
            "name": "useprivatereg",
            "source": {
                "value": "$($UsePrivateReg.ToString())"
            }
        },
        {
            "name": "useprivateregcreds",
            "source": {
                "value": "$($UseRegistryCredential.ToString())"
            }
        },
        {
            "name": "registryuri",
            "source": {
                "value": "$ContainerRegistry"
            }
        },
        {
            "name": "privregun",
            "source": {
                "value": "$PrivateRegUn"
            }
        },
        {
            "name": "privregpw",
            "source": {
                "value": "$PrivateRegPw"
            }
        },
        {
            "name": "privregmail",
            "source": {
                "value": "$PrivateRegEmail"
            }
        },
        {
            "name": "consoletag",
            "source": {
                "value": "$ConsoleTag"
            }
        },
        {
            "name": "defendertag",
            "source": {
                "value": "$DefenderTag"
            }
        },
        {
            "name": "deploymentos",
            "source": {
                "value": "linux"
            }
        },
        {
            "name": "consoleurl",
            "source": {
                "value": "$AppUrl"
            }
        },
        {
            "name": "consoleun",
            "source": {
                "value": "$ConsoleUser"
            }
        },
        {
            "name": "twistlocklicense",
            "source": {
                "value": "$TwistlockLicense"
            }
        },
        {
            "name": "deploymentartifacts",
            "source": {
                "value": "twistlock-artifacts"
            }
        }
    ]
}
"@

$IsInsecureRegistry = $false

if ($DeploymentType -eq [DeploymentType]::Disconnected)
{
    $IsInsecureRegistry = $true
}


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
    -IsInsecureregistry:$IsInsecureRegistry




# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUouRwRyI4vimz8LwQBey7Ythp
# FMmgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBTFp035MYVVex3xDBfRV1hrZ2H9vDANBgkqhkiG
# 9w0BAQEFAASCAgA1VgDh7SKijCU6wVkgGtttRM4gt+XHYenDbRvEFAk+9wpduceG
# Q2etA6leO6TA9AuvBkdpT0UGpA8ir8Qg5lBVBW3LtcFN+72YbAN1clUn0Kz6XHdf
# FEhb/1buWzNyS/bF482RynF2hqP/Hik3G+yIRfFFA15DDyTVdWDRNaGCDDe67g2P
# 7wfLCizF+XJ6pkkAt2x9oH/hOmza+VGkqGJ3vdtAI6X3VXT53OVNJX33p2M64Y0r
# UeMsSeoCZvs2id/n7/uPaM70XzcyZyIRO5/za3IoRmXmvPIkbsyk+FAmqkc/30MO
# CdHVvsyLU+Lj1/CexnfUhakic8UkZnTUbfKDh0IGpfKNXLxL7HkL2cOxM/RzyHfw
# WXc9OLRsb2bEhbDbZFI6MimQz+hjJD7j8hyel9xh4aYcS5Yuf7mId745uN3iIqas
# aIkDls4WNXCqomp5+xpudr62l9cIk6kD5vfoMJ2v30FakxYxgcmIu4MloG98vgz9
# Nuq9SxiluFTu/kgJOuiac6OxrbY8QIdBglmuKXYfU4ISvSejO8SPfJevnl8ss6bH
# GqX16F9Up7+R99S7V3Fk1DEpO/ik7JuFmTiOdT1CdBgCUf3+U0iB7fLs8re+K0Bu
# 1O67jiSVP7zupio2AI0+pUbXtArF4QvM6wc4JPs3vXkGWHpON2ArVmT44A==
# SIG # End signature block
