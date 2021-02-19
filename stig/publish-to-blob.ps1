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

$ErrorActionPreference = "Stop"

$context = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName).Context

if (-not(Get-AzStorageContainer -Context $context -Prefix $containerName)) {
    New-AzStorageContainer -Context $context -Name $containerName -Permission Off
}

Get-ChildItem -Path "." -Exclude "publish-to-blob.ps1","*.md" -File -Recurse | Set-AzStorageBlobContent -Context $context -Container $containerName -Force

$sasToken = New-AzStorageContainerSASToken -Context $context -Name $containerName -Permission rwdl
$mainTemplateWinUrl = (Get-AzStorageBlob -Context $context -Container $containerName -Blob "windows/mainTemplate.json").ICloudBlob.Uri.AbsoluteUri + $sasToken
$createUIDefWinUrl = (Get-AzStorageBlob -Context $context -Container $containerName -Blob "windows/createUiDefinition.json").ICloudBlob.Uri.AbsoluteUri + $sasToken
$mainTemplateLinUrl = (Get-AzStorageBlob -Context $context -Container $containerName -Blob "linux/mainTemplate.json").ICloudBlob.Uri.AbsoluteUri + $sasToken
$createUIDefLinUrl = (Get-AzStorageBlob -Context $context -Container $containerName -Blob "linux/createUiDefinition.json").ICloudBlob.Uri.AbsoluteUri + $sasToken

$portalUrl = "https://portal.azure.com"
if ((Get-AzContext).Environment.Name -eq "AzureUSGovernment") {
    $portalUrl = "https://portal.azure.us"
}

$win = "/#create/Microsoft.Template/uri/$([uri]::EscapeDataString($mainTemplateWinUrl))/createUIDefinitionUri/$([uri]::EscapeDataString($createUIDefWinUrl))"
$lin = "/#create/Microsoft.Template/uri/$([uri]::EscapeDataString($mainTemplateLinUrl))/createUIDefinitionUri/$([uri]::EscapeDataString($createUIDefLinUrl))"

Write-Host "Windows:    $($portalUrl)$($win)"
Write-Host "Linux:    $($portalUrl)$($lin)"