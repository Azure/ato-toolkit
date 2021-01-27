# This script publishes templates and associated scripts into your Azure Storage account, and generates Azure Portal link for testing.
# Replace variables with your environment details.
$tenantId=""
$subscriptionId=""

# Replace variables with unique values for your storage account and resource group names.
$resourceGroup=""
$storageAccountName=""

<#
$location="USGovVirginia"
#New-AzResourceGroup -n $resourceGroup -Location $location
#New-AzStorageAccount -ResourceGroupName $resourceGroup -name $storageAccountName -SkuName Standard_LRS -Location $location
#>

$container="artifacts"
$acureDeployFile="mainTemplate.json"
$createUIDefFile="createUiDefinition.json"

Set-AzContext -Tenant $tenantId -SubscriptionId $subscriptionId
$context = (Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName).Context

if (-not(Get-AzStorageContainer -Prefix $container -Context $context)) {
    New-AzStorageContainer -Name $container -Context $context -Permission Container
}

Compress-Archive -Path ".\artifacts\WindowsServer.ps1" -DestinationPath ".\artifacts\WindowsServer.ps1.zip" -Force

Set-AzStorageBlobContent -File ".\artifacts\mainTemplate.json" -Container $container -Blob "mainTemplate.json" -Context $context -Force
Set-AzStorageBlobContent -File ".\artifacts\createUiDefinition.json" -Container $container -Blob "createUiDefinition.json" -Context $context -Force
Set-AzStorageBlobContent -File ".\artifacts\InstallModules.ps1" -Container $container -Blob "InstallModules.ps1" -Context $context -Force
Set-AzStorageBlobContent -File ".\artifacts\RequiredModules.ps1" -Container $container -Blob "RequiredModules.ps1" -Context $context -Force
Set-AzStorageBlobContent -File ".\artifacts\WindowsServer.ps1.zip" -Container $container -Blob "WindowsServer.ps1.zip" -Context $context -Force

$azureDeployUrl = New-AzStorageBlobSASToken -Container $container -Blob (Split-Path $acureDeployFile -leaf) -Context $context -FullUri -Permission r
$createUIDefUrl = New-AzStorageBlobSASToken -Container $container -Blob (Split-Path $createUIDefFile -leaf) -Context $context -FullUri -Permission r

$azureDeployUrlEncoded=[uri]::EscapeDataString($azureDeployUrl)
$createUIDefUrlEncoded=[uri]::EscapeDataString($createUIDefUrl)
$deployUrl="https://portal.azure.com/#create/Microsoft.Template/uri/$($azureDeployUrlEncoded)/createUIDefinitionUri/$($createUIDefUrlEncoded)"
$deployUrl