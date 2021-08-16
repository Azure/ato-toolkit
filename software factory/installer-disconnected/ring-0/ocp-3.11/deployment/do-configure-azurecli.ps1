# this needs to be done when the value is something like what azure stack uses
# https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-version-profiles-azurecli2?view=azs-1910#connect-to-azure-stack-hub
param (
    [parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [parameter(Mandatory=$true)] [string] $AzureCloud,
    [parameter(Mandatory=$true)] [string] $AzureDomain,
    [parameter(Mandatory=$true)] [string] $AzureProfile
)

Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$proc = "az"

if ($DeploymentType -eq [DeploymentType]::DisconnectedStack)
{
    Log-Information "Checking if the Azure Location is registered"
    $AzureCloudRegistration=(az cloud list --query "[?name=='$AzureCloud']" -o json ) | ConvertFrom-Json
    if ($AzureCloudRegistration.count -ge 1)
    {
        Log-Information "Registration found"
        if ($AzureCloudRegistration.IsActive)
        {
            Log-Information "Setting the active cloud to Azure to prep for removal"
            $argList = "cloud set -n AzureCloud -o table"
            $retVal = Run-Command -Process $proc -Arguments $argList
        }
        Log-Information "Removing registration"
        $argList = "cloud unregister -n $AzureCloud -o table"
        $retVal = Run-Command -Process $proc -Arguments $argList
    }

    # az cli has certs that need to be setup in a proxy situation (like Seq)
    # If you append to the existing certs from docs for linux/windows respectively then it will work
    # https://github.com/Azure/azure-cli/blob/dev/doc/use_cli_effectively.md#working-behind-a-proxy

    Log-Information "Registering the Azure CLI location $AzureCloud"
    # az cloud register -n AzSeq --endpoint-resource-manager "https://usseceast.management.azure.microsoft.scloud" --endpoint-management "https://management.core.microsoft.scloud" `
    #    --endpoint-active-directory "https://login.microsoftonline.microsoft.scloud/" `
    #    --endpoint-active-directory-graph-resource-id "https://graph.microsoft.scloud/" `
    #    --endpoint-active-directory-resource-id "https://management.azure.microsoft.scloud/" `
    #    --suffix-storage-endpoint "core.microsoft.scloud" --suffix-keyvault-dns ".vault.core.microsoft.scloud"
    #    --endpoint-vm-image-alias-doc "https://deveastocpst001.blob.core.microsoft.scloud/filesbl/aliases.json"
    $argList = "cloud register " +
                "-n $AzureCloud " +
                "--endpoint-resource-manager `"https://management.$AzureDomain`" " +
                "--suffix-storage-endpoint $AzureDomain " +
                "--suffix-keyvault-dns `".vault.$AzureDomain`" " +
                "--endpoint-vm-image-alias-doc `"https://raw.githubusercontent.com/Azure/azure-rest-api-specs/master/arm-compute/quickstart-templates/aliases.json`" " +
                "-o table"
                $retVal = Run-Command -Process $proc -Arguments $argList

    # $AzureDomain = "microsoft.scloud"
    # $AzureDomain = "ppe4.stackpoc.com"
}

Log-Information "Setting to cloud $AzureCloud"
$argList = "cloud set -n $AzureCloud -o table"
$retVal = Run-Command -Process $proc -Arguments $argList

if ($DeploymentType -eq [DeploymentType]::DisconnectedStack)
{
    Log-Information "Updating the Azure CLI profile"
    $argList = "cloud update --profile $AzureProfile -o table"
    $retVal = Run-Command -Process $proc -Arguments $argList
}

Log-Footer -ScriptName $MyInvocation.MyCommand







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUNoZ6k9ybBsiZ78YJa0NmEQ9A
# 3iagggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBSMYiL/jdQAB95M6+pbXiy6E6YelTANBgkqhkiG
# 9w0BAQEFAASCAgCaiKxlgsB7z1Ipknyy/eookylJbkr/0+d1tLSw4B/lvvIAuJgX
# tmHdlTHl3uaL/RW8sQiG6PxDvYWpjptt6bccPIjb9av26KBgzCviRFMrFQN1Zput
# Bagf0URiPPQ+pOmqfnOpnQi7urGRCdv11sS5IEGirEdT1p9hOGUKDnGPxClfUk2j
# Glk12ZnXyBOJq/t1ELjl34QpavlgoaZv2Xo+jiE3uWxbO/rHgF2A8h25GEZm4+Do
# 73xGZWgxaZG0IYEznV6hwu/hGLRidJTc3bChrQTsVyKTbYxHkMFFJEH+tRNJWjsw
# QNPMKgjgdW29ZYlovmbq3xjkgMOVSV4+ABUi+y2AlUB0A7VNtGvBKF21Tdl5RzAD
# FBOb/w22AuMT3tJPz2wgw8E6/UDffONlmWmasvZiI8KANLXcfIdFT8wjs75/Jfaf
# 8ag2Q4Vx6pyV811dzMgNBl3ULcgcBV2003C3zxCbYFQ+Z1sq1sNob0n8Ivxi+lkk
# IrSgZQeReQxN5/ekGsXOCZo1TQEVhk6++fNYe73YtPDXmwo+nYafc3Hks868AMlq
# 0+3nl/D+aXBXtC3MKgDgImu6b7FpaBqWvn7fd1V67DPbiAAR7HLEb9l5vYFe6lZV
# M1A4ZjO33vWrFYbL0F86J9WVLlwLq612Lozw+bHpTKb3upP04SI13l7lsw==
# SIG # End signature block
