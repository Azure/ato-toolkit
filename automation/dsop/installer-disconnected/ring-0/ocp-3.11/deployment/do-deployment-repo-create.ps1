param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [string] $StorageAccount,
    [Parameter(Mandatory=$true)] [string] $Container,
    [Parameter(Mandatory=$true)] [string] $VhdName,
    [Parameter(Mandatory=$true)] [string] $VmName,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$true)] [string] $VirtualNetworkResourceGroup,
    [Parameter(Mandatory=$true)] [string] $VirtualNetworkName,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [string] $MasterInfraSubnetName
)

Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$proc = "az"

[string] $SshKeyPath = "./certs/$SshKey"
Log-Information "Verifying the ssh key $SshKeyPath exists"
if (-not (Test-Path $SshKeyPath))
{
    Log-Error "The ssh key was not found ($SshKeyPath)"
    throw
}

Log-Information "Create resource group for upload: $ResourceGroup"
$retVal = Run-Command -Process $proc -Arguments "group create -l `"$AzureLocation`" -n $ResourceGroup -o table"

Log-Information "Get endpoint to use for the image"
$StorageEndpoint=( az storage account show -n $StorageAccount --query primaryEndpoints.blob -o tsv )
Log-Information "$StorageEndpoint"

Log-Information "Create the image"
$argList = "image create " +
    "--resource-group $ResourceGroup " +
    "--location `"$AzureLocation`" " +
    "--name $VmName " +
    "--os-type linux " +
    "--source $StorageEndpoint$Container/$VhdName " +
    "--os-disk-caching ReadWrite " +
    "-o table"
$retVal = Run-Command -Process $proc -Arguments $argList

$PublicIpAddress = '""'
$AuthType = "ssh"
if ($DeploymentType -eq [DeploymentType]::DisconnectedLite)
{
    Log-Information "Create the VM with emulated subnet"
    $argList = "vm create " +
        "-g $ResourceGroup " +
        "-n $VmName " +
        "--location `"$AzureLocation`" " +
        "--image $VmName " +
        "--admin-username $AdminUsername " +
        "--public-ip-address $PublicIpAddress " +
        "--authentication-type $AuthType " +
        "--subnet `"/subscriptions/$SubscriptionId/resourceGroups/$VirtualNetworkResourceGroup/providers/Microsoft.Network/virtualNetworks/$VirtualNetworkName/subnets/Combine-Private-C`" " +
        "--generate-ssh-keys " +
        "-o table"
    $retVal = Run-Command -Process $proc -Arguments $argList
}
elseif(($DeploymentType -eq [DeploymentType]::DisconnectedStack) -or ($DeploymentType -eq [DeploymentType]::Disconnected))
{
    Log-Information "Create the VM with emulated subnet"
    $argList = "vm create " +
        "-g $ResourceGroup " +
        "-n $VmName " +
        "--location `"$AzureLocation`" " +
        "--image $VmName " +
        "--admin-username $AdminUsername " +
        "--public-ip-address $PublicIpAddress " +
        "--authentication-type $AuthType " +
        "--subnet `"/subscriptions/$SubscriptionId/resourceGroups/$VirtualNetworkResourceGroup/providers/Microsoft.Network/virtualNetworks/$VirtualNetworkName/subnets/$MasterInfraSubnetName`" " +
        "--generate-ssh-keys " +
        "-o table"
    $retVal = Run-Command -Process $proc -Arguments $argList
}
# Give the machine 30 seconds to finish with ssh before we change it.
# Stack had an issue so we had to do this update because of that.
Start-Sleep -Seconds 120

Log-Information "Set the vm ssh key user"
$argList = "vm user update " +
    "--resource-group $ResourceGroup " +
    "--name $VmName " +
    "--username $AdminUsername " +
    "--ssh-key-value $SshKeyPath " +
    "-o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Footer -ScriptName $MyInvocation.MyCommand







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUaTJ99AgZ/GQfnzX4TRk0hGGI
# kn6gggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBQ6wVzsFTtKnbymzbzP//wiuXs/RTANBgkqhkiG
# 9w0BAQEFAASCAgBe2RtMGA0ju6EBsfEpKeiFpdFIs6fPN8VhSkT7gox+HM0URT8X
# B8QYpRS+REbWucQ/SKkSKWMMoJBofDG1lgZ77KW5rtYBwAIS/5zWc+MWjo+LoLZY
# T6dhGzzPubd7EGgr2CazWbUOfNyi1jBqB6x96qRa6QeRu9J+z+zYUwBAwD32dD6o
# ghkVX7gDHG4tnNzbA8culzBCXJiA0GrxtJAileGAUyIUp7y8NEYqf8ybqEUB56uV
# xbxASLH4/X4WhR9uQAeU3cGHo2/Aj81DJ3TzSEmV+vtsMvH2+zx8JecGptxF60Ai
# vgeMC5TJIYLuFy65g0pJsPNA3NVxlInFu1urznOVK5zE0VUU+0F7fXnLmuErf7gQ
# obBcKSBmSomUX3cwnQRqFI7SfuWrTlM3arOcpsO7hSYDt5vbdX1wTjqfAbnLZbV5
# K0yTToe1Kncp84j7LWElQOT6a/dBN1guKK2L9QpWaD6oDhQW7kIeLIexrfEIhgHE
# F0zWljbtW3nPEAB/80wZ55WKKRXjTgEnjtrJeoJkpGeKFhkiYmo0vZXRxrlD7l6X
# nJVtRAV4WN6qWO8e6zE+f7mioIil4uJeB/+pEo2h5IZAQbtjwIdmeIdML3a83Rly
# kVSg8bIwFmRf9hyT9iR0qfI+MYkAAS4B+W5CRTBWEgHXbWMHLeWNf2zzDg==
# SIG # End signature block
