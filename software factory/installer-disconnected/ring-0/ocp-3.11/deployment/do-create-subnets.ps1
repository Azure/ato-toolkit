param (
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string] $ResourceGroup,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string] $AddressPrefixes,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string] $VirtualNetworkName,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string] $MasterInfraSubnetName,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string] $MasterInfraSubnetPrefix,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string] $NodeSubnetName,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string] $NodeSubnetPrefix
)

Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$proc = "az"

Log-Information "Create resource group for deployment: $ResourceGroup"
$retVal = Run-Command -Process $proc -Arguments "group create -l `"$AzureLocation`" -n $ResourceGroup -o table"

Log-Information "Create Virtual Network"
$argList = "network vnet create --resource-group $ResourceGroup " +
            "--name $VirtualNetworkName " +
            "--address-prefix $AddressPrefixes " +
            "-o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Information "Creating Master Infra Subnet"
$argList = "network vnet subnet create --address-prefix $MasterInfraSubnetPrefix " +
            "--resource-group $ResourceGroup " +
            "--name $MasterInfraSubnetName " +
            "--vnet-name $VirtualNetworkName " +
            "-o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Information "Creating Node Infra Subnet"
$argList = "network vnet subnet create --address-prefix $NodeSubnetPrefix " +
            "--resource-group $ResourceGroup " +
            "--name $NodeSubnetName " +
            "--vnet-name $VirtualNetworkName " +
            "-o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Footer -ScriptName $MyInvocation.MyCommand







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9/e8UbzH8IyWlFF9jzMFMuBS
# X6KgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBTEfS7JVvL5OyGbCkNQ8RIdvbN/GzANBgkqhkiG
# 9w0BAQEFAASCAgAgxPYdkwCG1IMXG+C4FC0r906dQaVkgYV83ijQONQQQlEJCmIy
# runog93xAQLW5F3Xilv1YbFpyyHdH+j7rwoXodYZUNWCT/w4KsXdtWDQ2SEdDOE8
# Kf2iwtUzSiRXDc5D51jSrDHlqm3xfpzC+MoA5wiVjU2EZ60mju76aSrSKiJ5qoyi
# /B725a8EO7t4n145hw7sv/15QzzhYanFWC6CBznpPWP/pI8FLTWJqf6ayYnJE2m4
# Oq7GArV4bJFstQfO9VQs+HW1V9i9PTDJ2ttY1PWvkr2WFkL5MGY0G0Uy52/YygrD
# qHiCKf9Rr2X4Lui++RnyCtU1mFNR1MUI8t8/G1DEyyAM3S+SueD9WSw2IU092HmI
# 94uIDY8AaiIW7Wyv9MV4+8TGu/dnZ4BRMm4NZ3XdSA1oa73lpMZ6DXNzdCK4nWHj
# RbSPVXcYlcog5hF7GriPoZQnAUK6lwkzSN2doR+bA/tBN7mqqofdyYSMaJQkbhgE
# 2cFEScGxXOsJfYzzjhg0WL62kGh4rXT8PAz0Y0/QmtH6G+Ax3Vl0QSgxbPYsC4xl
# I9uxJOzlauyKk3XeCWJ2DC6GNp8SLoUrzyumyjbTZAE/qrQmI0m/Z/+3iPL5p6qd
# uZFNHFjCsILJiqfDfFS67tpl7VJYe38oRfnsJwKk9AQV0wxQ37csqYfAIw==
# SIG # End signature block
