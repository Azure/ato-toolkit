param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $ClusterType,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $AppName,
    [Parameter(Mandatory=$true)] [string] $ContainerRegistry,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $Username,
    [Parameter(Mandatory=$true)] [string] $DriveName,
    [Parameter(Mandatory=$true)] [string] $StringMatch,
    [Parameter(Mandatory=$true)] [string] $Tenant,
    [Parameter(Mandatory=$true)] [string] $Paswd,
    [Parameter(Mandatory=$true)] [string] $BastionMachineName,
    [Parameter(Mandatory=$true)] [string] $BastionMachineIp,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$false)] [string] $AzArgs,
    [Parameter(Mandatory=$false)] [string] $BastionProxyUsername,
    [Parameter(Mandatory=$false)] [string] $BastionProxyIp,
    [Parameter(Mandatory=$false)] [bool] $IsInsecureRegistry,
    [Parameter(Mandatory=$true)] [string] $NSSCertPath
)

$parameterJson = @"
{
    "name": "myparams",
    "parameters": [
        {
            "name": "username",
            "source": {
                "value": "$Username"
            }
        },
        {
            "name": "resourcegroup",
            "source": {
                "value": "$ResourceGroup"
            }
        },
        {
            "name": "drivename",
            "source": {
                "value": "$DriveName"
            }
       },
       {
            "name": "stringmatch",
            "source": {
                "value": "$StringMatch"
            }
        },
        {
            "name": "tenant",
            "source": {
                "value": "$Tenant"
            }
        },
        {
            "name": "paswd",
            "source": {
                "value": "$Paswd"
            }
        },
        {
            "name": "registryurl",
            "source": {
                "value": "$ContainerRegistry"
            }
        },
        {
            "name": "azargs",
            "source": {
                "value": "$AzArgs"
            }
        }
    ]
}
"@

$credentialsNSS = @"
{
    "name": "NSSRoot2",
    "source":
        {
        "path": "$NSSCertPath"
        }
}
"@


#need to add to the Common Library in future releases.  Additionally will have to take into account Seq envs
#Run-Command -Process "ssh.exe" -Arguments "-i `"certs/$SshKey`" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $AdminUsername@$BastionMachineIp `"oc adm policy add-scc-to-user privileged system:serviceaccount:openebs:openebs-maya-operator`""
Run-Command -Process "ssh.exe" -Arguments "-i `"$($(Get-Location).Path)\certs\$SshKey`" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $AdminUsername@$BastionMachineIp `"oc adm policy add-scc-to-user privileged system:serviceaccount:openebs:openebs-maya-operator`""

Log-Information "Installing OpenEBS via CNAB bundle."
Log-Information "This will take some time to deploy with no visual output until process is complete."
Install-PorterFromBastion `
    -DeploymentType $DeploymentType `
    -AppName $AppName `
    -ContainerRegistry $ContainerRegistry `
    -ResourceGroup $ResourceGroup `
    -BastionMachineName $BastionMachineName `
    -BastionMachineIp $BastionMachineIp `
    -AdminUsername $AdminUsername `
    -SshKey $SshKey `
    -BastionProxyUsername $BastionProxyUsername `
    -BastionProxyIp $BastionProxyIp `
    -ParameterJson $parameterJson `
    -CredentialsJson $credentialsNSS `
    -BundlePath "$($(Get-Location).Path)/$AppName.tgz" `
    -IsInsecureRegistry:$IsInsecureRegistry

# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUcsdwBySKt+y4lvomMQ6DhUXi
# D9WgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBS9l3salrwOKr6ShlY8VKebFpXEqDANBgkqhkiG
# 9w0BAQEFAASCAgCCozFhpc1HMX142vEu5LSILV8/SXfYr56d30KuHZLomsAjDhvT
# KFUxvvc2i5VxoG1VMziUWPg3Ld1BQW1O1iO9da+ScPtjf6LsX6+446vZyfXMgS+t
# JeEva+olVaJGpV42TCw0dYhquWGstl85/PGUJ3k5swxbbWcQKOOhvnU3Q9vP5BFW
# lDU2tpVsN7aKiIg8g3iF6h7DcAiSi1wTXaLRrrtiyszKSir7mkCDMx3DWl+IH3zw
# V/0NcXXHsK+arSNp8y4pCV8kUI7L98Ox0A0jJpsDA6Yv862Mw+b3Q8Ky3rGoi/k4
# bn5gKxpHY4dSo1I0thSdXGIn3g9y4vhMMekAKBueoUcCSjSem7VRR99JpAYCkF55
# 8dqgEnrRtP3iFujcgXxfw18jsI+h4lM4e4encVj3NxnhLxqyTY+D0JKxLzdtoZRc
# D6xa78JwSz6nuvfIhTMdQ449uiQlpTyvA5JEagWR8A2DZOK4W89e1OYuseezVkZH
# N3WocNpczYsK5Pql6rjE0DKn6iEXTnmg/L1nMu/OxtooeKkHNXL7w6f68c8eD1Ix
# UR3iKxcQuPxj/Aj0seqPqRBQoXKlw8e27c+SnW91dH5+bNgzlLBZcsJrskjGAjN3
# KDBKaMjxXcgjY7DCZ8u/EhbDZSUvGmf4KqTxP1RiygoCE37hvC26Sfj5gQ==
# SIG # End signature block
