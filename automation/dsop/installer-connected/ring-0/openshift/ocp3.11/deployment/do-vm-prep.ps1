param (
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $Environment,
    [Parameter(Mandatory=$true)] [string] $RegionLocation,
    [Parameter(Mandatory=$true)] [string] $RhsmUsernameOrOrgId,
    [Parameter(Mandatory=$true)] [string] $RhsmPasswordOrActivationKey,
    [Parameter(Mandatory=$true)] [string] $RhsmPoolId,
    [Parameter(Mandatory=$true)] [string] $RepoIpAddress,
    [Parameter(Mandatory=$false)] [string] $RegistryPortNumber,
    [Parameter(Mandatory=$true)] [string] $MasterClusterDns,
    [Parameter(Mandatory=$true)] [string] $RoutingSubDomain,
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [int] $MasterInstanceCount,
    [Parameter(Mandatory=$true)] [int] $InfraInstanceCount,
    [Parameter(Mandatory=$true)] [int] $NodeInstanceCount,
    [Parameter(Mandatory=$true)] [int] $CnsInstanceCount,
    [Parameter(Mandatory=$true)] [string] $BastionShortname,
    [Parameter(Mandatory=$true)] [string] $MasterShortname,
    [Parameter(Mandatory=$true)] [string] $NodeShortname,
    [Parameter(Mandatory=$true)] [string] $InfraShortname,
    [Parameter(Mandatory=$true)] [string] $CnsShortname,
    [Parameter(Mandatory=$true)] [bool] $EnableCns,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $MasterCertType,
    [Parameter(Mandatory=$true)] [string] $RoutingCertType,
    [Parameter(Mandatory=$true)] [string] $OpenShiftMinorVersion,
    [Parameter(Mandatory=$true)] [string] $DomainName,
    [Parameter(Mandatory=$true)] [string] $MasterClusterDnsType,
    [Parameter(Mandatory=$true)] [string] $RoutingSubDomainType,
    [Parameter(Mandatory=$true)] [string] $MasterPrivateClusterIp,
    [Parameter(Mandatory=$true)] [string] $RouterPrivateClusterIp,
    [Parameter(Mandatory=$false)] [string] $MasterCertCaFile,
    [Parameter(Mandatory=$false)] [string] $MasterCertCrtFile,
    [Parameter(Mandatory=$false)] [string] $MasterCertKeyFile,
    [Parameter(Mandatory=$false)] [string] $RoutingCertCaFile,
    [Parameter(Mandatory=$false)] [string] $RoutingCertCrtFile,
    [Parameter(Mandatory=$false)] [string] $RoutingCertKeyFile,
    [Parameter(Mandatory=$false)] [string] $MasterLbIpAddress,
    [Parameter(Mandatory=$false)] [string] $InfraLbIpAddress
)

$ShimParams = @{}
$ShimParams.ResourceGroup = $ResourceGroup
$ShimParams.Environment = $Environment
$ShimParams.RegionLocation = $RegionLocation
$ShimParams.RhsmUsernameOrOrgId = $RhsmUsernameOrOrgId
$ShimParams.RhsmPasswordOrActivationKey = $RhsmPasswordOrActivationKey
$ShimParams.RhsmPoolId = $RhsmPoolId
$ShimParams.RepoIpAddress = $RepoIpAddress
$ShimParams.RegistryPortNumber = $RegistryPortNumber
$ShimParams.MasterClusterDns = $MasterClusterDns
$ShimParams.RoutingSubDomain = $RoutingSubDomain
$ShimParams.DeploymentType = $DeploymentType
#Optional Params supplied only for bastionPrep.sh
$ShimParams.AdminUsername = $AdminUsername
$ShimParams.MasterCertType = $MasterCertType
$ShimParams.RoutingCertType = $RoutingCertType
$ShimParams.OpenShiftMinorVersion = $OpenShiftMinorVersion
$ShimParams.DomainName = $DomainName
$ShimParams.MasterClusterDnsType = $MasterClusterDnsType
$ShimParams.RoutingSubDomainType = $RoutingSubDomainType
$ShimParams.MasterPrivateClusterIp = $MasterPrivateClusterIp
$ShimParams.RouterPrivateClusterIp = $RouterPrivateClusterIp

if ($ClusterType -eq "public")
{
    $ShimParams.MasterPrivateClusterIp = $MasterLbIpAddress
    $ShimParams.RouterPrivateClusterIp = $InfraLbIpAddress
}

$ShimParams.MasterCertCaFile = $MasterCertCaFile
$ShimParams.MasterCertCrtFile = $MasterCertCrtFile
$ShimParams.MasterCertKeyFile = $MasterCertKeyFile
$ShimParams.RoutingCertCaFile = $RoutingCertCaFile
$ShimParams.RoutingCertCrtFile = $RoutingCertCrtFile
$ShimParams.RoutingCertKeyFile = $RoutingCertKeyFile

$Job = 1..5 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            Write-Output "Run bastion prep"
            ./do-prep-shim.ps1 @using:ShimParams `
                -ShortName $using:BastionShortname `
                -InstanceCount 1 `
                -PrepFileName "bastionPrep.sh"
        }
        2 {
            Write-Output "Run master prep"
            ./do-prep-shim.ps1 @using:ShimParams `
                -ShortName $using:MasterShortname `
                -InstanceCount $using:MasterInstanceCount `
                -PrepFileName "masterPrep.sh"
        }
        3 {
            Write-Output "Run infra prep"
            ./do-prep-shim.ps1 @using:ShimParams `
                -ShortName $using:InfraShortname `
                -InstanceCount $using:InfraInstanceCount `
                -PrepFileName "infraPrep.sh"
        }
        4 {
            Write-Output "Run node prep"
            ./do-prep-shim.ps1 @using:ShimParams `
                -ShortName $using:NodeShortname `
                -InstanceCount $using:NodeInstanceCount `
                -PrepFileName "nodePrep.sh"
        }
        5 {
            if ($using:EnableCns)
            {
                Write-Output "Run cns prep"
                #This uses nodeprep.sh
                ./do-prep-shim.ps1 @using:ShimParams `
                    -ShortName $using:CnsShortname `
                    -InstanceCount $using:CnsInstanceCount `
                    -PrepFileName "nodePrep.sh"
            }
        }
    }

    # potential workaround for thread locks
    Start-Sleep -Seconds 5
} -AsJob -ThrottleLimit 5
$Job | Receive-Job -Wait
