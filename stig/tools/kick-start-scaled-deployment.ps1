#Requires -Module @{ ModuleName = 'Az.Resources'; ModuleVersion = '3.5.0' }
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

    [Parameter(Mandatory = $false)]
    [string]
    $Environment = 'AzureUSGovernment',

    [Parameter(Mandatory = $true)]
    [ValidateScript({Test-Path -Path $_})]
    [string]
    $DataFilePath,

    [Parameter(Mandatory = $false)]
    [SecureString]
    $AdminPasswordOrKey
)

# if AdminPasswordOrKey is not passed at runtime, prompt the user for password
if ($PSBoundParameters.ContainsKey('AdminPasswordOrKey') -eq $false)
{
    # explain the password requirements to the user
    Write-Host "Deployment Admin Password must be at least 12 characters long, contain upper case, lower case, number and symbol." -ForegroundColor Magenta

    # prompt for AdminPassword, check for complexity, confirm they are equal before proceeding
    $passTryCount = 0
    do
    {
        if ($passTryCount -gt 3)
        {
            throw "The password validation checks failed, check the password and try again."
        }

        $passTryCount++

        # ensure clean decrypted vars through each iteration
        $passwordEntryDecrypt = $null
        $passConfEntryDecrypt = $null

        $passwordEntry = Read-Host -Prompt 'Initial --> Deployment Admin Password' -AsSecureString
        $passwordIntPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwordEntry)
        $passwordEntryDecrypt = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($passwordIntPtr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordIntPtr)

        # test decrypted password to ensure complexity
        $passwordComplexityMatchPattern = '^(?=.*[A-Z])(?=.*[.!@#$%^&*()-_=+])(?=.*[0-9])(?=.*[a-z]).{12,40}$'
        if ($passwordEntryDecrypt -notmatch $passwordComplexityMatchPattern)
        {
            Write-Warning "The password does not meet complexity requirements stated above, try again..."
            continue
        }

        # prompt again to ensure passwords match
        $passConfEntry = Read-Host -Prompt 'Confirm --> Deployment Admin Password' -AsSecureString
        $passConfIntPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passConfEntry)
        $passConfEntryDecrypt = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($passConfIntPtr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passConfIntPtr)
        if ($passwordEntryDecrypt -ne $passConfEntryDecrypt)
        {
            Write-Warning "The password confirmation does not match, check the password and try again..."
        }
    }
    until ($passwordEntryDecrypt -eq $passConfEntryDecrypt)

    $adminPasswordOrKey = $passwordEntry
}

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
[void] $PSBoundParameters.Remove('AdminPasswordOrKey')
$artifactLocationParams = & $publishToBlobScript @PSBoundParameters -MetadataPassthru

# call the scale-deployment.ps1 script to deploy all datafile VM resources using the artificats previously copied via the publish-to-blob.ps1 script
$scaleDeployment = Join-Path -Path $PSScriptRoot -ChildPath '.\scale-deployment.ps1'
& $scaleDeployment @artifactLocationParams -DataFilePath $DataFilePath -AdminPasswordOrKey $AdminPasswordOrKey
