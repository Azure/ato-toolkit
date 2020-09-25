param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [string] $TenantId,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [string] $StorageAccount,
    [Parameter(Mandatory=$true)] [string] $Container,
    [Parameter(Mandatory=$true)] [string] $VhdName,
    [string] $VhdPath = "/repo/"
)

Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$proc = "az"

$VhdPath = "$($(Get-Location).Path)$VhdPath"

Log-Information "Renaming VHD Image"
Move-Item "$($VhdPath)bravo*.vhd" -Destination "$($VhdPath)/$($VhdName)"

./do-confirm-login.ps1 -TenantId $TenantId `
    -SubscriptionId $SubscriptionId `
    -DeploymentType $DeploymentType

Log-Information "Create resource group for upload: $ResourceGroup"
$retVal = Run-Command -Process $proc -Arguments "group create -l `"$AzureLocation`" -n $ResourceGroup -o table"

Log-Information "Creating the storage account"
$retVal = Run-Command -Process $proc -Arguments "storage account create -l `"$AzureLocation`" --resource-group $ResourceGroup -n $StorageAccount --sku Standard_LRS -o table"

Log-Information "Creating the container in the account"
$retVal = Run-Command -Process $proc -Arguments "storage container create --account-name $StorageAccount -n $Container -o table"

if ($DeploymentType -eq [DeploymentType]::DisconnectedStack)
{
    Log-Information "Running in $DeploymentType, need to set an environment variable for the copy to work"
    $env:AZCOPY_DEFAULT_SERVICE_API_VERSION="2017-11-09" #2019-06-01
}

Log-Information "Acquiring the endpoint for copy"
$StorageEndpoint=( az storage account show -n $StorageAccount --query primaryEndpoints.blob -o tsv )
Log-Information "$StorageEndpoint"

Log-Information "Pushing the VHD file into Blob"
$retVal = Run-Command -Process $proc -Arguments "storage copy -s $VhdPath$VHDname -d $StorageEndpoint$Container --recursive --blob-type=PageBlob"

Log-Footer -ScriptName $MyInvocation.MyCommand







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZmQq83UqDR5P/KPlpg4DrpsS
# BZSgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBR9/6/KBJNa43gRj9sOJlxzL6qXkTANBgkqhkiG
# 9w0BAQEFAASCAgBzJ1ngdAafRhPCKaQJoTCzfFvkMtJ00fJYD3Goyk9hBKji2SgJ
# 87zvL9FhMSpslH2Cn8grrBeXeFyv0GBt36Bn/YeNVKZfKtPtoAkFEoHUO0oBYhbO
# 3JkxIQw62ADQISWaN2qw+LXS6GsDbthRpXkui3Q29XwFqfPiDdhbPIzaHapH9WT0
# aF9VM6dkUiFdaWShM7GHxu8/CI8Nubkr3sYGt9mq874jY7t1LB6nYfsAmD5HO1+g
# 3sa4MtXbJdvIW9/52V80KPxOeF3ZD+gpTRgoxtIg2DKEIYvbbBIDLGJmqdoNyINW
# ZWKGZ61qSv8JAAqoAh9kHOiyFRKLoQKP1udjfxb38j7mVzkXTKY2ITP8ZPaeNsje
# j2ySeA96nVvblUKTGAuSoVnE0/Z9RfwSsMfQlbv4IKvaJL4B3RUBfF5hKYCcthYE
# 54m+iPkUIDblRI1xJ5owPWAg+VxI1C1FjvYfHjmXC/RJnIv85wiad8RYC3RYuZaG
# 9M+mbXQnUX/JPRFe9ySL6Dmg3Xw1UAqn3pjoB0S6WifdFbXLa5jhpG31vsb2oeo3
# 0U2J9ptCvAPCNJzMcXw3Z1QroUHINa2SIoiYcJZLnhsM4uE44LoRilK52u1bcPFv
# 1Lri7YBos/sUVpsF9ApAuPBX9JymI7jY8zunaPuJiIFg6/I6CozI+zcoeQ==
# SIG # End signature block
