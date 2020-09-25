param (
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $ScriptsPath,
    [Parameter(Mandatory=$true)] [string] $MasterClusterDns,
    [Parameter(Mandatory=$true)] [string] $MasterPrivateClusterIp,
    [Parameter(Mandatory=$true)] [string] $RoutingSubDomain,
    [Parameter(Mandatory=$true)] [string] $RouterPrivateClusterIp,
    [Parameter(Mandatory=$true)] [string] $MasterHostname,
    [Parameter(Mandatory=$true)] [int] $MasterInstanceCount,
    [Parameter(Mandatory=$true)] [string] $InfraHostname,
    [Parameter(Mandatory=$true)] [int] $InfraInstanceCount,
    [Parameter(Mandatory=$true)] [string] $NodeHostname,
    [Parameter(Mandatory=$true)] [int] $NodeInstanceCount,
    [Parameter(Mandatory=$true)] [bool] $EnableCns,
    [Parameter(Mandatory=$true)] [string] $CnsHostname,
    [Parameter(Mandatory=$true)] [int] $CnsInstanceCount
)

Log-Information "Prepare dnsmasq script"
New-Item -Path $ScriptsPath/dnsmasq-settings.sh -Force -ItemType file -Value @"
cat > /etc/dnsmasq.conf <<FOR
conf-dir=/etc/dnsmasq.d,.rpmnew,.rpmsave,.rpmorig
address=/$MasterClusterDns/$MasterPrivateClusterIp
address=/$RoutingSubDomain/$RouterPrivateClusterIp
FOR

systemctl restart dnsmasq
"@

$jsonFile = New-Base64EncodedJson -ScriptPath $ScriptsPath -ScriptFileName "dnsmasq-settings.sh"

$Job = 1..4 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            Set-LogFile "./deployment-output/dnsmasq-$($using:MasterHostname)_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            Log-Information "alter masters dnsmasq"
            $c = 1
            do {
                $n = ([string]$c).PadLeft(3,"0")
                Log-Information "altering $using:MasterHostname-$($n)v"

                New-AzureLinuxExtension -ResourceGroup $using:ResourceGroup -VmName "$using:MasterHostname-$($n)v" -JsonFile $using:jsonFile

                $c++
            } until ($c -gt $using:MasterInstanceCount)
        }
        2 {
            Set-LogFile "./deployment-output/dnsmasq-$($using:InfraHostname)_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            Log-Information "alter infra dnsmasq"
            $c = 1
            do {
                $n = ([string]$c).PadLeft(3,"0")
                Log-Information "altering $using:InfraHostname-$($n)v"

                New-AzureLinuxExtension -ResourceGroup $using:ResourceGroup -VmName "$using:InfraHostname-$($n)v" -JsonFile $using:jsonFile

                $c++
            } until ($c -gt $using:InfraInstanceCount)
        }
        3 {
            Set-LogFile "./deployment-output/dnsmasq-$($using:NodeHostname)_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            Log-Information "alter node dnsmasq"
            $c = 1
            do {
                $n = ([string]$c).PadLeft(3,"0")
                Log-Information "altering $using:NodeHostname-$($n)v"

                New-AzureLinuxExtension -ResourceGroup $using:ResourceGroup -VmName "$using:NodeHostname-$($n)v" -JsonFile $using:jsonFile

                $c++
            } until ($c -gt $using:NodeInstanceCount)
        }
        4 {
            if ($using:EnableCns)
            {
                Set-LogFile "./deployment-output/dnsmasq-$($using:CnsHostname)_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
                Log-Information "alter cns dnsmasq"
                $c = 1
                do {
                    $n = ([string]$c).PadLeft(3,"0")
                    Log-Information "altering $using:CnsHostname-$($n)v"

                    New-AzureLinuxExtension -ResourceGroup $using:ResourceGroup -VmName "$using:CnsHostname-$($n)v" -JsonFile $using:jsonFile

                    $c++
                } until ($c -gt $using:CnsInstanceCount)
            }
        }
    }

    # potential workaround for thread locks
    Start-Sleep -Seconds 5
} -AsJob -ThrottleLimit 5
$Job | Receive-Job -Wait







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJ7mU8+hXnSy+zCubig/2RZoB
# HcSgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBSffYqXJLgI9cwl4oeHz0d3gPespzANBgkqhkiG
# 9w0BAQEFAASCAgA9C6YboVOTsBH7jH7Hwea0ljef4rFc3MDAXczdiurhJXDksWHp
# hrMNVZ+Z0itUpyugSOe4/7gu8io3YNbXNv3p58dlfOJoQsEgNSrix6izpMdIsvkc
# BJgTMze/NrYr2lVz6n+nny0SBM81sLFflvNC132nNPWo9yClNPi8xHuvm7NWYENE
# a1d8mXgz4AxdGHFn643LSBUFnSrhRDVs3uJC22G4JsLWwCxYdY5WlLo26UunW8m1
# 2FsZZNO0l2GL+47DCl6qPHQt4lXDYScLtWLKDnPCmyf8ip/c9tJSgnNK2m5AFWJj
# Pa84uoI7xexvX4d333JZS18k4gWAmOckkTfU9jq1k3LK8VuyjZReXP58G18Et5QK
# h8SZtTsKplnLvEi9uWVjM8FFEQF9NEswfVDy3pkRcfson3JYtNPzXtKIIVJDA/Dg
# 0DpW2CCnUMt2M+6/T/mQkSgr3bfn3cD223btFuW8of/4r98xz5CBZe0juDzpdHC2
# UIRcmwgK3nzM9CQ1PCudGLljnbQpKX+Z8XOISuX4KOI2bq0tT5AcDXsMFntug3zN
# /5GUgBWIBVVYEgnHy4ymUJA3SslQ0UdnBjq+lSVVbdOkFfrmEvb3H1w5b9d3O/cP
# Vb9AaJxZZkldjxnqs5jm2hz+ClzmvysSV3sJNQK6eBmtBlWnkSpVvWCJyQ==
# SIG # End signature block
