param (
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [int] $DataDiskSize,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $DiagnosticsStorage,
    [Parameter(Mandatory=$true)] [string] $MarketplaceOffer,
    [Parameter(Mandatory=$true)] [string] $MarketplacePublisher,
    [Parameter(Mandatory=$true)] [string] $MarketplaceSku,
    [Parameter(Mandatory=$true)] [string] $MarketplaceVersion,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$true)] [string] $MasterInfraSubnetReference,
    [Parameter(Mandatory=$true)] [string] $OsImageType,
    [Parameter(Mandatory=$true)] [string] $VhdImageName,
    [Parameter(Mandatory=$true)] [int] $MasterInstanceCount,
    [Parameter(Mandatory=$true)] [int] $InfraInstanceCount,
    [Parameter(Mandatory=$true)] [int] $NodeInstanceCount,
    [Parameter(Mandatory=$true)] [int] $CnsInstanceCount,
    [Parameter(Mandatory=$true)] [string] $ClusterType,
    [Parameter(Mandatory=$true)] [string] $MasterVmSize,
    [Parameter(Mandatory=$true)] [string] $InfraVmSize,
    [Parameter(Mandatory=$true)] [string] $NodeVmSize,
    [Parameter(Mandatory=$true)] [string] $CnsVmSize,
    [Parameter(Mandatory=$true)] [string] $BastionShortname,
    [Parameter(Mandatory=$true)] [string] $MasterShortname,
    [Parameter(Mandatory=$true)] [string] $NodeShortname,
    [Parameter(Mandatory=$true)] [string] $InfraShortname,
    [Parameter(Mandatory=$true)] [string] $CnsShortname,
    [Parameter(Mandatory=$true)] [bool] $EnableCns,
    [Parameter(Mandatory=$true)] [int] $CnsGlusterDiskSize,
    [Parameter(Mandatory=$true)] [string] $AvailabilitySetPrefix
)

$AllParams = @{}
$AllParams.AdminUsername = $AdminUsername
$AllParams.AzureLocation = $AzureLocation
$AllParams.DataDiskSize = $DataDiskSize
$AllParams.ResourceGroup = $ResourceGroup
$AllParams.DiagnosticsStorage = $DiagnosticsStorage
$AllParams.MarketplaceOffer = $MarketplaceOffer
$AllParams.MarketplacePublisher = $MarketplacePublisher
$AllParams.MarketplaceSku = $MarketplaceSku
$AllParams.MarketplaceVersion = $MarketplaceVersion
$AllParams.SshKey = $SshKey
$AllParams.SubnetName = $MasterInfraSubnetReference
$AllParams.OsImageType = $OsImageType
$AllParams.VhdImageName = $VhdImageName

$Job = 1..5 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            $MachineNamePrefix = "$using:AvailabilitySetPrefix-$using:BastionShortName"
            if ($using:ClusterType -eq "public")
            {
                $PublicIpName = "$MachineNamePrefix-PIP"
            }
            # Bastion
            ./do-vm-creation-shim.ps1 @using:AllParams `
                -InstanceCount 1 `
                -MachineNamePrefix $MachineNamePrefix `
                -VmSize $using:NodeVmSize `
                -PublicIpName $PublicIpName `
                -NetworkSecurityGroup "$MachineNamePrefix-NSG"
        }
        2 {
            # Master
            $MachineNamePrefix = "$using:AvailabilitySetPrefix-$using:MasterShortname"
            ./do-vm-creation-shim.ps1 @using:AllParams `
                -MachineNamePrefix $MachineNamePrefix `
                -InstanceCount $using:MasterInstanceCount `
                -LoadBalancerName "$MachineNamePrefix-LB" `
                -LoadBalancerBackEnd "loadBalancerBackEnd" `
                -VmSize $using:MasterVmSize `
                -AvailabilitySet "$MachineNamePrefix-AS01" `
                -NetworkSecurityGroup "$MachineNamePrefix-NSG"
        }
        3 {
            # Infra
            $MachineNamePrefix = "$using:AvailabilitySetPrefix-$using:InfraShortname"
            ./do-vm-creation-shim.ps1 @using:AllParams `
                -MachineNamePrefix $MachineNamePrefix `
                -InstanceCount $using:InfraInstanceCount `
                -LoadBalancerName "$MachineNamePrefix-LB" `
                -LoadBalancerBackEnd "loadBalancerBackEnd" `
                -VmSize $using:InfraVmSize `
                -AvailabilitySet "$MachineNamePrefix-AS01" `
                -NetworkSecurityGroup "$MachineNamePrefix-NSG"
        }
        4 {
            # Node
            $MachineNamePrefix = "$using:AvailabilitySetPrefix-$using:NodeShortname"
            ./do-vm-creation-shim.ps1 @using:AllParams `
                -MachineNamePrefix $MachineNamePrefix `
                -InstanceCount $using:NodeInstanceCount `
                -VmSize $using:NodeVmSize `
                -AvailabilitySet "$MachineNamePrefix-AS01" `
                -NetworkSecurityGroup "$MachineNamePrefix-NSG"
        }
        5 {
            # CNS
            if ($using:EnableCns)
            {
                $MachineNamePrefix = "$using:AvailabilitySetPrefix-$using:CnsShortname"
                ./do-vm-creation-shim.ps1 @using:AllParams `
                    -MachineNamePrefix $MachineNamePrefix `
                    -InstanceCount $using:CnsInstanceCount `
                    -CnsGlusterDiskSize $using:CnsGlusterDiskSize `
                    -VmSize $using:CnsVmSize `
                    -AvailabilitySet "$MachineNamePrefix-AS01" `
                    -NetworkSecurityGroup "$MachineNamePrefix-NSG"
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQULRfZsOQfPwIB/zsOPcUkwxNb
# FfagggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBQSYlmrs2+f2xevzYphpbhzYCnVjDANBgkqhkiG
# 9w0BAQEFAASCAgAKO6z03iU19Wzqxk2sXrkHWznxusfXxblKFj912tpbEg46MPmy
# T55tMKPZ0qRQ52trD3w5Pm4cDMpHQpk96pvJao1WN8UUAam4j18JOJuS5d6XtMlD
# Dv9QxWBy9TKZlcdV0G/oP2qxFzVfv9di46++T6V+aA+ho0aPMG7Eay2SaApKvNEu
# 8LJtXDEu+V/99wCURKFKhqBSBEOhFH3T/Laqe2hTOKN2k2dT86zvv1n1bWBSjGN6
# pN6yNrEUWJ9BDP3o+PdRoV5LZbiURZ7jjxFBLAF6pPMm+8G2OxkgbzC1NJ8RgAZ1
# m2TNtkT66yRmV2M6NRvRQwhUqFkOsEtNm+1cblqjbF7hi343UseXdL8nPx7ANUVk
# sL7Re9t+THgNqMpyz6QT9pGg+sHRQsDEe621FhlnV0KXRjijPnTZ+pqQywhORS3W
# ZV3sFJkBUklZ0JFetEIM14tuwtSs7glqwjJrGCUDpOl41NMXFTOjSvUROwBhF66+
# 853Z1kzbd3/4PHO1/Lh2LUR3a8b+ZNrd+mkdJYT59FZ4X+TMdAfjznOdGWVCLzuE
# eiCO7rIWkVXZoSeS0BCvrtBlyo949ayFsLoP/MMBtSbNLLTOuqX9NIRMcfNw84gb
# O/qtjf8wCBDS5NO1Snvy4hal/fyjBASxcmk7GG5n2Cnyok98NDwiajfyZA==
# SIG # End signature block
