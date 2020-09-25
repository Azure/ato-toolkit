param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $ClusterType,
    [Parameter(Mandatory=$true)] [string] $AppName,
    [Parameter(Mandatory=$true)] [string] $AppUrl,
    [Parameter(Mandatory=$true)] [string] $Namespace,
    [Parameter(Mandatory=$true)] [string] $PostgresUsername,
    [Parameter(Mandatory=$true)] [string] $PostgresPassword,
    [Parameter(Mandatory=$true)] [string] $ContainerRegistry,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $BastionMachineName,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$true)] [string] $TenantId,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [bool] $EmailNotifications,
    [Parameter(Mandatory=$true)] [bool] $EnableSmtpAuth,
    [Parameter(Mandatory=$true)] [string] $SmtpUsername,
    [Parameter(Mandatory=$true)] [string] $SmtpPassword,
    [Parameter(Mandatory=$true)] [string] $SmtpServer,
    [Parameter(Mandatory=$true)] [int] $SmtpPort,
    [Parameter(Mandatory=$false)] [string] $BastionProxyUsername,
    [Parameter(Mandatory=$false)] [string] $BastionProxyIp
)

Log-Information "Generating parameter file for Porter install."
$parameterJson = @"
{
    "name": "myparams",
    "parameters": [
        {
            "name": "app-url",
            "source": {
                "value": "$AppUrl"
            }
        },
        {
            "name": "helm-environment-value",
            "source": {
                "value": "$ClusterType"
            }
        },
        {
            "name": "registry",
            "source": {
                "value": "$ContainerRegistry"
            }
        },
        {
            "name": "namespace",
            "source": {
                "value": "$Namespace"
            }
        },
        {
            "name": "postgres-username",
            "source": {
                "value": "$PostgresUsername"
            }
        },
        {
            "name": "postgres-password",
            "source": {
                "value": "$PostgresPassword"
            }
        },
        {
            "name": "email-notifications",
            "source": {
                "value": "$($EmailNotifications.ToString())"
            }
        },
        {
            "name": "enable-smtp-auth",
            "source": {
                "value": "$($EnableSmtpAuth.ToString())"
            }
        },
        {
            "name": "smtpusername",
            "source": {
                "value": "$SmtpUsername"
            }
        },
        {
            "name": "smtppassword",
            "source": {
                "value": "$SmtpPassword"
            }
        },
        {
            "name": "smtpserver",
            "source": {
                "value": "$SmtpServer"
            }
        },
        {
            "name": "smtpport",
            "source": {
                "value": "$SmtpPort"
            }
        }
    ]
}
"@

$IsInsecureRegistry = $false
if ($DeploymentType -eq [DeploymentType]::DisconnectedLite)
{
    $IsInsecureRegistry = $true
}

Log-Information "Logging in to az cli for tenant [$TenantId] and subscription [$SubscriptionId]"
Confirm-DsopAzLogin `
    -TenantId $TenantId `
    -SubscriptionId $SubscriptionId `
    -DeploymentType $DeploymentType

Log-Information "Installing Mattermost via CNAB bundle."
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUifGWbT96BYZfMkGw5eKsudqD
# nzegggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBQdd99wuf/CCJPZ0GEEM93Z+aOdvTANBgkqhkiG
# 9w0BAQEFAASCAgAlaMk8JqvQmHxC9N/kYfH7QENLtz6mxQmkVd7Szi9msBsIcmUz
# k+dF+7/R5fXaiL5No3XIoJW6qQmzFYtZzjqCMIbPTWRQOR8NheQY7SA1lX+mmMq8
# vAlSLlOBJaijesXa9lygy1JWDKDmUp325M7UgoUpFUhcac5KOoWHWhHRLm7j+JS4
# jxRNBkIVaO8zcNbgazSYBIuK+rFHbHpy0ml4n4xgDWknX9wNlrgoWT7wnSCBdc99
# /4F8arrmoUQA3Ev5b6rwFKUtUaWj0IbIj0Fy7nEAPmfaAhTiNVUwHFB91yiiaPpX
# KEWLUBUxra4eUS4QCEhUhdLDhTUYJek2xBCZzPWQuNMPWLABjF2lXWqF0PGVvfp7
# SeSWhcg7FBrk5KIbf/CPW2LtlXmxqReykyPMgYDtI9RvCThz3J0XXDsYcJf/eYMP
# WTg8WkSS01ikTqEk1hpnrvPtRSS8EvqGzBYqPJ7r0m4Zj3pUnoMpKVhYt3Ptj5xl
# Li7SsYhlCa7CxNxBi9/bEbmCY/NA/Y8O+Mxmi9lDM09l0JvXTW8AZJeES5N3MOXn
# ZsPkhy7AYUtQ6VNf8t8u9EK2b3bTWTxLuFcviUDItHxABds5gegnjo1mjswuTqWd
# tUNnfUnjqVQjSPZPAGhz9HOFvT0k271Je9er3FU9fjH8jZXgMDySSASzeg==
# SIG # End signature block
