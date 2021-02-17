<#
    This script publishes templates and associated scripts into your Azure Storage account, and generates Azure Portal link for deployment.
    Replace variables with your environment details.
#>

Param(
    [string]
    [Parameter(Mandatory = $true)]
    $resourceGroupName,

    [string]
    [Parameter(Mandatory = $true)]
    $storageAccountName,

    [string]
    [Parameter(Mandatory = $false)]
    $containerName = "artifacts"
)

$azureDeployFile = "mainTemplate.json"
$createUIDefFile = "createUiDefinition.json"

$ErrorActionPreference = "Stop"

$context = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName).Context

if (-not(Get-AzStorageContainer -Context $context -Prefix $containerName)) {
    New-AzStorageContainer -Context $context -Name $containerName -Permission Off
}

Get-ChildItem -Path ".\artifacts" -File -Recurse | Set-AzStorageBlobContent -Context $context -Container $containerName -Force

$sasToken = New-AzStorageContainerSASToken -Context $context -Name $containerName -Permission rwdl
$azureDeployUrl = (Get-AzStorageBlob -Context $context -Container $containerName -Blob $azureDeployFile).ICloudBlob.Uri.AbsoluteUri + $sasToken
$createUIDefUrl = (Get-AzStorageBlob -Context $context -Container $containerName -Blob $createUIDefFile).ICloudBlob.Uri.AbsoluteUri + $sasToken

$azureDeployUrlEncoded = [uri]::EscapeDataString($azureDeployUrl)
$createUIDefUrlEncoded = [uri]::EscapeDataString($createUIDefUrl)
"https://portal.azure.com/#create/Microsoft.Template/uri/$($azureDeployUrlEncoded)/createUIDefinitionUri/$($createUIDefUrlEncoded)"
"https://portal.azure.us/#create/Microsoft.Template/uri/$($azureDeployUrlEncoded)/createUIDefinitionUri/$($createUIDefUrlEncoded)"