Param(
    [string] 
    [Parameter(Mandatory = $true)] 
    $ResourcePrefix,

    [string]
    $Region = "usgovarizona"
)

function New-ArtifactStorageAccount {
    param(
        [Parameter(Mandatory = $True)]
        [string]
        $ResourceGroupName,

        [Parameter(Mandatory = $True)]
        [string]
        $Region,

        [Parameter(Mandatory = $True)]
        [string]
        $artifactStorageAccountName
    )

    $existingAccount = (Get-AzStorageAccount | Where-Object { $_.StorageAccountName -eq $artifactStorageAccountName })

    if (!$existingAccount) {
        Write-Host "Creating a new artifact storage account $artifactStorageAccountName"
        $existingAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupName `
            -Name $artifactStorageAccountName `
            -Location $Region `
            -SkuName Standard_GRS `
            -Kind Storage `
            -EnableHttpsTrafficOnly $true
    }
    else {
        Write-Host "Using existing artifact storage account $artifactStorageAccountName"
    }
}

function New-Artifacts {
    param(
        [Parameter(Mandatory = $True)]
        [string]
        $artifactStorageAccountName,

        [Parameter(Mandatory = $True)]
        [string]
        $containerName
    )
  
    $azureDeployFile = "azuredeploy.json"
    $azureDeployFilePath = "$PSScriptRoot\..\$($azuredeployFile)"
    $createUIDefFile = "createUiDefinition.json"
    $scriptFile = "WindowsServer.ps1.zip"

    # Create storage account and storage container.
    $context = (Get-AzStorageAccount | Where-Object { $_.StorageAccountName -eq $artifactStorageAccountName }).Context
    New-AzStorageContainer -Name $containerName -Context $context -Permission Container -ErrorAction SilentlyContinue *>&1
    
    # Update template parameter default values for script location and offline deployment.
    $jAzureDeploy = Get-Content -raw "$azureDeployFilePath" | ConvertFrom-Json
    $jAzureDeploy.parameters.autoInstallDependencies.defaultValue = $false
    $jAzureDeploy | ConvertTo-Json -Depth 100 | % { [System.Text.RegularExpressions.Regex]::Unescape($_) } | Set-Content "$($PSScriptRoot)\offline\$($azureDeployFile)" -Force
    
    Set-AzStorageBlobContent -File "$($PSScriptRoot)\offline\$($azureDeployFile)" -Container $containerName -Blob $azureDeployFile -Context $context -Force
    Set-AzStorageBlobContent -File "$($PSScriptRoot)\..\$($createUIDefFile)" -Container $containerName -Blob $createUIDefFile -Context $context -Force
    Set-AzStorageBlobContent -File "$($PSScriptRoot)\..\GenerateStigChecklist.ps1" -Container $containerName -Blob "GenerateStigChecklist.ps1" -Context $context -Force
    Set-AzStorageBlobContent -File "$($PSScriptRoot)\offline\WindowsServer.ps1.zip" -Container $containerName -Blob $scriptFile -Context $context -Force

    Write-Host "Uploaded file(s) to Container '$($containerName)' in Storage Account '$($artifactStorageAccountName)'."
    
    $azureDeployUrl = New-AzStorageBlobSASToken -Container $containerName -Blob (Split-Path $azureDeployFile -leaf) -Context $context -FullUri -Permission r
    $createUIDefUrl = New-AzStorageBlobSASToken -Container $containerName -Blob (Split-Path $createUIDefFile -leaf) -Context $context -FullUri -Permission r

    $azureDeployUrlEncoded = [uri]::EscapeDataString($azureDeployUrl)
    $createUIDefUrlEncoded = [uri]::EscapeDataString($createUIDefUrl)
    $deployUrl = "https://portal.azure.us/#create/Microsoft.Template/uri/$($azureDeployUrlEncoded)/createUIDefinitionUri/$($createUIDefUrlEncoded)"
    
    Write-Host "Azure Storage Container Uri: $($context.BlobEndPoint + $containerName)"
    Write-Host "Deployment Uri: $($deployUrl)"
}

$containerName = "artifacts"
$artifactStorageAccountName = "$($ResourcePrefix)artifacts"
$artifactResourceGroupName = "$($ResourcePrefix)-artifacts"

# Create the artifact storage account and stage the deployment files
New-AzResourceGroup -Name $artifactResourceGroupName -Location $Region -Verbose -Force
New-ArtifactStorageAccount -ArtifactStorageAccountName $artifactStorageAccountName -ResourceGroupName $artifactResourceGroupName -Region $Region
New-Artifacts -ArtifactStorageAccountName $artifactStorageAccountName -ContainerName $containerName