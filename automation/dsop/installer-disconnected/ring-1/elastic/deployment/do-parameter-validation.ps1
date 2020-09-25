

Log-Information "Validating deployment..."
# certificate file path
If ((Test-Path $pathToCert -PathType Leaf) -ne $true) {
    Log-Information ".pfx certificate not found at the specified location" -ForegroundColor Red
    $exit = $true
} 
Else {Log-Information "Certificate file path OK"}
# elasticsearch vm size
If ((az vm list-sizes --location eastus | Select-String -pattern "$elasticVmSize") -eq "") {
    Log-Information "The VM size $elasticVmSize specified for Elasticsearch is not available in the region $location" -ForegroundColor Red
    $exit = $true
}
Else {Log-Information "Elasticsearch machine size SKU OK"}
# tenant name
If ((az account list | Select-String -pattern "$tenant") -eq "") {
    Log-Information "The tenant $tenant was not found" -ForegroundColor Red
    $exit = $true
}
Else {Log-Information "Tenant name OK"}
# region/location
If ((az account list-locations | Select-String -pattern "$location") -eq "") {
    Log-Information "The location $location was not found" -ForegroundColor Red
    $exit = $true
}
Else {Log-Information "Region OK"}
# resource group
If ((az group exists --name $resourceGroupName) -eq $false) {
    Log-Information "The resource group $resourceGroupName was not found" -ForegroundColor Red
    $exit = $true
}
Else {Log-Information "Resource group OK"}
# vnet
If ((az network vnet list -g $resourceGroupName | Select-String -pattern "$vnetName") -eq "") {
    Log-Information "The vnet $vnetName was not found" -ForegroundColor Red
    $exit = $true
}
Else {Log-Information "Vnet OK"}
# cluster subnet
$addressRange = $string = $clusterSubnetRange.Substring(0,$clusterSubnetRange.Length-3)
$result = az network vnet subnet list -g $resourceGroupName --vnet-name $vnetName | Select-String -pattern "$addressRange"
If (($result) -like "*$addressRange*") {
    Log-Information "The address range $clusterSubnetRange for the Elasticsearch cluster subnet is not available" -ForegroundColor Red
    $exit = $true
}
# appgw subnet
$addressRange = $string = $gatewaySubnetRange.Substring(0,$gatewaySubnetRange.Length-3)
$result = az network vnet subnet list -g $resourceGroupName --vnet-name $vnetName | Select-String -pattern "$addressRange"
If (($result) -like "*$addressRange*") {
    Log-Information "The address range $gatewaySubnetRange for the application gateway subnet is not available" -ForegroundColor Red
    $exit = $true
}
If ($exit -eq $true) {
    Read-Host -prompt "`n`nValidation failed due to one or more errors. Press ENTER to exit"
    exit
}
Else {
    Read-Host -Prompt "Validation passed. Press ENTER to continue"
}







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUGdpgXNvu7T9iMcbKqJNUvK7S
# m5KgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBRJA2/NwySo7uphi673Errs/sdYejANBgkqhkiG
# 9w0BAQEFAASCAgBvTS2Oounc4vU6B6C0B9hD4l+ZALL5tJwMP8o/K+h36L8x0qCX
# QC4q4gHHV9KaOVOfc5xItoaUx3y1bkpQpWrCxWzHbwpafxCtAhThSLFpiAp6X9p2
# JM/TH7Ye4xiSKRbcBXsKLcilVW80IhkFqc/PRp1IYy89z+zpRxlbLSXpf5YvJRW/
# YHwokccgUnVLcYHFyz8dYdgtXFHMnrMYp2BC2a7JuU810QpULLlCkkkeBm7hDBbz
# Oif2UxtkO19JTLtpOAOJWBxpWTJtZMMSDHJUo+3/KKOmv/BWJ6ue5hYFKzc9Eu1a
# uF0aMwe633ioHdEJ/IYRX6/5ViorwUJ4sIQMr6dKsGq6tSLpQl59gpudpoQb2twI
# zTHPgNOet4ak1sBz1DMB/cQgztrUUMacQ3aUx79Q+t189fMWRZZLNGtL4fN5jKSx
# cqkIv4Qhlz/2x4IrgLqo55hQDijaxoYX8cYJYUpzqsMvx3/mueL0NhIBGUvWzlcD
# VFihTs0ZyKXyu84fN6Ow0C6Nj9yFYX4k2JhEPSQcbpvzfppOiQBR3+EnYUb23hEJ
# zMiss0MjRclYpGpsAd1FVRqcXsEq3KmCDmoFgmYVYhUlHzi9GYLUgl47tgd+DIyG
# IdGoz0wIwT4mACZaiibOFyXUYLXDo6omhchTXejT0f7W7lHKbfA+6Z4z/w==
# SIG # End signature block
