param (
    [parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [parameter(Mandatory=$true)] [string] $AzureCloud,
    [parameter(Mandatory=$true)] [string] $AzureDomain,
    [parameter(Mandatory=$true)] [string] $AzureProfile
)

Log-Parameters -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$proc = "az"

if ($DeploymentType -eq [DeploymentType]::DisconnectedStack)
{
    Log-Information "Checking if the Azure Location is registered"
    $AzureCloudRegistration=(az cloud list --query "[?name=='$AzureCloud']" -o json ) | ConvertFrom-Json
    if ($AzureCloudRegistration.count -ge 1)
    {
        Log-Information "Registration found"
        if ($AzureCloudRegistration.IsActive)
        {
            Log-Information "Setting the active cloud to Azure to prep for removal"
            $argList = "cloud set -n AzureCloud -o table"
            $retVal = Run-Command -Process $proc -Arguments $argList
        }
        Log-Information "Removing registration"
        $argList = "cloud unregister -n $AzureCloud -o table"
        $retVal = Run-Command -Process $proc -Arguments $argList
    }

    Log-Information "Registering the Azure CLI location $AzureCloud"
    $argList = "cloud register " +
                "-n $AzureCloud " +
                "--endpoint-resource-manager `"https://management.$AzureDomain`" " +
                "--suffix-storage-endpoint $AzureDomain " +
                "--suffix-keyvault-dns `".vault.$AzureDomain`" " +
                "--endpoint-vm-image-alias-doc `"https://raw.githubusercontent.com/Azure/azure-rest-api-specs/master/arm-compute/quickstart-templates/aliases.json`" " +
                "-o table"
                $retVal = Run-Command -Process $proc -Arguments $argList
}

Log-Information "Setting to cloud $AzureCloud"
$argList = "cloud set -n $AzureCloud -o table"
$retVal = Run-Command -Process $proc -Arguments $argList

if ($DeploymentType -eq [DeploymentType]::DisconnectedStack)
{
    Log-Information "Updating the Azure CLI profile"
    $argList = "cloud update --profile $AzureProfile -o table"
    $retVal = Run-Command -Process $proc -Arguments $argList
}

Log-Footer -ScriptName $MyInvocation.MyCommand
