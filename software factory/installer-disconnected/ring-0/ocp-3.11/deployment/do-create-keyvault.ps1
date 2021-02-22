param (
    [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $ResourceGroup,
    [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $AzureLocation,
    [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $KeyVaultName,
    [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $OpenShiftPassword,
    [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $RhsmPasswordOrActivationKey,

    [ValidateNotNullOrEmpty()]
    [string] $AadClientSecret = "WeDontCareRightNow",

    [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()] [string] $SshPrivateKey
)

Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$proc = "az"

Log-Information "Create resource group for KeyVault: $ResourceGroup"
$argList = "group create -l `"$AzureLocation`" -n $ResourceGroup -o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Information "Checking for soft-deleted keyvault with the name, $KeyVaultName"

$softDeletedKeyvault = (az keyvault list-deleted --query "[?name == '$KeyVaultName'].name" -o tsv)
if ($softDeletedKeyvault)
{
    Log-Information "Found a soft-deleted keyvault, $softDeletedKeyvault.  Purging keyvault"
    $argList = "keyvault purge --name $KeyVaultName"
    $retVal = Run-Command -Process $proc -Arguments $argList

    if ($retVal -ne 0)
    {
        Log-Error "There was an error purging the keyvault, $KeyVaultName"
        throw
    }
    else 
    {
        Log-Information "Successfully purged the keyvault, $KeyVaultName"
    }
}

Log-Information "Create the KeyVault"

$argList = "keyvault create -l `"$AzureLocation`" -n $KeyVaultName -g $ResourceGroup --enabled-for-template-deployment true --enabled-for-deployment true -o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Information "Add secret for openshiftpassword"
$argList = "keyvault secret set --vault-name $KeyVaultName -n openshiftPassword --value $OpenShiftPassword -o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Information "Add secret for redhat subscription"
$argList = "keyvault secret set --vault-name $KeyVaultName -n rhsmPasswordOrActivationKey --value $RhsmPasswordOrActivationKey -o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Information "Add secret for AAD"
$argList = "keyvault secret set --vault-name $KeyVaultName -n aadClientSecret --value $AadClientSecret -o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Information "Add secret for sshPrivateKey"
$argList = "keyvault secret set --vault-name $KeyVaultName -n sshPrivateKey --file `"$($(Get-Location).Path)/certs/$SshPrivateKey`" -o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-Footer -ScriptName $MyInvocation.MyCommand







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9QVMrk/DXf42UqsAXIm6JsJJ
# 3gmgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBQTYBruupzWt5f73sw/8HjXMZUs7jANBgkqhkiG
# 9w0BAQEFAASCAgAlBP+KcMfoIVu5gpg0hJty6pNurkuLFpJtI41rUkE1ifEoOURD
# JakhvEaFjFw7anb3zUbPP+LAvoC1v61OgexOgqVrM3a2B8/EypkMjFcBqKj4z5Iz
# zBhtVAhr+IvR3gsMuPoyELTKVl0EH0alEfo4e+YMH+MKKHpqaKdONS+b3B3Q0HeP
# 7O63RSIK6slxFWn9yatGjHFDhXiBPgQj63d266QqKMjXu6V42hYn6M9NiRTJO/ui
# J9T2CkmfStPtHRbtR3hXzyf+1OLfTabCUMLBnNOY1ZbCBd7RVPLgzKqV4/cFV1ut
# LcsXhNGl7bfOvi6Wj+Fsjmen8dAQRn+vhb8lNEwqVxR+UeN3/9qfmCu1Z2PhsJOc
# gGfwpcgZw62fLy6Jj7ie2+ErSXMpo+j+N1kxtemgqMXAULIbF1HHKNdklB1XMQ6K
# ab9BJZsNNRJ2ht+z19eK0uajSAVnZGJh62VP2cZkPnyE1W5y4uzExLjhBqk/Vpgq
# Jx/faEoQM7+h0kwwccRrSECcS+kgGvN400TfpNH/lUJ01uZBWu98HEUoGyvvUGIN
# AllDqhVHAAkQEXGWKkWIJgv4aQj4gd3ns5zL26Wgc/msE810LQwQr/duoD8DIBN5
# MMlEUXnChtUlLr6Cc9rTW+605oK066t1k/ALjbP1WZdbHHbWlV1qVNbHnQ==
# SIG # End signature block
