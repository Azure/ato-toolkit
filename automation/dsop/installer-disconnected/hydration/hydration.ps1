# register the az cli cloud
# az cloud register -n AzSec `
#     --endpoint-resource-manager "https://usseceast.management.azure.microsoft.scloud" --endpoint-management "https://management.core.microsoft.scloud" `
#     --endpoint-active-directory "https://login.microsoftonline.microsoft.scloud/" `
#     --endpoint-active-directory-graph-resource-id "https://graph.microsoft.scloud/" `
#     --endpoint-active-directory-resource-id "https://management.azure.microsoft.scloud/" `
#     --suffix-storage-endpoint "core.microsoft.scloud" --suffix-keyvault-dns ".vault.core.microsoft.scloud" `
#     --endpoint-vm-image-alias-doc "https://deveastocpst001.blob.core.microsoft.scloud/filesbl/aliases.json"

# --cloud-config
# --endpoint-active-directory
# --endpoint-active-directory-data-lake-resource-id
# --endpoint-active-directory-graph-resource-id
# --endpoint-active-directory-resource-id
# --endpoint-gallery
# --endpoint-management
# --endpoint-resource-manager
# --endpoint-sql-management
# --endpoint-vm-image-alias-doc
# --profile {2017-03-09-profile, 2018-03-01-hybrid, 2019-03-01-hybrid, latest}
# --suffix-acr-login-server-endpoint
# --suffix-azure-datalake-analytics-catalog-and-job-endpoint
# --suffix-azure-datalake-store-file-system-endpoint
# --suffix-keyvault-dns
# --suffix-sql-server-hostname
# --suffix-storage-endpoint

if ($PSVersionTable.PSVersion.Major -lt "6")
{
    Write-Output "Powershell version 7 is required"
    exit
}

$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\EscDomains"
New-Item -Path "$registryPath\internet" -Force | out-null
New-ItemProperty -Path "$registryPath\internet" -Name "about" -Value 2 -PropertyType DWORD -Force | out-null

New-Item -Path "$registryPath\microsoftonline.com" -Force | out-null
New-ItemProperty -Path "$registryPath\microsoftonline.com" -Name "https" -Value 2 -PropertyType DWORD -Force | out-null

New-Item -Path "$registryPath\msftauth.net" -Force | out-null
New-ItemProperty -Path "$registryPath\msftauth.net" -Name "https" -Value 2 -PropertyType DWORD -Force | out-null

New-Item -Path "$registryPath\msauth.net" -Force | out-null
New-ItemProperty -Path "$registryPath\msauth.net" -Name "https" -Value 2 -PropertyType DWORD -Force | out-null

New-Item -Path "$registryPath\live.com" -Force | out-null
New-ItemProperty -Path "$registryPath\live.com" -Name "https" -Value 2 -PropertyType DWORD -Force | out-null

$registryPathFirstRun = "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main"
New-Item -Path "$registryPathFirstRun" -Force | out-null
New-ItemProperty -Path "$registryPathFirstRun" -Name "DisableFirstRunCustomize" -Value 1 -PropertyType DWORD -Force | out-null


$baseDirectory = "$($(Get-Location).Path)"
$configFile = "deployment.vars.jsonc"
$password = ""
$useCertForServicePrincipal = $false

./tools/azcli-setup.ps1

./tools/azcopy-setup.ps1

# ./tools/porter-setup.ps1

try
{
    $jsonConfig = Get-Content "$baseDirectory/$configFile" -ErrorAction Stop | ConvertFrom-Json
}
catch 
{
    throw "Cannot find $baseDirectory/$configFile. Cannot proceed with script."
}

$loginUri = $($jsonConfig.azureConfig.cloud.endpoints.activeDirectory).Replace("https://login.", "")
write-output "Allow the uri to work: $loginUri"
New-Item -Path "$registryPath\$loginUri" -Force | out-null
New-ItemProperty -Path "$registryPath\$loginUri" -Name "https" -Value 2 -PropertyType DWORD -Force | out-null

if ($null -eq $jsonConfig.azureConfig.azCliRootCert) {
    Write-Output "Appending Cert chain for AZ CLI"
    ./cert-fix.ps1 -rootCert $jsonConfig.azureConfig.azCliRootCert
}
else {
    Write-Output "Cert file not found. Certificate will not be injected into the Python cert store. If this is needed, please provide a path to the cert and try again."
}

$azCloudExists = (az cloud list -o json --query "[?name=='$($jsonConfig.azureConfig.cloudName)'].name") | ConvertFrom-Json
# should we check the original list, 
# store it as the default list, 
# and then unregister any cloudNames not in that list 
# but previously registered?
if ($azCloudExists)
{
    Write-Output "Cloud $($jsonConfig.azureConfig.cloudName) already registered"
}
else
{
    Write-Output "Cloud $($jsonConfig.azureConfig.cloudName) not registered. Getting cloud configuration."


    # # looks like this might not be ready:
    # # https://github.com/Azure/azure-cli/pull/13899
    # $env:ARM_CLOUD_METADATA_URL = "https://management.azure.com/metadata/endpoints?api-version=2020-06-01"
    # az login -t $jsonConfig.azureConfig.tenantId


    $cloudConfig = $($jsonConfig.azureConfig.cloud | ConvertTo-Json -Compress).Replace("`"", "\`"")
    Write-Output "Registering $($jsonConfig.azureConfig.cloudName)"
    az cloud register -n "$($jsonConfig.azureConfig.cloudName)" --cloud-config $cloudConfig
    Write-Output "Registered $($jsonConfig.azureConfig.cloudName)"
}

write-output "Switching to specified cloud $($jsonConfig.azureConfig.cloudName)"
az cloud set -n "$($jsonConfig.azureConfig.cloudName)"

write-output "Logging into $($jsonConfig.azureConfig.cloudName) with tenant $($jsonConfig.azureConfig.tenantId)"
az login -t $jsonConfig.azureConfig.tenantId

write-output "Making sure the resource group exists"
az group create -g $($jsonConfig.azureConfig.spResouceGroup) -l "$($jsonConfig.azureConfig.location)" | out-null

write-output "Checking if the keyvault exists"
$keyvaultExists = ( az keyvault list -g $($jsonConfig.azureConfig.spResouceGroup) --query "[?name=='$($jsonConfig.azureConfig.spKeyvault)'].name" -o tsv )
if ($keyvaultExists)
{
    write-output "Keyvault found"
}
else
{
    write-output "Keyvault does not exist. Creating."
    az keyvault create -n $($jsonConfig.azureConfig.spKeyvault) -g $($jsonConfig.azureConfig.spResouceGroup) | out-null
}

$servicePrincipalName = "$($jsonConfig.azureConfig.servicePrincipalName)"
if (-not $servicePrincipalName.StartsWith("http"))
{
    write-output "Service principal name $servicePrincipalName does not start with http. Prepending."
    $servicePrincipalName = "http://$servicePrincipalName"
    write-output "Service principal name is now: $servicePrincipalName"
}

write-output "Verifying if the service principal exists"
$spExists = ( az ad sp list --spn "$servicePrincipalName" -o tsv )
if ($spExists)
{
    write-output "Service principal exists. Skipping creating."
}
else
{
    write-output "Service principal not found."
    if ($useCertForServicePrincipal)
    {
        write-output "Creating a service principal with a cert"
        az ad sp create-for-rbac --name "$servicePrincipalName" `
            --keyvault $($jsonConfig.azureConfig.spKeyvault) `
            --cert "$($jsonConfig.azureConfig.spCertName)" `
            --create-cert | out-null


        $pemCert = "./$($($jsonConfig.azureConfig.spCertName)).pem"
        write-output "Check if the cert file $pemCert exists locally"
        if (-not (Test-Path "$pemCert" -PathType Leaf))
        {
            write-output "Cert file doesn't exist. Downloading from keyvault as pfx."
            $pfxCert = "./$($($jsonConfig.azureConfig.spCertName)).pfx"
            # if we can't find this we need to do something because it should mean that the sp wasn't created here, 
            # but also the file wasn't given
            # and we expected it to be here so login is going to fail
            az keyvault secret download --vault-name $($jsonConfig.azureConfig.spKeyvault) -n sp-login -f "$pfxCert" --encoding base64
            write-output "Converting pfx to pem with openssl"
            openssl pkcs12 -in "$pfxCert" -out "$pemCert" -nodes -password pass:""
        }
    
        $password = $pemCert
    }
    else
    {
        write-output "Creating a service principal with a password"
        $password = ( az ad sp create-for-rbac --name "$servicePrincipalName" -o tsv --query "password" )

        write-output "Adding the password to key vault"
        az keyvault secret set --vault-name $($jsonConfig.azureConfig.spKeyvault) -n sp-login --value "$password" | out-null
    }
    write-output "Service principal created"
}


write-output "Checking if the service principal is set to be a Contributor"
$contributorRoleExists = (az role assignment list --assignee "$servicePrincipalName" `
                            --query "[?roleDefinitionName=='Contributor'].roleDefinitionName"  -o tsv )
if ($contributorRoleExists)
{
    write-output "Service principal is already assigned the Contributor role."
}
else
{
    write-output "Service principal is not assign the Contributor. Assigning now."
    az role assignment create --assignee "$servicePrincipalName" --role Contributor | out-null
}

if ($useCertForServicePrincipal)
{
    write-output "Signing in with the service principal cert"
    az login --service-principal `
        -u "$servicePrincipalName" `
        -p "$pemCert" `
        --tenant "$($jsonConfig.azureConfig.tenantId)"
}
else
{
    write-output "Signing in with the service principal password"
    az login --service-principal `
        -u "$servicePrincipalName" `
        -p "$password" `
        --tenant "$($jsonConfig.azureConfig.tenantId)"
}

write-output "Service Principal signed in"
write-output "-------------------------------"
write-output "Hydration complete. Proceed with your install."

# store common environment values for later automation
# ---
# could we instead have them fill out this json file
# and then just use it in all of the automation?







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUHfoMz5YPKdqgrrNTm+4AoxRV
# NzigggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBRnZkrgUCXwGGqchwf3nz2JzEC1wDANBgkqhkiG
# 9w0BAQEFAASCAgBpdFuBO2i/hWHQIi0vcifJdOCBBTF4bkdwihfvyesKq/dRGPXc
# LIkbDr1BuFVnwiBMlkLHbRVTURncSKvy34S7lU7YZGm0BQ6km6zfKMAtmh2y/CQK
# 0nEzIVrqSc6QDnqwjxr6sLb8mz/JeIDwZp1jjFSGX7cMPOS6FWuTjaj80RvC7NgJ
# C7i2dJ9zKE36BIQTv0cqery4DEIiXJsx/lH5g+vXSzzBpwdIv9kB6HXuk3F3Yguw
# zUSAvxUn8RhD5+CFKhoLOhOMIEDcv2qZ/4k67cGtilL0AadXs+3CKuqHBslM13l8
# E1oTmbjFbUIjPLNa7Px+EyS3KytxUlyoKzq9rU8KGElKjR9nT5l7uGcec+vAFeAe
# jaoGc3u0thnkzR56U7zjgb8aMg/ToboB97OIDBKezBdnIRsJNdID8inf6LpTn2F6
# cjL/y/h7S5SPLRpBVCnAnZ297pYSJG7quRSQOb1e1XmofktpehNvQKXSoSWoNVdC
# F0izqssuFxhM6Ltz69fI3yA5O2yu8aTK1jw/EdCi5MJo/oB5cYtJE5UmAKBElLPu
# AvL6JpsMfx7S9kiTI0zIiVumzITnsFJT728hgSmqUlTzW4e4PL2AF8PqqYscjXRa
# AKcrYvGTl+6pXw/QZ/TAw4iOyl6roGI3QfkAAF9knDdgoFSPjT9A7ZnEmQ==
# SIG # End signature block
