param (
    # Mandatory Parameters
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [string] $DiagnosticsStorage,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$true)] [string] $SubnetName,
    [Parameter(Mandatory=$true)] [int] $DataDiskSize,
    [Parameter(Mandatory=$true)] [string] $MachineNamePrefix,
    [Parameter(Mandatory=$true)] [string] $NetworkSecurityGroup,
    [Parameter(Mandatory=$true)] [string] $MarketplacePublisher,
    [Parameter(Mandatory=$true)] [string] $MarketplaceOffer,
    [Parameter(Mandatory=$true)] [string] $MarketplaceSku,
    [Parameter(Mandatory=$true)] [string] $MarketplaceVersion,
    [Parameter(Mandatory=$true)] [string] $VmSize,
    [Parameter(Mandatory=$true)] [int] $InstanceCount,
    [Parameter(Mandatory=$true)] [string] $OsImageType,
    [Parameter(Mandatory=$true)] [string] $VhdImageName,
    #Optional Parameters
    [Parameter(Mandatory=$false)] [string] $LoadBalancerName,
    [Parameter(Mandatory=$false)] [string] $LoadBalancerBackEnd,
    [Parameter(Mandatory=$false)] [string] $AvailabilitySet,
    [Parameter(Mandatory=$false)] [int] $CnsGlusterDiskSize = 0,
    [Parameter(Mandatory=$false)] [string] $PublicIpName
)

1..$InstanceCount | ForEach-Object -Parallel {
    ./do-vm-creation.ps1 -ResourceGroup $using:ResourceGroup `
        -AzureLocation $using:AzureLocation `
        -DiagnosticsStorage $using:DiagnosticsStorage `
        -AdminUsername $using:AdminUsername `
        -SshKey $using:SshKey `
        -SubnetName $using:SubnetName `
        -MachineNumber $_ `
        -DataDiskSize $using:DataDiskSize `
        -MachineNamePrefix $using:MachineNamePrefix `
        -NetworkSecurityGroup $using:NetworkSecurityGroup `
        -MarketplacePublisher $using:MarketplacePublisher `
        -MarketplaceOffer $using:MarketplaceOffer `
        -MarketplaceSku $using:MarketplaceSku `
        -MarketplaceVersion $using:MarketplaceVersion `
        -LoadBalancerName $using:LoadBalancerName `
        -LoadBalancerBackEnd $using:LoadBalancerBackEnd `
        -AvailabilitySet $using:AvailabilitySet `
        -CnsGlusterDiskSize $using:CnsGlusterDiskSize `
        -PublicIpName $using:PublicIpName `
        -VmSize $using:VmSize `
        -OsImageType $using:OsImageType `
        -VhdImageName $using:VhdImageName `
        -LogFile "./deployment-output/vm-creation-$($using:MachineNamePrefix)_$($_)_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
    # potential workaround for thread locks
    Start-Sleep -Seconds 5
} -AsJob -ThrottleLimit 10 | Receive-Job -Wait







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+oOrWEiA87OOPoiOAX3itFvL
# fVygggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBQjAqbiCGX84xWupnrPRhsC8R3EeDANBgkqhkiG
# 9w0BAQEFAASCAgBh0tGi4TB2R1F124MhtJq6LkizbAEqAn1BBhreSSj/kAvCNqwm
# ZNUNY/75ub8X2cqB04G8kF5DLEemd2gefl5oIoQ7c3u9Zc9dJLpP+SomZQdfdh8q
# u/nD0AgFZCBZjA7fhDKf+BkylYXbDnUXyZPp2UbuWcl9FHmM9YR01SS2cLwDC3D0
# CYf+PGEOuOjzkUAhYtKD0y0+jJwI09eWmHPtsZ4WXp0ln0fU73iEDruzkFk2NHy/
# v2XJnLngOFe1tpgFCxNV04WxJFnH0QIjYQHUdL4BR7x/U/UXvNZ0v7kv7nMAgAIy
# phaCcVXjxngBXRJUoaWWgu0zU9kmhqmKMRb+0dwD3O9gryOI2ca92rQAnRwX1nOM
# Iz4IqncMb90925et6y7ISWVCv/M0tzqOxyQDiYy3MKpQWLFhZx2neYAhPnNvQFuU
# j5YLqslyB623nGSzeYFc8dFD0EkpOWkCekrMaWIysutGA2bHmEfssSeHULTCEP5n
# wBjZ0xinkLfNHNHlOd5UQHkNKeqc5zcxf58ljnk/UeR1D24fPU1F1A64Z61DfqAS
# i8AVgKx4AdBNfw1G4y/kNNhZTtXVOg1LKXF507G6vlioB8Xdrd65iwWrR+7No44m
# kxdZ5H/D7d5EqzRuNr61RvW4yWHvDq1FFGc6lyr02R/6yBaf8JD30RUIcA==
# SIG # End signature block
