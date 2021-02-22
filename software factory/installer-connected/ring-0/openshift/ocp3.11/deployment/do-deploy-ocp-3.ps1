param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $OpenshiftPassword,
    [Parameter(Mandatory=$true)] [string] $BastionMachineName,
    [Parameter(Mandatory=$true)] [string] $MasterHostname,
    [Parameter(Mandatory=$true)] [string] $MasterClusterDns,
    [Parameter(Mandatory=$true)] [string] $InfraHostname,
    [Parameter(Mandatory=$true)] [string] $NodeHostname,
    [Parameter(Mandatory=$true)] [int] $nodeInstanceCount,
    [Parameter(Mandatory=$true)] [int] $InfraInstanceCount,
    [Parameter(Mandatory=$true)] [int] $MasterInstanceCount,
    [Parameter(Mandatory=$true)] [int] $CnsInstanceCount,
    [Parameter(Mandatory=$true)] [string] $RoutingSubDomain,
    [Parameter(Mandatory=$true)] [string] $EnableMetrics,
    [Parameter(Mandatory=$true)] [string] $EnableLogging,
    [Parameter(Mandatory=$true)] [string] $TenantId,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $EnableAzure,
    [Parameter(Mandatory=$true)] [string] $EnableCns,
    [Parameter(Mandatory=$true)] [string] $CnsHostname,
    [Parameter(Mandatory=$true)] [string] $OpenShiftRegistry,
    [Parameter(Mandatory=$true)] [string] $ClusterType,
    [Parameter(Mandatory=$true)] [string] $MasterPrivateClusterIp,
    [Parameter(Mandatory=$true)] [int] $OpenShiftMinorVersion,
    [Parameter(Mandatory=$true)] [string] $InternalEndpoint,
    [Parameter(Mandatory=$true)] [string] $RoutingCertType,
    [Parameter(Mandatory=$true)] [string] $MasterCertType,
    [Parameter(Mandatory=$false)] [string] $MasterLbIpAddress,
    [Parameter(Mandatory=$false)] [string] $InfraLbIpAddress,
    [Parameter(Mandatory=$true)] [string] $RepoIpAddress,
    [Parameter(Mandatory=$false)] [string] $RegistryPortNumber
)

Log-Information "Deploy OpenShift 3.11"
$scriptsPath = "$($(Get-Location).Path)/Ring-0/ocp.3.11/scripts"
$scriptFile = "deployOpenShift.sh"

$OpenShiftRegistryKey = az storage account keys list -n $OpenShiftRegistry -o tsv --query "[?keyName=='key1'].value"

$scriptContent = ((Get-Content "$scriptsPath/$scriptFile") -join "`n")

$scriptContent = $scriptContent.Replace("`${SUDOUSER}", "$AdminUsername")
$scriptContent = $scriptContent.Replace("`${PASSWORD}", "$OpenshiftPassword")
$scriptContent = $scriptContent.Replace("`${MASTER}", "$MasterHostname")
$scriptContent = $scriptContent.Replace("`${MASTERPUBLICIPHOSTNAME}", "$MasterLbIpAddress.nip.io")
$scriptContent = $scriptContent.Replace("`${MASTERPUBLICIPADDRESS}", $MasterLbIpAddress)
$scriptContent = $scriptContent.Replace("`${INFRA}", "$InfraHostname")
$scriptContent = $scriptContent.Replace("`${NODE}", "$NodeHostname")
$scriptContent = $scriptContent.Replace("`${NODECOUNT}", "$nodeInstanceCount")
$scriptContent = $scriptContent.Replace("`${INFRACOUNT}", "$InfraInstanceCount")
$scriptContent = $scriptContent.Replace("`${MASTERCOUNT}", "$MasterInstanceCount")

if ($ClusterType -eq "public")
{
    $scriptContent = $scriptContent.Replace("`${ROUTING}", "$InfraLbIpAddress.nip.io")
}
else
{
    $scriptContent = $scriptContent.Replace("`${ROUTING}", "$RoutingSubDomain")
}

$scriptContent = $scriptContent.Replace("`${METRICS}", "$EnableMetrics")
$scriptContent = $scriptContent.Replace("`${LOGGING}", "$EnableLogging")
$scriptContent = $scriptContent.Replace("`${TENANTID}", "$TenantId")
$scriptContent = $scriptContent.Replace("`${SUBSCRIPTIONID}", "$SubscriptionId")
$scriptContent = $scriptContent.Replace("`${LOCATION}", "$AzureLocation")
$scriptContent = $scriptContent.Replace("`${RESOURCEGROUP}", "$ResourceGroup")
$scriptContent = $scriptContent.Replace("`${AZURE}", "$EnableAzure")
$scriptContent = $scriptContent.Replace("`${ENABLECNS}", "$EnableCns")
$scriptContent = $scriptContent.Replace("`${CNS}", "$CnsHostname")
$scriptContent = $scriptContent.Replace("`${CNSCOUNT}", "$CnsInstanceCount")
$scriptContent = $scriptContent.Replace("`${REGISTRYSA}", "$OpenShiftRegistry")
$scriptContent = $scriptContent.Replace("`${ACCOUNTKEY}", "$OpenShiftRegistryKey")
$scriptContent = $scriptContent.Replace("`${MASTERCLUSTERTYPE}", "$ClusterType")
$scriptContent = $scriptContent.Replace("`${PRIVATEIP}", "$MasterPrivateClusterIp")
$scriptContent = $scriptContent.Replace("`${PRIVATEDNS}", "$MasterClusterDns")
$scriptContent = $scriptContent.Replace("`${MINORVERSION}", "$OpenShiftMinorVersion")
$scriptContent = $scriptContent.Replace("`${REPOSERVER}", "$RepoIpAddress")
$scriptContent = $scriptContent.Replace("`${REGISTRYSERVER}", "$RepoIpAddress$RegistryPortNumber")
$scriptContent = $scriptContent.Replace("`${DEPLOYMENTTYPE}", "$([int]$DeploymentType)")
$scriptContent = $scriptContent.Replace("`${DOCKERREGISTRYREALM}", "$InternalEndpoint")
$scriptContent = $scriptContent.Replace("`${CUSTOMROUTINGCERTTYPE}", "$RoutingCertType")
$scriptContent = $scriptContent.Replace("`${CUSTOMMASTERCERTTYPE}", "$MasterCertType")

$scriptInBytes = [System.Text.Encoding]::UTF8.GetBytes($scriptContent)
$encodedScript = [Convert]::ToBase64String($scriptInBytes)
$jsonFile = "$scriptsPath/deployOpenShift.json"
Set-Content -Path $jsonFile -Value "{`"script`": `"$encodedScript`"}"

$existingExtensions = az vm extension list -g $ResourceGroup --vm-name $BastionMachineName -o json | ConvertFrom-Json

for ($i = 0; $i -lt $existingExtensions.Count; $i++) {
    $ext = $existingExtensions[$i]
    $argList = "vm extension delete " +
                "-g $ResourceGroup " +
                "--vm-name $BastionMachineName " +
                "--name $($ext.Name)"

    $retVal = Run-Command -Process az -Arguments $argList
}

$argList = "vm extension set " +
            "-g $ResourceGroup " +
            "--vm-name $BastionMachineName " +
            "--extension-instance-name deployOpenshift " +
            "--name customScript " +
            "--publisher Microsoft.Azure.Extensions " +
            "--settings $jsonFile"

$retVal = Run-Command -Process az -Arguments $argList

