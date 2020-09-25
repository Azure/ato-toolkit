param (
    [Parameter(Mandatory=$true)] [string] $KeyVaultEndpoint,
    [Parameter(Mandatory=$true)] [string] $StorageEndpoint,
    [Parameter(Mandatory=$true)] [string] $MasterHostname,
    [Parameter(Mandatory=$true)] [string] $MasterIpAddress,
    [Parameter(Mandatory=$true)] [string] $StorageAccount,
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $ElasticClusterName,
    [Parameter(Mandatory=$true)] [int] $ElasticDataDiskSize,
    [Parameter(Mandatory=$true)] [string] $ElasticVersion,
    [Parameter(Mandatory=$true)] [int] $ElasticPublicPort,
    [Parameter(Mandatory=$true)] [int] $ElasticPrivatePort,
    [Parameter(Mandatory=$true)] [string] $ElasticKeyVault,
    # Data disk size for data nodes. This should be calculated based on deployment / environments requirements
    [Parameter(Mandatory=$false)] [string] $AnsibleVars = "./ansible/group_vars/all/vars.yml"
)

Set-LogFile "./deployment-output/deploy-elastic-ansible-vars_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$OfflineDeployment = "false"
if ($DeploymentType -eq [DeploymentType]::DisconnectedStack -or `
    $DeploymentType -eq [DeploymentType]::Disconnected -or `
    $DeploymentType -eq [DeploymentType]::DisconnectedLite)
{
    $OfflineDeployment = "true"
}

Set-Content -Path $AnsibleVars -Value "ES_CLUSTER_NAME: `"$ElasticClusterName`""
Add-Content -Path $AnsibleVars -Value "ES_INITIAL_MASTER_HOSTNAME: `"$MasterHostname-001v`""
Add-Content -Path $AnsibleVars -Value "ES_INITIAL_MASTER_IP: `"$MasterIpAddress`""

$MasterPassword = Get-RandomString -Size 32 -IncludeNumber
Add-Content -Path $AnsibleVars -Value "ES_INITIAL_MASTER_CA_PASS: `"$MasterPassword`""
Add-Content -Path $AnsibleVars -Value "ELASTICSEARCH_VERSION: `"$ElasticVersion`""
Add-Content -Path $AnsibleVars -Value "ES_DEFAULT_PORT_1: `"$ElasticPublicPort`""
Add-Content -Path $AnsibleVars -Value "ES_DEFAULT_PORT_2: `"$ElasticPrivatePort`""
Add-Content -Path $AnsibleVars -Value "ES_DATA_DISK_SIZE: `"$($ElasticDataDiskSize)GB`""
Add-Content -Path $AnsibleVars -Value "ES_DATA_PATH: `"/data`""
Add-Content -Path $AnsibleVars -Value "ES_KEYVAULT: `"$ElasticKeyVault`""
Add-Content -Path $AnsibleVars -Value ""
Add-Content -Path $AnsibleVars -Value "USER_LOCATION: `"/etc/elasticsearch/userdest`""
Add-Content -Path $AnsibleVars -Value ""
Add-Content -Path $AnsibleVars -Value "OFFLINE_DEPLOYMENT: `"$OfflineDeployment`""
Add-Content -Path $AnsibleVars -Value ""
Add-Content -Path $AnsibleVars -Value "KEYVAULT_ENDPOINT: `"$KeyVaultEndpoint`""
Add-Content -Path $AnsibleVars -Value ""
Add-Content -Path $AnsibleVars -Value "azure_plugin:"
Add-Content -Path $AnsibleVars -Value "  storage_account_name: `"$StorageAccount`""
Add-Content -Path $AnsibleVars -Value "  # Key must be BASE64 encoded"
$StorageAccountKey = az storage account keys list -n $StorageAccount -o tsv --query "[?keyName=='key1'].value"
Add-Content -Path $AnsibleVars -Value "  storage_account_key: `"$StorageAccountKey`""
Add-Content -Path $AnsibleVars -Value "  STORAGE_ENDPOINT: $StorageEndpoint"


Log-ScriptEnd







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdvQQiYUzOLneIsGpaTEVTfYg
# fyKgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBTT04cFl+czAfnid/G+i92TDWFGaTANBgkqhkiG
# 9w0BAQEFAASCAgAKh3aRPY+24Ldl1dTn2KDfLQNHQYqKXmiO43bw3rTCrGJSe26o
# RfMUe+A8PSqAC+IhWU8lgKVA+MAYTv6q1ZAWE+uvSc9v6vUP32iL05x8TMBv5PN8
# AFkwFhW35mcgfw4W1ReD9SwqeH8hsVq1JEbi+S1CrnbXKm6bS7Cz0nO/g2swFdb2
# Hj4M6R1Z3zuRr9YYfruXuCATH2TUJgumsDOk/pGxG2f2qG+sInJ/PmKxzNgOWf4G
# wwkHTaC5Ui0GGZsdCDc+hkrrSjiavrIAkLuHtsQndJlqI7UybN05Yv7lVr4KvTOC
# b8xFcI/nvt23zPDmPCQtJoBjMfsv9BmfYNZnrvF3kaloaWEpdvtpyY71m0VGL0uw
# n75BWA2mo9WJctnHjxTcoRfvsXCT08wu0s/JUjdscjlSIww/ZDfS3R7l5HdnCh+n
# 2E8zDnzmcu02OWJuPNj13pHxbn5KkNuWvG8/hq6+QFRaAiXG5fMaMxfxGVXFMhea
# J3GIzVlmnMFFQcXkHLZT7BYwGndX9/vcBtERBNbLdcVL1XmKLKqNHmwyxZl1ecfI
# wa6mFIzxgfZX8z3vnl5P+B736R7pdvcyDEpNG1I8nCwyIQZ5DvEHZpVDiLQZj+tk
# hnYGxnLuXltmgUhoUSgG0ig2CDkiMkYA6jMKmEeOm9zTpqsgYscF55GtEw==
# SIG # End signature block
