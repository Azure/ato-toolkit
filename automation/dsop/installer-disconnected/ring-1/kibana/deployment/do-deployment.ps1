param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [string] $TenantId,
    [Parameter(Mandatory=$true)] [string] $ClusterType,
    [Parameter(Mandatory=$true)] [string] $AppName,
    [Parameter(Mandatory=$true)] [string] $AppUrl,
    [Parameter(Mandatory=$true)] [string] $ContainerRegistry,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $KeyVault,
    [Parameter(Mandatory=$true)] [string] $ElasticHostIp,
    [Parameter(Mandatory=$true)] [string] $BastionMachineName,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$false)] [string] $BastionProxyUsername,
    [Parameter(Mandatory=$false)] [string] $BastionProxyIp
)

Set-LogFile "./deployment-output/deployment_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

Log-Information "Confirm login"
Confirm-DsopAzLogin `
    -TenantId $TenantId `
    -SubscriptionId $SubscriptionId `
    -DeploymentType $DeploymentType

$kibanaPassword = ( az keyvault secret show --name kibanaPassword --vault-name $KeyVault -o tsv --query value )

# love me some helm: https://helm.sh/docs/intro/using_helm/#the-format-and-limitations-of---set
$kibanaPassword = $kibanaPassword.Replace(',', '\\\,').Replace('.', '\\\.')

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
            "name": "elastic-password",
            "source": {
                "value": "$kibanaPassword"
            }
        },
        {
            "name": "elastic-host-ips",
            "source": {
                "value": "https://$ElasticHostIp`:9200"
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

$IsInsecureRegistry = $true

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

Log-ScriptEnd






# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUF/Aj6kxuf90qXomHocX61ooN
# flugggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBSEFm59O9qt2n3DDWnFnaJ0DifNETANBgkqhkiG
# 9w0BAQEFAASCAgBLxKPjyx+osUvMsylOhwIW6f9PWp7lmp8FRLluv4Lj+lOL4Ogb
# jjNS+iUFeXKOe/ZXmxB0IQNlJzQNEqgF7Q8dfFuK4/nYXT9eAWQ63rUGiJ6OvHuZ
# vhqrTWHYWCXgTEARCx7UGaWB64iJPPyn7+uUzWcbKrB7r9QKdwPE/AAytSyH82CW
# e7oD6YheGl4xk30LPHQe8KmHrHVqJ0o8TorQtX+t07D1I06/2nGcSsVD1tFnyFPS
# ZhT4N0lrSL+XjG2VmmYS0C6M8uCJwcl1BAsv7yezWt/SbT0l3ZY3tgRYAlpqDdh8
# ySPVo2tpjqKcJAfvt420aPYaaGN0sjtTZ0KvpA+vFcNSUFvq+M87/W8zPgwH8e2T
# ZT3U3cmhq07YgJ6woHVkYeMhYRS627Cne3voNe/i1MkMUyQ06YbiUQWoRQqKBbjw
# U1rhNB6WytngnDfqPhIrXKlUl7zioKJckKnwhy2G87seW2P564AxCE9JRbePDC/z
# sXE00VCTYRfV91inrbpIKMa+ZLkhe4MLEcv2kYN/zCToi231io+MRT2YUDCUAKO+
# 5glN6Po5Jx4tk61MzFlBdnthMbiBX8Y0CrnL6sMU0PZFmFQXD+f7zGxPaQkK0UHn
# yASg9H66uLqLvrCk/I13XLTGG15ZezPmQTFEIPaSd81x8nh3jsEMDsh2pw==
# SIG # End signature block
