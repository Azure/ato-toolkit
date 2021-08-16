Param(
    [string] 
    [Parameter(Mandatory = $true)] 
    $ResourcePrefix,

    [string]
    $Region = "usgovarizona"
)

function Create-ArtifactStorageAccount {
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

function Upload-Artifacts {
    param(
        [Parameter(Mandatory = $True)]
        [string]
        $artifactStorageAccountName,

        [Parameter(Mandatory = $True)]
        [string]
        $containerName,

        [Parameter(Mandatory = $True)]
        [string]
        $LocalDirectoryToStage
    )

    $storageAccount = (Get-AzStorageAccount | Where-Object { $_.StorageAccountName -eq $artifactStorageAccountName })

    $Container = New-AzStorageContainer -Name $containerName -Context $storageAccount.Context -Permission Container -ErrorAction SilentlyContinue *>&1

    $FilesToStage = Get-ChildItem $LocalDirectoryToStage -Recurse -File
    Write-Host "Found $($FilesToStage.count) file(s) at path $LocalDirectoryToStage"

    foreach ($FileToStage in $FilesToStage) {
        # Keep the source folder structure
        $blobName = ($FileToStage.fullname.Substring($LocalDirectoryToStage.Length)).Replace("\", "/").trim("/")

        $BlobContent = Set-AzStorageBlobContent -File $FileToStage.FullName -Blob "$blobName" `
            -Container $containerName `
            -Context $storageAccount.Context `
            -BlobType "Block" `
            -Force
    }

    Write-Host "Uploaded $($FilesToStage.Count) file(s) to Container '$($containerName)' in Storage Account '$($artifactStorageAccountName)'."
    return $storageAccount.Context.BlobEndPoint + $containerName
}


$containerName = "artifacts"
$artifactStorageAccountName = "$($ResourcePrefix)artifacts"
$artifactResourceGroupName = "$($ResourcePrefix)-artifacts"
$buildPath = "$PSScriptRoot\dependencies"

# Create the artifact storage account and stage the deployment files
New-AzResourceGroup -Name $artifactResourceGroupName -Location $Region -Verbose -Force
Create-ArtifactStorageAccount -ArtifactStorageAccountName $artifactStorageAccountName -ResourceGroupName $artifactResourceGroupName -Region $Region
$deploymentTemplateRoot = Upload-Artifacts -ArtifactStorageAccountName $artifactStorageAccountName -ContainerName $containerName -LocalDirectoryToStage $buildPath

Write-Host $deploymentTemplateRoot


