param (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern('(?i)\A\{?[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\}?\z')]
    [string] $TenantId,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern('(?i)\A\{?[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\}?\z')]
    [string] $SubscriptionId,

    [parameter(Mandatory=$true)]
    [DeploymentType] $DeploymentType
)

Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$proc = "az"

if ($DeploymentType -ne [DeploymentType]::Disconnected) {

    Log-Information "Verifying az cli is logged into $TenantId"
    $TenantLogin=(az account list --query "[?tenantId=='$TenantId']" -o json) | ConvertFrom-Json
    if (-not $TenantLogin)
    {
        Log-Warning "Not logged in. Requesting now."
        if(!$env:AZUSERNAME)
        {
            Log-Warning "You may be required to verify your login via browser."
            az login --tenant $TenantId
        }
        else 
        {
            az login --service-principal -u $env:AZUSERNAME -p $env:AZPASSWORD --tenant $TenantId
        }
    }

    Log-Information "Login confirmed. Setting subscription."
    $argList = "account set -s $SubscriptionId"
    $retVal = Run-Command -Process $proc -Arguments $argList

    $argList = "account list -o table"
    $retVal = Run-Command -Process $proc -Arguments $argList
}
else
{
    # The config here is so blinded and heavy right now, that we're going to just skip these steps
    # for now they will do all of their manual steps to get it authenticated prior to deployment.
    Log-Information "Not confirming login. We currently do not confirm login for a disconnected deployment."
}

Log-Footer -ScriptName $MyInvocation.MyCommand







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbNORpVxXk3zsptL2hR3+SPKy
# bGygggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBS7TFraMf1GJB3YBuxTsghvMQun3DANBgkqhkiG
# 9w0BAQEFAASCAgBnNDTwdygHcyYxF4MCDgJj4ueDh8niYSSF3BmoIM6+7jyU6UdB
# jx1fxBePUdikGtO9eRG3feYNkgkP4IC589IZ0bQGhYmYFKyvoDe1M5jHRgMeacvg
# j45f9uJ6nG49kidq+fHD1n8awAA+l64ut1g0W2wBUAKzXy2qHKVdIcf8qrCvz1H2
# DxMfYo85HOsqbjYlXaAN5ldfcwUDh8TT37C1TK77iNOkxxfQWqm9Q1a4jcGyCxTw
# EUXPvrOkn52QFTtLpHrsoR64hXV0vE1ovixIXzKueNga89c4hHyQ44QxKhGlfc7P
# R2JrDlOvx08iefGvNYsm0+nrZWUO4WOkFD7y/Y4GyHAXvRKtmOHz2XMXLTt14GKs
# Sv5c0IqGq1wquMqc2f8V1DcuZjOQisAVS1yMDw9Yua/Bi2XlenGfsQ/xfw6KZzdz
# WUzdFnAPEm/Ckrf+6+toCIsQbLt9ygEcR1V4U92zH3cvXP0hcYm0a2RdY/oUsqNW
# ws5EmV6RsXVNq0QVrdtrZgNrbQ1sM68GRYNYryrurj/ms4QR63pOzgo0wX64uSnj
# kCTPzYgJO0ThxXjw/02YiJmNbKnjUKmz4af+n+5WkrJ9i2lnehF6ObuXu16TRubG
# NVWiDLZ437jy8pibfv/uWUfIGipHSZ1hL3+RrWcP9ZSd8QjLDY8ccgD3aw==
# SIG # End signature block
