param (
    [Parameter(Mandatory=$true)] [string] $OsImageType,
    [Parameter(Mandatory=$true)] [string] $UploadVhd,
    [Parameter(Mandatory=$true)] [string] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [string] $TenantId,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [string] $SetupStorage,
    [Parameter(Mandatory=$true)] [string] $SetupBlobContainer,
    [Parameter(Mandatory=$true)] [string] $VhdDiskName,
    [Parameter(Mandatory=$true)] [string] $VhdImageName
)

if ($OsImageType.ToLower() -eq "vhd")
{
    if ($UploadVhd)
    {
        Log-Information "Upload the vhd for vm image"
        ./do-deployment-vhd-upload.ps1 -DeploymentType $DeploymentType `
            -SubscriptionId $SubscriptionId `
            -TenantId $TenantId `
            -ResourceGroup $ResourceGroup `
            -AzureLocation $AzureLocation `
            -StorageAccount $SetupStorage `
            -Container $SetupBlobContainer `
            -VhdName $VhdDiskName `
            -VhdPath "/vhd-base/"
    }

    Log-Information "Get endpoint to use for the image"
    $StorageEndpoint=( az storage account show -n $SetupStorage --query primaryEndpoints.blob -o tsv )
    Log-Information "$StorageEndpoint"

    Log-Information "Create the image for VMs"
    $argList = "image create " +
        "--resource-group $ResourceGroup " +
        "--location $AzureLocation " +
        "--name $VhdImageName " +
        "--os-type linux " +
        "--source $StorageEndpoint$SetupBlobContainer/$VhdDiskName " +
        "--os-disk-caching ReadWrite " +
        "-o table"
    $retVal = Run-Command -Process "az" -Arguments $argList
}







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUTMcBRAmxw/DsjbjPe698aab4
# 30+gggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBRxnUEcct1M1mm4HC1xBi2EggZoTzANBgkqhkiG
# 9w0BAQEFAASCAgBKte6312yZEufR9hD+l9O9fXsq2q9ijKY+IRqmeWquuAhalgRW
# guNP/gabxyoQOo/IOauB2C/7jtP8TDPJifgNCdWFFDHRB0uE6N3hx7xU0W+Pbzby
# UNF/nM9R+Y6SfaNm4u+RxcPKWHyxC6Lw4Cp55fj5GPm6His08kC9k5GE0rskFMuY
# ofR0T/2mYopkQFvnkYvqHE4LCVaDGboxhP7dv0wHewxiBuIcTnstpAx7JQqc1qnd
# hRcu8gZNtwfHeZqiCnO7weTf/Gmq/h8Z7896G+/6e9PxkpS5rLK16KQED5arvwoL
# Jk3ZbagnPmuWUgwSigXNGnug0cvkCxbZr1+/02n0vaidY9tjZKtRN5W1ALnwOV2y
# IwIRwS3ANO3q6xMygv9Y6ovhX5i1pjCrOOQs7M6aGn4tNpqPUxFUYn4Jl85/IKNL
# 2K5G6b4gpVlCndUYz1rZBJRYxlKQz3nzVVFTd1vBQb5PvwvwSbVUl4imOFVPoafm
# NJ0ZRHaCclHhL/4aZClGzrrqtRL/GajqCiTQAaTtr0cjm8m3G2XoXBNZiOQsikJO
# Om+uGmiJxRbIj9fepKCtdrFZiNzB2QNuwsPtK3BUSc1qhCtiVIc9+C6w2jSF+3xB
# nB8I66cJYlRTSJDVAbocrv34P8l+9y1nuqmWhRET+eaciH+6r9PQqsXnKg==
# SIG # End signature block
