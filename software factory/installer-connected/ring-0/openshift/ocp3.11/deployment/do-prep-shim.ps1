param (
    # Mandatory Parameters
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $Environment,
    [Parameter(Mandatory=$true)] [string] $RegionLocation,
    [Parameter(Mandatory=$true)] [string] $ShortName,
    [Parameter(Mandatory=$true)] [string] $RhsmUsernameOrOrgId,
    [Parameter(Mandatory=$true)] [string] $rhsmPasswordOrActivationKey,
    [Parameter(Mandatory=$true)] [string] $RhsmPoolId,
    [Parameter(Mandatory=$true)] [string] $RepoIpAddress,
    [Parameter(Mandatory=$true)] [string] $MasterPrivateClusterIp,
    [Parameter(Mandatory=$true)] [string] $RouterPrivateClusterIp,
    [Parameter(Mandatory=$true)] [string] $MasterClusterDns,
    [Parameter(Mandatory=$true)] [string] $RoutingSubDomain,
    [Parameter(Mandatory=$true)] [string] $PrepFileName,
    [Parameter(Mandatory=$true)] [int] $DeploymentType,
    [Parameter(Mandatory=$true)] [int] $InstanceCount,
    # Optional Parameters
    [string] $AdminUsername,
    [string] $MasterCertType,
    [string] $RoutingCertType,
    [string] $RegistryPortNumber,
    [string] $OpenShiftMinorVersion,
    [string] $DomainName,
    [string] $MasterClusterDnsType,
    [string] $RoutingSubDomainType,
    [string] $MasterCertCaFile,
    [string] $MasterCertCrtFile,
    [string] $MasterCertKeyFile,
    [string] $RoutingCertCaFile,
    [string] $RoutingCertCrtFile,
    [string] $RoutingCertKeyFile
)

$prepScriptsPath = "$($(Get-Location).Path)/Ring-0/ocp.3.11/scripts"
$extraScriptsPath = "$($(Get-Location).Path)/Ring-0/extra-scripts"
$certsPath = "$($(Get-Location).Path)/certs"

$jsonFile = "$extraScriptsPath/$ShortName.json"
if (Test-Path $jsonFile)
{
    Remove-Item $jsonFile -Force -Confirm:$false
}
$scriptContent = ((Get-Content "$prepScriptsPath/$PrepFileName") -join "`n")
if($PrepFileName -eq "bastionPrep.sh")
{
    $CustomRoutingCaFile = [string]::Empty
    $CustomRoutingCertFile = [string]::Empty
    $CustomRoutingKeyFile = [string]::Empty
    $CustomMasterCaFile = [string]::Empty
    $CustomMasterCertFile = [string]::Empty
    $CustomMasterKeyFile = [string]::Empty
    if ($MasterCertType -eq "custom")
    {
        $CustomMasterCaFile = ((Get-Content "$certsPath/$MasterCertCaFile") -join "`n")
        $CustomMasterCertFile = ((Get-Content "$certsPath/$MasterCertCrtFile") -join "`n")
        $CustomMasterKeyFile = ((Get-Content "$certsPath/$MasterCertKeyFile") -join "`n")
    }

    if ($RoutingCertType -eq "custom")
    {
        $CustomRoutingCaFile = ((Get-Content "$certsPath/$RoutingCertCaFile") -join "`n")
        $CustomRoutingCertFile = ((Get-Content "$certsPath/$RoutingCertCrtFile") -join "`n")
        $CustomRoutingKeyFile = ((Get-Content "$certsPath/$RoutingCertKeyFile") -join "`n")
    }

    $scriptContent = $scriptContent.Replace("`${USERNAME_ORG}", "$RhsmUsernameOrOrgId")
    $scriptContent = $scriptContent.Replace("`${PASSWORD_ACT_KEY}", "$RhsmPasswordOrActivationKey")
    $scriptContent = $scriptContent.Replace("`${POOL_ID}", "$RhsmPoolId")
    $scriptContent = $scriptContent.Replace("`${SUDOUSER}", "$AdminUsername")
    $scriptContent = $scriptContent.Replace("`${CUSTOMROUTINGCAFILE}", "$CustomRoutingCaFile")
    $scriptContent = $scriptContent.Replace("`${CUSTOMROUTINGCERTFILE}", "$CustomRoutingCertFile")
    $scriptContent = $scriptContent.Replace("`${CUSTOMROUTINGKEYFILE}", "$CustomRoutingKeyFile")
    $scriptContent = $scriptContent.Replace("`${CUSTOMMASTERCAFILE}", "$CustomMasterCaFile")
    $scriptContent = $scriptContent.Replace("`${CUSTOMMASTERCERTFILE}", "$CustomMasterCertFile")
    $scriptContent = $scriptContent.Replace("`${CUSTOMMASTERKEYFILE}", "$CustomMasterKeyFile")
    $scriptContent = $scriptContent.Replace("`${CUSTOMROUTINGCERTTYPE}", "$RoutingCertType")
    $scriptContent = $scriptContent.Replace("`${CUSTOMMASTERCERTTYPE}", "$MasterCertType")
    $scriptContent = $scriptContent.Replace("`${CUSTOMDOMAIN}", "$DomainName")
    $scriptContent = $scriptContent.Replace("`${MINORVERSION}", "$OpenShiftMinorVersion")
    $scriptContent = $scriptContent.Replace("`${CUSTOMMASTERTYPE}", "$MasterClusterDnsType")
    $scriptContent = $scriptContent.Replace("`${CUSTOMROUTINGTYPE}", "$RoutingSubDomainType")
    $scriptContent = $scriptContent.Replace("`${REPOSERVER}", "$RepoIpAddress")
    $scriptContent = $scriptContent.Replace("`${PRIVATEIP}", "$MasterPrivateClusterIp")
    $scriptContent = $scriptContent.Replace("`${ROUTERIP}", "$RouterPrivateClusterIp")
    $scriptContent = $scriptContent.Replace("`${PRIVATEDNS}", "$MasterClusterDns")
    $scriptContent = $scriptContent.Replace("`${INFRADNS}", "$RoutingSubDomain")
    $scriptContent = $scriptContent.Replace("`${DEPLOYMENTTYPE}", "$([int]$DeploymentType)")
    $scriptContent = $scriptContent.Replace("`${REGISTRYSERVER}", "$RepoIpAddress$RegistryPortNumber")
}
else
{
    $scriptContent = $scriptContent.Replace("`${USERNAME_ORG}", "$RhsmUsernameOrOrgId")
    $scriptContent = $scriptContent.Replace("`${PASSWORD_ACT_KEY}", "$rhsmPasswordOrActivationKey")
    $scriptContent = $scriptContent.Replace("`${POOL_ID}", "$RhsmPoolId")
    $scriptContent = $scriptContent.Replace("`${REPOSERVER}", "$RepoIpAddress")
    $scriptContent = $scriptContent.Replace("`${REGISTRYSERVER}", "$RepoIpAddress$RegistryPortNumber")
    $scriptContent = $scriptContent.Replace("`${PRIVATEIP}", "$MasterPrivateClusterIp")
    $scriptContent = $scriptContent.Replace("`${ROUTERIP}", "$RouterPrivateClusterIp")
    $scriptContent = $scriptContent.Replace("`${PRIVATEDNS}", "$MasterClusterDns")
    $scriptContent = $scriptContent.Replace("`${INFRADNS}", "$RoutingSubDomain")
    $scriptContent = $scriptContent.Replace("`${DEPLOYMENTTYPE}", "$([int]$DeploymentType)")
}

$scriptInBytes = [System.Text.Encoding]::UTF8.GetBytes($scriptContent)
$encodedScript = [Convert]::ToBase64String($scriptInBytes)
Set-Content -Path $jsonFile -Value "{`"script`": `"$encodedScript`"}"

$logDate = $(Get-Date -format "yyyy-MM-dd-HHmmss")

1..$InstanceCount | ForEach-Object -Parallel {
    $LogFile = "./deployment-output/vm-prep-arm-$($using:ShortName)_$($_)_$using:logDate.log"
    $n = ([string]$_).PadLeft(3,"0")

    $existingExtensions = az vm extension list -g $using:ResourceGroup --vm-name "$using:Environment-$using:RegionLocation-$using:ShortName-$($n)v" -o json | ConvertFrom-Json

    Log-Information "Found $($existingExtension.Count) existing extensions."
    for ($i = 0; $i -lt $existingExtensions.Count; $i++) {
        $ext = $existingExtensions[$i]
        $argList = "vm extension delete " +
                    "-g $using:ResourceGroup " +
                    "--vm-name $using:Environment-$using:RegionLocation-$using:ShortName-$($n)v " +
                    "--name $($ext.Name)"

        Run-Command -Process "az" -Arguments $argList
    }

    Start-Sleep -Seconds 15

    $argList = "vm extension set " +
                "-g $using:ResourceGroup " +
                "--vm-name $using:Environment-$using:RegionLocation-$using:ShortName-$($n)v " +
                "--extension-instance-name prep " +
                "--name customScript " +
                "--publisher Microsoft.Azure.Extensions " +
                "--settings $using:jsonFile"

    ./do-run-command.ps1 -LogFile $LogFile -Arguments $argList

    # potential workaround for thread locks
    Start-Sleep -Seconds 5
} -AsJob -ThrottleLimit 5 | Receive-Job -Wait
