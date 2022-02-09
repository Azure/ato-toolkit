<#
    .SYNOPSIS
        This script publishes templates and associated scripts into your Azure Storage account, and generates Azure Portal link for deployment.

    .DESCRIPTION
        This script publishes templates and associated scripts into your Azure Storage account, and generates Azure Portal link for deployment.

    .PARAMETER ResourceGroupName
        Specifies the name of the deployment resource group.

    .PARAMETER StorageAccountName
        Specifies the name of the Storage Account where the artifacts will be copied.

    .PARAMETER ContainerName
        Specifies the name of the container where the artifacts will be copied.

    .PARAMETER Environment
        Environment containing the Azure account.

    .PARAMETER MetadataPassthru
        Used to pass Uri data through the pipeline.

    .PARAMETER SkipPublish
        Skips publishing artifacts to the storage blob and only returns metadata when used in conjunction with the MetaDataPassthru switch.

    .EXAMPLE
        $deploymentUri = .\publish-to-blob.ps1 -ResourceGroupName deploymentRG -StorageAccountName deploymentSA -ContainerName artifacts -MetadataPassthru

        This example will copy deployment artifacts to the specified storage account / container, then output via Write-Host Uri details.
        This example also stores the artifact location details as a hash table in the deploymentUri variable.

    .NOTES
        The README.md file from Linux and Windows folders will be added to the specified storage container regardless of which platform is specified.
        This method is used to ensure that a Linux and Windows folder is created in order to maintain backward compatibility.
#>

Param(
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountName,

    [Parameter(Mandatory = $false)]
    [string]
    $ContainerName = 'artifacts',

    [Parameter(Mandatory = $false)]
    [string]
    $Environment = ((Get-AzContext).Environment.Name),

    [Parameter(Mandatory = $false)]
    [switch]
    $MetadataPassthru,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Linux', 'Windows')]
    [string[]]
    $Platform = @('Linux', 'Windows'),

    [Parameter(Mandatory = $false)]
    [switch]
    $SkipPublish
)

# create storage account context for use throughout the script
$context = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Context

# detect specified container name, create it if it does not exist
if (-not(Get-AzStorageContainer -Context $context -Name $ContainerName -ErrorAction SilentlyContinue))
{
    Write-Verbose -Message "Specified container does not exist, creating $ContainerName"
    New-AzStorageContainer -Context $context -Name $ContainerName -Permission Off | Out-Null
}

# detect artifact folders and copy to the specified blob storage container
if ($SkipPublish)
{
    $blobContent = Get-AzStorageBlob -Context $context -Container $ContainerName
}
else
{
    $projectRootPath = Join-Path -Path $PSScriptRoot -ChildPath '..\'
    $linArtifactPath = Join-Path -Path $projectRootPath -ChildPath '.\linux'
    $winArtifactPath = Join-Path -Path $projectRootPath -ChildPath '.\windows'
    $artifactFolders = [System.Collections.ArrayList]::new()
    switch ($Platform)
    {
        'Linux'
        {
            $winReadMePath = Join-Path -Path $winArtifactPath -ChildPath 'README.md'
            [void] $artifactFolders.Add((Get-ChildItem -Path $linArtifactPath, $winReadMePath))
        }
        'Windows'
        {
            $linReadMePath = Join-Path -Path $linArtifactPath -ChildPath 'README.md'
            [void] $artifactFolders.Add((Get-ChildItem -Path $winArtifactPath, $linReadMePath))
        }
    }

    $artifactFiles = Get-ChildItem -Path $artifactFolders.FullName -File -Recurse
    $blobContent = $artifactFiles | Set-AzStorageBlobContent -Context $context -Container $ContainerName -Force
}

# create container SAS token
$sasToken = New-AzStorageContainerSASToken -Context $context -Name $ContainerName -Permission r

# isolating mainTemplate/createUiDefinition blob objects
$mainTemplateWinBlob = $blobContent | Where-Object -FilterScript {$_.ICloudBlob.Uri.AbsoluteUri -like "*/windows/*mainTemplate.json"}
$createUIDefiWinBlob = $blobContent | Where-Object -FilterScript {$_.ICloudBlob.Uri.AbsoluteUri -like "*/windows/*createUiDefinition.json"}
$mainTemplateLinBlob = $blobContent | Where-Object -FilterScript {$_.ICloudBlob.Uri.AbsoluteUri -like "*/linux*/*mainTemplate.json"}
$createUIiDefLinBlob = $blobContent | Where-Object -FilterScript {$_.ICloudBlob.Uri.AbsoluteUri -like "*/linux*/*createUiDefinition.json"}

# store mainTemplate/createUiDefinition json file Uris from blob objects
$mainTemplateWinUri = $mainTemplateWinBlob.ICloudBlob.Uri.AbsoluteUri
$createUIDefiWinUri = $createUIDefiWinBlob.ICloudBlob.Uri.AbsoluteUri
$artifactsLocWinUrl = $mainTemplateWinBlob.ICloudBlob.Parent.Uri.AbsoluteUri
$mainTemplateLinUri = $mainTemplateLinBlob.ICloudBlob.Uri.AbsoluteUri
$createUIiDefLinUrl = $createUIiDefLinBlob.ICloudBlob.Uri.AbsoluteUri
$artifactsLocLinUrl = $mainTemplateLinBlob.ICloudBlob.Parent.Uri.AbsoluteUri

# creating switch for Context Environment to support additional environments
switch ($Environment)
{
    'AzureUSGovernment' {$azureRootDomain = 'us'; break}
    'AzureGermanCloud'  {$azureRootDomain = 'de'; break}
    'AzureCloud'        {$azureRootDomain = 'com'; break}
    default             {$azureRootDomain = 'com'}
}

# create portal template links and return a formatted Uri Write-Host output
$azPortalUrl = 'https://portal.azure.{0}/#create/Microsoft.Template/uri/' -f $azureRootDomain
$windowsUri  = '{0}{1}/createUIDefinitionUri/{2}' -f $azPortalUrl, [uri]::EscapeDataString($mainTemplateWinUri + $sasToken), [uri]::EscapeDataString($createUIDefiWinUri + $sasToken)
$linuxUri    = '{0}{1}/createUIDefinitionUri/{2}' -f $azPortalUrl, [uri]::EscapeDataString($mainTemplateLinUri + $sasToken), [uri]::EscapeDataString($createUIiDefLinUrl + $sasToken)

Write-Host -Object "`nWindows Deployment Azure portal Uri:" -ForegroundColor Green
Write-Host -Object $windowsUri -ForegroundColor Blue
Write-Host -Object 'Windows Deployment Artifacts Location Uri:' -ForegroundColor Green
Write-Host -Object $artifactsLocWinUrl -ForegroundColor Blue
Write-Host -Object 'Windows Deployment Template Uri:' -ForegroundColor Green
Write-Host -Object $mainTemplateWinUri -ForegroundColor Blue
Write-Host -Object "`nLinux Deployment Azure portal Uri:" -ForegroundColor Green
Write-Host -Object $linuxUri -ForegroundColor Blue
Write-Host -Object 'Linux Deployment Artifacts Location Uri:' -ForegroundColor Green
Write-Host -Object $artifactsLocLinUrl -ForegroundColor Blue
Write-Host -Object 'Linux Deployment Template Uri:' -ForegroundColor Green
Write-Host -Object $mainTemplateLinUri -ForegroundColor Blue

# metadatapassthru is used in conjunction with scale-deployment.ps1
if ($MetadataPassthru -eq $true)
{
    return @{
        WindowsTemplateUri        = $mainTemplateWinUri
        WindowsArtifactsLocation  = $artifactsLocWinUrl
        LinuxTemplateUri          = $mainTemplateLinUri
        LinuxArtifactsLocation    = $artifactsLocLinUrl
        ArtifactsLocationSasToken = $sasToken | ConvertTo-SecureString -AsPlainText -Force
    }
}
