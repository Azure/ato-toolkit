param (
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $Environment,
    [Parameter(Mandatory=$true)] [string] $RegionLocation,
    [Parameter(Mandatory=$true)] [string] $RhsmUsernameOrOrgId,
    [Parameter(Mandatory=$true)] [string] $RhsmPasswordOrActivationKey,
    [Parameter(Mandatory=$true)] [string] $RhsmPoolId,
    [Parameter(Mandatory=$true)] [string] $MasterClusterDns,
    [Parameter(Mandatory=$true)] [string] $RoutingSubDomain,
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [int] $MasterInstanceCount,
    [Parameter(Mandatory=$true)] [int] $InfraInstanceCount,
    [Parameter(Mandatory=$true)] [int] $NodeInstanceCount,
    [Parameter(Mandatory=$true)] [int] $CnsInstanceCount,
    [Parameter(Mandatory=$true)] [string] $BastionShortname,
    [Parameter(Mandatory=$true)] [string] $MasterShortname,
    [Parameter(Mandatory=$true)] [string] $NodeShortname,
    [Parameter(Mandatory=$true)] [string] $InfraShortname,
    [Parameter(Mandatory=$true)] [string] $CnsShortname,
    [Parameter(Mandatory=$true)] [bool] $EnableCns,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $MasterCertType,
    [Parameter(Mandatory=$true)] [string] $RoutingCertType,
    [Parameter(Mandatory=$true)] [string] $OpenShiftMinorVersion,
    [Parameter(Mandatory=$true)] [string] $DomainName,
    [Parameter(Mandatory=$true)] [string] $MasterClusterDnsType,
    [Parameter(Mandatory=$true)] [string] $RoutingSubDomainType,
    [Parameter(Mandatory=$true)] [string] $MasterPrivateClusterIp,
    [Parameter(Mandatory=$true)] [string] $RouterPrivateClusterIp,
    [Parameter(Mandatory=$false)] [string] $MasterCertCaFile,
    [Parameter(Mandatory=$false)] [string] $MasterCertCrtFile,
    [Parameter(Mandatory=$false)] [string] $MasterCertKeyFile,
    [Parameter(Mandatory=$false)] [string] $RoutingCertCaFile,
    [Parameter(Mandatory=$false)] [string] $RoutingCertCrtFile,
    [Parameter(Mandatory=$false)] [string] $RoutingCertKeyFile,
    [Parameter(Mandatory=$false)] [string] $MasterLbIpAddress,
    [Parameter(Mandatory=$false)] [string] $InfraLbIpAddress,
    [Parameter(Mandatory=$true)] [string] $RepoIpAddress,
    [Parameter(Mandatory=$false)] [string] $RegistryPortNumber,
    [Parameter(Mandatory=$true)] [string] $AvailabilitySetPrefix
)

$ShimParams = @{}
$ShimParams.ResourceGroup = $ResourceGroup
$ShimParams.Environment = $Environment
$ShimParams.RegionLocation = $RegionLocation
$ShimParams.RhsmUsernameOrOrgId = $RhsmUsernameOrOrgId
$ShimParams.RhsmPasswordOrActivationKey = $RhsmPasswordOrActivationKey
$ShimParams.RhsmPoolId = $RhsmPoolId
$ShimParams.RepoIpAddress = $RepoIpAddress
$ShimParams.RegistryPortNumber = $RegistryPortNumber
$ShimParams.MasterClusterDns = $MasterClusterDns
$ShimParams.RoutingSubDomain = $RoutingSubDomain
$ShimParams.DeploymentType = $DeploymentType
#Optional Params supplied only for bastionPrep.sh
$ShimParams.AdminUsername = $AdminUsername
$ShimParams.MasterCertType = $MasterCertType
$ShimParams.RoutingCertType = $RoutingCertType
$ShimParams.OpenShiftMinorVersion = $OpenShiftMinorVersion
$ShimParams.DomainName = $DomainName
$ShimParams.MasterClusterDnsType = $MasterClusterDnsType
$ShimParams.RoutingSubDomainType = $RoutingSubDomainType
$ShimParams.MasterPrivateClusterIp = $MasterPrivateClusterIp
$ShimParams.RouterPrivateClusterIp = $RouterPrivateClusterIp

if ($ClusterType -eq "public")
{
    $ShimParams.MasterPrivateClusterIp = $MasterLbIpAddress
    $ShimParams.RouterPrivateClusterIp = $InfraLbIpAddress
}

$ShimParams.MasterCertCaFile = $MasterCertCaFile
$ShimParams.MasterCertCrtFile = $MasterCertCrtFile
$ShimParams.MasterCertKeyFile = $MasterCertKeyFile
$ShimParams.RoutingCertCaFile = $RoutingCertCaFile
$ShimParams.RoutingCertCrtFile = $RoutingCertCrtFile
$ShimParams.RoutingCertKeyFile = $RoutingCertKeyFile
$ShimParams.AvailabilitySetPrefix = $AvailabilitySetPrefix

$Job = 1..5 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            Write-Output "Run bastion prep"
            ./do-prep-shim.ps1 @using:ShimParams `
                -ShortName $using:BastionShortname `
                -InstanceCount 1 `
                -PrepFileName "bastionPrep.sh"
        }
        2 {
            Write-Output "Run master prep"
            ./do-prep-shim.ps1 @using:ShimParams `
                -ShortName $using:MasterShortname `
                -InstanceCount $using:MasterInstanceCount `
                -PrepFileName "masterPrep.sh"
        }
        3 {
            Write-Output "Run infra prep"
            ./do-prep-shim.ps1 @using:ShimParams `
                -ShortName $using:InfraShortname `
                -InstanceCount $using:InfraInstanceCount `
                -PrepFileName "infraPrep.sh"
        }
        4 {
            Write-Output "Run node prep"
            ./do-prep-shim.ps1 @using:ShimParams `
                -ShortName $using:NodeShortname `
                -InstanceCount $using:NodeInstanceCount `
                -PrepFileName "nodePrep.sh"
        }
        5 {
            if ($using:EnableCns)
            {
                Write-Output "Run cns prep"
                #This uses nodeprep.sh
                ./do-prep-shim.ps1 @using:ShimParams `
                    -ShortName $using:CnsShortname `
                    -InstanceCount $using:CnsInstanceCount `
                    -PrepFileName "nodePrep.sh"
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQURIlh6aIhv7Rh51bHsQUD1XsR
# Hp2gggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBSb5dCXJNOFpLPODojtdE4BglNbkjANBgkqhkiG
# 9w0BAQEFAASCAgCbSaM0SCGCyj69+s0mQ5XsqnRogsRe+YHo1e4Zu+np7tWQ6YZc
# 654BBD53CP805P8SOONla7vVQjCwakv2geJCW1vVhflXMOUvP+U2pr8Hiy7L4siK
# SSiLlUK+Q43P3EzBT/LQlSjdPqEEJgRFK5fdWaYWmtQAG7Fsi2+R04DV8pcgY4gK
# OijGemfXfFItVM+BHlTNfecdz5XHGjtArnHbjq1kh7i0X1uLRa0EOiscuQAqtzes
# krZUVxFnsOxfUFFx9FXADyoThmhmJavfE3YmSBnJEYfPO1UEz1qmMqaCY3C1g2Rf
# FmXVu66TEnpR93N1SKsb5AU4h3EMWT9XZyecb+h09FXpaDX8Iz2uQJyqdJt2n+5T
# ya9BkHdcTaidckSPvUxV4TxcKDKwkq0ZjEhquqZHMlv3FoBAVgHxXp6Bg3OxgzdB
# fzi1qT1ZLVnUb79O8Y5xKFxS9vauIUjvozfqu+1KcYshnBNRvyD6Xxk2rMa0mvmq
# G+pXntIRNhDeFJ0r6r2uh6TdoZFTp/wtRALurypcvgWtiwFzwsfc/npLa5CKP5fw
# rmoCiZUG+xhWM6A69Yulr9ocwOh+DAHzfvUYjfOTldl/B5W/fb0BtCeFsKOpipWY
# lRBeYWnOR+YENHhehlOqbhSBHmyXROqK04fIElpfAhH5PiTQaozQOPRMTg==
# SIG # End signature block
