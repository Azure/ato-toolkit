<#
    .SYNOPSIS
        Kick start script that copies artifact data to a storeage account, then deploys Virtual Machines based on the specified data file.

    .DESCRIPTION
        Kick start script that copies artifact data to a storeage account, then deploys Virtual Machines based on the specified data file.

    .PARAMETER ResourceGroupName
        Specifies the name of the deployment resource group.

    .PARAMETER StorageAccountName
        Specifies the name of the Storage Account where the artifacts will be copied.

    .PARAMETER ContainerName
        Specifies the name of the container where the artifacts will be copied.

    .PARAMETER Environment
        Environment containing the Azure account.

    .PARAMETER DataFilePath
        ATO Scale deployment data file (.psd1)

    .EXAMPLE

        $kickStartParams = @{
            ResourceGroupName  = 'deploymentRG'
            StorageAccountName = 'deploymentSA'
            ContainerName      = 'deploymentContainer'
            Environment        = 'AzureUSGovernment'
            DataFilePath       = 'C:\data\deploymentData.psd1'
        }
        .\kick-start-scaled-deployment.ps1 @kickStartParams

        This example leverage the .\publish-to-blob.ps1 script to copy deployment artifacts to a storage account, then invoke
        .\scale-deployment.ps1 to deploy Virtual Machines defined in the data file (psd1).
#>

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountName,

    [Parameter(Mandatory = $false)]
    [string]
    $ContainerName = 'artifacts',

    [Parameter(Mandatory = $true)]
    [string]
    $Environment,

    [Parameter(Mandatory = $true)]
    [ValidateScript({Test-Path -Path $_})]
    [string]
    $DataFilePath
)

# prompt for AdminPassword, twice, confirm they are equal before proceeding
$passTryCount = 0
do
{
    $passwordEntry = Read-Host -Prompt 'Deployment Admin Password' -AsSecureString
    $passConfEntry = Read-Host -Prompt 'Confirm Deployment Admin Password' -AsSecureString
    $passwordEntryDecrypt = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwordEntry))
    $passConfEntryDecrypt = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passConfEntry))
    if ($passTryCount -gt 1 -and $passwordEntryDecrypt -ne $passConfEntryDecrypt)
    {
        throw "Deployment Admin Password confirmation does not match, Check the password and try again."
    }
    $passTryCount++
}
until ($passwordEntryDecrypt -eq $passConfEntryDecrypt)

# connect to AzAccount
if ($null -eq $(Get-AzContext))
{
    try
    {
        Connect-AzAccount -Environment $Environment -ErrorAction Stop | Out-Null
    }
    catch
    {
        throw "Unable to connect to AzAccount; $_"
    }
}

# call the publish-to-blob.ps1 script to copy deployment artifacts to the specified ResourceGroup and StorageAccount
$publishToBlobScript = Join-Path -Path $PSScriptRoot -ChildPath '.\publish-to-blob.ps1'
[void] $PSBoundParameters.Remove('DataFilePath')
$artifactLocationParams = & $publishToBlobScript @PSBoundParameters -MetadataPassthru

# call the scale-deployment.ps1 script to deploy all datafile VM resources using the artificats previously copied via the publish-to-blob.ps1 script
$scaleDeployment = Join-Path -Path $PSScriptRoot -ChildPath '.\scale-deployment.ps1'
& $scaleDeployment @artifactLocationParams -DataFilePath $DataFilePath -AdminPasswordOrKey $passwordEntry
