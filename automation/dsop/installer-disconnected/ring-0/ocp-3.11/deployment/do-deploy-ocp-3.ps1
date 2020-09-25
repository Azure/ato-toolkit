param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $OpenshiftPassword,
    [Parameter(Mandatory=$true)] [string] $BastionMachineName,
    [Parameter(Mandatory=$true)] [string] $MasterHostname,
    [Parameter(Mandatory=$true)] [string] $MasterClusterDns,
    [Parameter(Mandatory=$true)] [string] $InfraHostname,
    [Parameter(Mandatory=$true)] [string] $NodeHostname,
    [Parameter(Mandatory=$true)] [int] $nodeInstanceCount,
    [Parameter(Mandatory=$true)] [int] $InfraInstanceCount,
    [Parameter(Mandatory=$true)] [int] $MasterInstanceCount,
    [Parameter(Mandatory=$true)] [int] $CnsInstanceCount,
    [Parameter(Mandatory=$true)] [string] $RoutingSubDomain,
    [Parameter(Mandatory=$true)] [string] $EnableMetrics,
    [Parameter(Mandatory=$true)] [string] $EnableLogging,
    [Parameter(Mandatory=$true)] [string] $TenantId,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $EnableAzure,
    [Parameter(Mandatory=$true)] [string] $EnableCns,
    [Parameter(Mandatory=$true)] [string] $CnsHostname,
    [Parameter(Mandatory=$true)] [string] $OpenShiftRegistry,
    [Parameter(Mandatory=$true)] [string] $ClusterType,
    [Parameter(Mandatory=$true)] [string] $MasterPrivateClusterIp,
    [Parameter(Mandatory=$true)] [int] $OpenShiftMinorVersion,
    [Parameter(Mandatory=$true)] [string] $InternalEndpoint,
    [Parameter(Mandatory=$true)] [string] $RoutingCertType,
    [Parameter(Mandatory=$true)] [string] $MasterCertType,
    [Parameter(Mandatory=$false)] [string] $MasterLbIpAddress,
    [Parameter(Mandatory=$false)] [string] $InfraLbIpAddress,
    [Parameter(Mandatory=$true)] [string] $RepoIpAddress,
    [Parameter(Mandatory=$false)] [string] $RegistryPortNumber
)

Log-Information "Deploy OpenShift 3.11"
$scriptsPath = "$($(Get-Location).Path)/Ring-0/ocp.3.11/scripts"
$scriptFile = "deployOpenShift.sh"

$OpenShiftRegistryKey = az storage account keys list -n $OpenShiftRegistry -o tsv --query "[?keyName=='key1'].value"

$scriptContent = ((Get-Content "$scriptsPath/$scriptFile") -join "`n")

$scriptContent = $scriptContent.Replace("`${SUDOUSER}", "$AdminUsername")
$scriptContent = $scriptContent.Replace("`${PASSWORD}", "$OpenshiftPassword")
$scriptContent = $scriptContent.Replace("`${MASTER}", "$MasterHostname")
$scriptContent = $scriptContent.Replace("`${MASTERPUBLICIPHOSTNAME}", "$MasterLbIpAddress.nip.io")
$scriptContent = $scriptContent.Replace("`${MASTERPUBLICIPADDRESS}", $MasterLbIpAddress)
$scriptContent = $scriptContent.Replace("`${INFRA}", "$InfraHostname")
$scriptContent = $scriptContent.Replace("`${NODE}", "$NodeHostname")
$scriptContent = $scriptContent.Replace("`${NODECOUNT}", "$nodeInstanceCount")
$scriptContent = $scriptContent.Replace("`${INFRACOUNT}", "$InfraInstanceCount")
$scriptContent = $scriptContent.Replace("`${MASTERCOUNT}", "$MasterInstanceCount")

if ($ClusterType -eq "public")
{
    $scriptContent = $scriptContent.Replace("`${ROUTING}", "$InfraLbIpAddress.nip.io")
}
else
{
    $scriptContent = $scriptContent.Replace("`${ROUTING}", "$RoutingSubDomain")
}

$scriptContent = $scriptContent.Replace("`${METRICS}", "$EnableMetrics")
$scriptContent = $scriptContent.Replace("`${LOGGING}", "$EnableLogging")
$scriptContent = $scriptContent.Replace("`${TENANTID}", "$TenantId")
$scriptContent = $scriptContent.Replace("`${SUBSCRIPTIONID}", "$SubscriptionId")
$scriptContent = $scriptContent.Replace("`${LOCATION}", "$AzureLocation")
$scriptContent = $scriptContent.Replace("`${RESOURCEGROUP}", "$ResourceGroup")
$scriptContent = $scriptContent.Replace("`${AZURE}", "$EnableAzure")
$scriptContent = $scriptContent.Replace("`${ENABLECNS}", "$EnableCns")
$scriptContent = $scriptContent.Replace("`${CNS}", "$CnsHostname")
$scriptContent = $scriptContent.Replace("`${CNSCOUNT}", "$CnsInstanceCount")
$scriptContent = $scriptContent.Replace("`${REGISTRYSA}", "$OpenShiftRegistry")
$scriptContent = $scriptContent.Replace("`${ACCOUNTKEY}", "$OpenShiftRegistryKey")
$scriptContent = $scriptContent.Replace("`${MASTERCLUSTERTYPE}", "$ClusterType")
$scriptContent = $scriptContent.Replace("`${PRIVATEIP}", "$MasterPrivateClusterIp")
$scriptContent = $scriptContent.Replace("`${PRIVATEDNS}", "$MasterClusterDns")
$scriptContent = $scriptContent.Replace("`${MINORVERSION}", "$OpenShiftMinorVersion")
$scriptContent = $scriptContent.Replace("`${REPOSERVER}", "$RepoIpAddress")
$scriptContent = $scriptContent.Replace("`${REGISTRYSERVER}", "$RepoIpAddress$RegistryPortNumber")
$scriptContent = $scriptContent.Replace("`${DEPLOYMENTTYPE}", "$([int]$DeploymentType)")
$scriptContent = $scriptContent.Replace("`${DOCKERREGISTRYREALM}", "$InternalEndpoint")
#Potential optional later
$scriptContent = $scriptContent.Replace("`${CUSTOMROUTINGCERTTYPE}", "$RoutingCertType")
$scriptContent = $scriptContent.Replace("`${CUSTOMMASTERCERTTYPE}", "$MasterCertType")
# Removed for not currently in use:
# ---------------------------------
# when azure is setup to true the below are used : "AZURE=true" `
# *************
#   "VNETNAME=$VirtualNetworkName" `
#   "NODENSG=$NodeHostname-NSG" `
#   "NODEAVAILIBILITYSET=$nodeAvailabilitySet" ``
#   "AADCLIENTID=$aadClientId" `
#   "AADCLIENTSECRET=$aadClientSecret" `
# *************
# OTHER UNUSED:
# *************
#   "STORAGEKIND=$storageKind"
#   "MASTERPIPNAME=$masterPublicIpName" `

$scriptInBytes = [System.Text.Encoding]::UTF8.GetBytes($scriptContent)
$encodedScript = [Convert]::ToBase64String($scriptInBytes)
$jsonFile = "$scriptsPath/deployOpenShift.json"
Set-Content -Path $jsonFile -Value "{`"script`": `"$encodedScript`"}"

$existingExtensions = az vm extension list -g $ResourceGroup --vm-name $BastionMachineName -o json | ConvertFrom-Json

for ($i = 0; $i -lt $existingExtensions.Count; $i++) {
    $ext = $existingExtensions[$i]
    $argList = "vm extension delete " +
                "-g $ResourceGroup " +
                "--vm-name $BastionMachineName " +
                "--name $($ext.Name)"

    $retVal = Run-Command -Process az -Arguments $argList
}

$argList = "vm extension set " +
            "-g $ResourceGroup " +
            "--vm-name $BastionMachineName " +
            "--extension-instance-name deployOpenshift " +
            "--name customScript " +
            "--publisher Microsoft.Azure.Extensions " +
            "--settings $jsonFile"

$retVal = Run-Command -Process az -Arguments $argList








# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUW/PmL4eKZk7E43S7xeWNZoL4
# s+SgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBQBYy4FaL8ADZEzxpJHHKSGnmxgIDANBgkqhkiG
# 9w0BAQEFAASCAgB0/yZjUj4symNVAzDQVi+69YxJEStqP9M9jTnyUdbeHwtFwgC1
# pOmWnCgsKbyLcjHjwbBcAPK8YGQ1zFOhGyqO+6LXslVvJiOUZJtqXA8AaPS32HeC
# OFKNjlC3SyKR+o7wG6fWiqG3Yq+GWhJ3tuYq85tZhrTr2mcwX+ppRilXkmhcbwkR
# 7K/fAbRfZ1kgz+5Ky8Z5A6mk/gbW2bZNgWp/vbUVt53HxJhYQ+FOnRzjN3ep9foe
# wzJuhQRyGSuSMSSgLD44V6OrHRVgAldS/h1HEgUOetyv7L6EmQf9/p8Iv6VwNdc7
# O7fdsvnI+ptq9Cv/9K35OCGGnuikj8Upsyz+EVl2ts/XjdQKvCnG36jQFTld2Na4
# i1odt45d15920j5dcex8kObc3ZgE8Ct9hIerePx3U6FItOxtgDYvZbujZczn4bpn
# CZSyZN19AbtsKJpJkSARxrjPEhk15NW9Ul01VL3QSCmuGahc1pYFKhMNccCaZQAR
# hDMR4kleIYlNtaVO1IILGhlcmFxB++qTVZB4JGEXWqvhiITsyEfFVORto3yciL5k
# OF+Mo+cgkI4WP2n1FfqyFbj6Tx/mLUBxBR9SD3UA8urlHaEjlrYFFpgKdZoYLnwy
# k8dR9/4b4VkxhmV9j477rABHs06QAq2R6SEJDQ0N+UTPdaOAz+ZUu/4nkQ==
# SIG # End signature block
