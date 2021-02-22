param (
    # Mandatory Parameters
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $Environment,
    [Parameter(Mandatory=$true)] [string] $RegionLocation,
    [Parameter(Mandatory=$true)] [string] $ShortName,
    [Parameter(Mandatory=$true)] [string] $RhsmUsernameOrOrgId,
    [Parameter(Mandatory=$true)] [string] $rhsmPasswordOrActivationKey,
    [Parameter(Mandatory=$true)] [string] $RhsmPoolId,
    [Parameter(Mandatory=$true)] [string] $RepoIpAddress,
    [Parameter(Mandatory=$true)] [string] $MasterPrivateClusterIp,
    [Parameter(Mandatory=$true)] [string] $RouterPrivateClusterIp,
    [Parameter(Mandatory=$true)] [string] $MasterClusterDns,
    [Parameter(Mandatory=$true)] [string] $RoutingSubDomain,
    [Parameter(Mandatory=$true)] [string] $PrepFileName,
    [Parameter(Mandatory=$true)] [int] $DeploymentType,
    [Parameter(Mandatory=$true)] [int] $InstanceCount,
    [Parameter(Mandatory=$true)] [string] $AvailabilitySetPrefix,
    # Optional Parameters
    [string] $AdminUsername,
    [string] $MasterCertType,
    [string] $RoutingCertType,
    [string] $RegistryPortNumber,
    [string] $OpenShiftMinorVersion,
    [string] $DomainName,
    [string] $MasterClusterDnsType,
    [string] $RoutingSubDomainType,
    [string] $MasterCertCaFile,
    [string] $MasterCertCrtFile,
    [string] $MasterCertKeyFile,
    [string] $RoutingCertCaFile,
    [string] $RoutingCertCrtFile,
    [string] $RoutingCertKeyFile
)

$prepScriptsPath = "$($(Get-Location).Path)/Ring-0/ocp.3.11/scripts"
$extraScriptsPath = "$($(Get-Location).Path)/Ring-0/extra-scripts"
$certsPath = "$($(Get-Location).Path)/certs"

$jsonFile = "$extraScriptsPath/$ShortName.json"
if (Test-Path $jsonFile)
{
    Remove-Item $jsonFile -Force -Confirm:$false
}
$scriptContent = ((Get-Content "$prepScriptsPath/$PrepFileName") -join "`n")
if($PrepFileName -eq "bastionPrep.sh")
{
    $CustomRoutingCaFile = [string]::Empty
    $CustomRoutingCertFile = [string]::Empty
    $CustomRoutingKeyFile = [string]::Empty
    $CustomMasterCaFile = [string]::Empty
    $CustomMasterCertFile = [string]::Empty
    $CustomMasterKeyFile = [string]::Empty
    if ($MasterCertType -eq "custom")
    {
        $CustomMasterCaFile = ((Get-Content "$certsPath/$MasterCertCaFile") -join "`n")
        $CustomMasterCertFile = ((Get-Content "$certsPath/$MasterCertCrtFile") -join "`n")
        $CustomMasterKeyFile = ((Get-Content "$certsPath/$MasterCertKeyFile") -join "`n")
    }

    if ($RoutingCertType -eq "custom")
    {
        $CustomRoutingCaFile = ((Get-Content "$certsPath/$RoutingCertCaFile") -join "`n")
        $CustomRoutingCertFile = ((Get-Content "$certsPath/$RoutingCertCrtFile") -join "`n")
        $CustomRoutingKeyFile = ((Get-Content "$certsPath/$RoutingCertKeyFile") -join "`n")
    }

    $scriptContent = $scriptContent.Replace("`${USERNAME_ORG}", "$RhsmUsernameOrOrgId")
    $scriptContent = $scriptContent.Replace("`${PASSWORD_ACT_KEY}", "$RhsmPasswordOrActivationKey")
    $scriptContent = $scriptContent.Replace("`${POOL_ID}", "$RhsmPoolId")
    $scriptContent = $scriptContent.Replace("`${SUDOUSER}", "$AdminUsername")
    $scriptContent = $scriptContent.Replace("`${CUSTOMROUTINGCAFILE}", "$CustomRoutingCaFile")
    $scriptContent = $scriptContent.Replace("`${CUSTOMROUTINGCERTFILE}", "$CustomRoutingCertFile")
    $scriptContent = $scriptContent.Replace("`${CUSTOMROUTINGKEYFILE}", "$CustomRoutingKeyFile")
    $scriptContent = $scriptContent.Replace("`${CUSTOMMASTERCAFILE}", "$CustomMasterCaFile")
    $scriptContent = $scriptContent.Replace("`${CUSTOMMASTERCERTFILE}", "$CustomMasterCertFile")
    $scriptContent = $scriptContent.Replace("`${CUSTOMMASTERKEYFILE}", "$CustomMasterKeyFile")
    $scriptContent = $scriptContent.Replace("`${CUSTOMROUTINGCERTTYPE}", "$RoutingCertType")
    $scriptContent = $scriptContent.Replace("`${CUSTOMMASTERCERTTYPE}", "$MasterCertType")
    $scriptContent = $scriptContent.Replace("`${CUSTOMDOMAIN}", "$DomainName")
    $scriptContent = $scriptContent.Replace("`${MINORVERSION}", "$OpenShiftMinorVersion")
    $scriptContent = $scriptContent.Replace("`${CUSTOMMASTERTYPE}", "$MasterClusterDnsType")
    $scriptContent = $scriptContent.Replace("`${CUSTOMROUTINGTYPE}", "$RoutingSubDomainType")
    $scriptContent = $scriptContent.Replace("`${REPOSERVER}", "$RepoIpAddress")
    $scriptContent = $scriptContent.Replace("`${PRIVATEIP}", "$MasterPrivateClusterIp")
    $scriptContent = $scriptContent.Replace("`${ROUTERIP}", "$RouterPrivateClusterIp")
    $scriptContent = $scriptContent.Replace("`${PRIVATEDNS}", "$MasterClusterDns")
    $scriptContent = $scriptContent.Replace("`${INFRADNS}", "$RoutingSubDomain")
    $scriptContent = $scriptContent.Replace("`${DEPLOYMENTTYPE}", "$([int]$DeploymentType)")
    $scriptContent = $scriptContent.Replace("`${REGISTRYSERVER}", "$RepoIpAddress$RegistryPortNumber")
}
else
{
    $scriptContent = $scriptContent.Replace("`${USERNAME_ORG}", "$RhsmUsernameOrOrgId")
    $scriptContent = $scriptContent.Replace("`${PASSWORD_ACT_KEY}", "$rhsmPasswordOrActivationKey")
    $scriptContent = $scriptContent.Replace("`${POOL_ID}", "$RhsmPoolId")
    $scriptContent = $scriptContent.Replace("`${REPOSERVER}", "$RepoIpAddress")
    $scriptContent = $scriptContent.Replace("`${REGISTRYSERVER}", "$RepoIpAddress$RegistryPortNumber")
    $scriptContent = $scriptContent.Replace("`${PRIVATEIP}", "$MasterPrivateClusterIp")
    $scriptContent = $scriptContent.Replace("`${ROUTERIP}", "$RouterPrivateClusterIp")
    $scriptContent = $scriptContent.Replace("`${PRIVATEDNS}", "$MasterClusterDns")
    $scriptContent = $scriptContent.Replace("`${INFRADNS}", "$RoutingSubDomain")
    $scriptContent = $scriptContent.Replace("`${DEPLOYMENTTYPE}", "$([int]$DeploymentType)")
}

$scriptInBytes = [System.Text.Encoding]::UTF8.GetBytes($scriptContent)
$encodedScript = [Convert]::ToBase64String($scriptInBytes)
Set-Content -Path $jsonFile -Value "{`"script`": `"$encodedScript`"}"

$logDate = $(Get-Date -format "yyyy-MM-dd-HHmmss")

1..$InstanceCount | ForEach-Object -Parallel {
    $LogFile = "./deployment-output/vm-prep-arm-$($using:ShortName)_$($_)_$using:logDate.log"
    Set-LogFile -LogFile $LogFile
    $n = ([string]$_).PadLeft(3,"0")

    $machineName = "$using:AvailabilitySetPrefix-$using:ShortName-$($n)v"
    $existingExtensions = az vm extension list -g $using:ResourceGroup --vm-name $machineName -o json | ConvertFrom-Json

    Log-Information "Found $($existingExtension.Count) existing extensions."
    for ($i = 0; $i -lt $existingExtensions.Count; $i++) {
        $ext = $existingExtensions[$i]
        $argList = "vm extension delete " +
                    "-g $using:ResourceGroup " +
                    "--vm-name $machineName " +
                    "--name $($ext.Name)"

        Run-Command -Process "az" -Arguments $argList
    }

    Start-Sleep -Seconds 15

    $argList = "vm extension set " +
                "-g $using:ResourceGroup " +
                "--vm-name $machineName " +
                "--extension-instance-name prep " +
                "--name customScript " +
                "--publisher Microsoft.Azure.Extensions " +
                "--settings $using:jsonFile"

    Run-Command -Process "az" -Arguments $argList

    # potential workaround for thread locks
    Start-Sleep -Seconds 5
} -AsJob -ThrottleLimit 5 | Receive-Job -Wait







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqAGKtC/0TOXYaQZvlDCKTbf4
# 4PWgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBRCD1Fr6EFWNzHr8hNYaR8OccaMRjANBgkqhkiG
# 9w0BAQEFAASCAgBrp7PZN/Gn0UGkJ5MgL7g4K7zegWkgceF+3TvSjml0io0N42Ku
# 1p+WShtE0VHZZ0b4ae7dDedIWrUuDJeT62VCT7O4jf71pc0YArJfrz3wP006QVcH
# JX2JAkYcwsLDRpaCfP+ZhVLsK2Kjsq1lUUnzUW/3YyTBXgwXF7vYAU3iVx09wAIx
# DAzwuDZ0c+TwIpE2HSabpl1i2WNToTxuXfdDvdMsLgMD5gCV+GrvFWqXplj9p4uO
# WSNCJ1ShpHblvEQMN7cs76lp1RodKHyPJZ6haLwNjQR4a4Y2QZ5CSn1K8KhNlNVi
# ivyYWdhwTC7x08tSxbRTJ9LXeBO7NVofbIvZQSIWng9u3XPMTIU/yqT6aVd3iFKc
# L9WsYmfcL7TPNHTtkKR8DCXEVh8UGljpkbrJbq90Oy5cqMpJR1BepdAjwN0k1R/y
# yFgB2z7NkSUWnXTNIdXySqkD5F4FJk7L5bfDy0KbuqvBho2lqDghE9pFZDjHAQg8
# wZlp0b6AVyuRT8aq8H5klCCXSvMzQOyYlW+lID9bwp/UMABNx6yvUJj21Gl9ZfJN
# M8dtvEy2OdX/YYF7CC1MGk3syNwPT7w1Ca2isUyRkPQ+1SCfi4KSBFawuXvLopX+
# rixNq+9w/fFnBFlCfVJAUQVi0EnwrMvXtyjS/Ymutaaelvjcl3MkP24OQA==
# SIG # End signature block
