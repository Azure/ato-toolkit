param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $SubscriptionId,
    [Parameter(Mandatory=$true)] [string] $TenantId,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $AzureCloud,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [string] $KeyVaultName,
    [Parameter(Mandatory=$true)] [string] $SetupStorage,
    [Parameter(Mandatory=$true)] [string] $SetupBlobContainer,
    [Parameter(Mandatory=$true)] [string] $RepoVmName,
    [Parameter(Mandatory=$true)] [string] $VhdName,
    [Parameter(Mandatory=$true)] [int] $MasterInstanceCount,
    [Parameter(Mandatory=$true)] [int] $InfraInstanceCount,
    [Parameter(Mandatory=$true)] [int] $NodeInstanceCount,
    [Parameter(Mandatory=$true)] [int] $CnsInstanceCount,
    [Parameter(Mandatory=$true)] [int] $OpenShiftMinorVersion,
    [Parameter(Mandatory=$true)] [string] $MasterVmSize,
    [Parameter(Mandatory=$true)] [string] $InfraVmSize,
    [Parameter(Mandatory=$true)] [string] $NodeVmSize,
    [Parameter(Mandatory=$true)] [string] $CnsVmSize,
    [Parameter(Mandatory=$true)] [string] $OsImageType,
    [Parameter(Mandatory=$true)] [string] $VhdDiskName,
    [Parameter(Mandatory=$true)] [string] $VhdImageName,
    [Parameter(Mandatory=$true)] [bool] $UploadVhd,
    [Parameter(Mandatory=$true)] [string] $MarketplacePublisher,
    [Parameter(Mandatory=$true)] [string] $MarketplaceOffer,
    [Parameter(Mandatory=$true)] [string] $MarketplaceSku,
    [Parameter(Mandatory=$true)] [string] $MarketplaceVersion,
    [Parameter(Mandatory=$true)] [string] $MasterClusterDnsType,
    [Parameter(Mandatory=$true)] [string] $ClusterType,
    [Parameter(Mandatory=$true)] [string] $MasterClusterDns,
    [Parameter(Mandatory=$true)] [string] $RoutingSubDomain,
    [Parameter(Mandatory=$true)] [string] $RoutingSubDomainType,
    [Parameter(Mandatory=$true)] [string] $MasterPrivateClusterIp,
    [Parameter(Mandatory=$true)] [string] $RouterPrivateClusterIp,
    [Parameter(Mandatory=$true)] [string] $MasterInfraSubnetName,
    [Parameter(Mandatory=$true)] [string] $MasterInfraSubnetPrefix,
    [Parameter(Mandatory=$true)] [string] $NodeSubnetName,
    [Parameter(Mandatory=$true)] [string] $NodeSubnetPrefix,
    [Parameter(Mandatory=$true)] [string] $VirtualNetwork,
    [Parameter(Mandatory=$true)] [string] $AddressPrefixes,
    [Parameter(Mandatory=$true)] [string] $VirtualNetworkName,
    [Parameter(Mandatory=$true)] [string] $VirtualNetworkResourceGroup,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [bool] $GenerateSshKey,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$true)] [string] $SshKeyPath,
    [Parameter(Mandatory=$true)] [bool] $UploadRepo,
    [Parameter(Mandatory=$true)] [bool] $CreateRepo,
    [Parameter(Mandatory=$true)] [string] $AzureDomain,
    [Parameter(Mandatory=$true)] [string] $AzureProfile,
    [Parameter(Mandatory=$true)] [string] $InternalEndpoint,
    [Parameter(Mandatory=$true)] [string] $RhsmPasswordOrActivationKey,
    [Parameter(Mandatory=$true)] [string] $DiagnosticsStorage,
    [Parameter(Mandatory=$true)] [string] $OpenShiftRegistry,
    [Parameter(Mandatory=$true)] [bool] $EnableCns,
    [Parameter(Mandatory=$true)] [int] $DataDiskSize,
    [Parameter(Mandatory=$true)] [int] $CnsGlusterDiskSize,
    [Parameter(Mandatory=$true)] [int] $FaultDomainCount,
    [Parameter(Mandatory=$true)] [int] $UpdateDomainCount,
    [Parameter(Mandatory=$true)] [bool] $EnableMetrics,
    [Parameter(Mandatory=$true)] [bool] $EnableLogging,
    [Parameter(Mandatory=$true)] [string] $RhsmUsernameOrOrgId,
    [Parameter(Mandatory=$true)] [string] $RhsmPoolId,
    [Parameter(Mandatory=$true)] [string] $RhsmBrokerPoolId,
    [Parameter(Mandatory=$true)] [string] $DomainName,
    [Parameter(Mandatory=$true)] [string] $RoutingCertType,
    [Parameter(Mandatory=$true)] [string] $MasterCertType,
    [Parameter(Mandatory=$true)] [bool] $EnableAzure,
    [Parameter(Mandatory=$true)] [string] $ProductLine,
    [Parameter(Mandatory=$true)] [string] $Environment,
    [Parameter(Mandatory=$true)] [string] $RegionLocation,
    [Parameter(Mandatory=$true)] [string] $BastionShortname,
    [Parameter(Mandatory=$true)] [string] $MasterShortname,
    [Parameter(Mandatory=$true)] [string] $NodeShortname,
    [Parameter(Mandatory=$true)] [string] $InfraShortname,
    [Parameter(Mandatory=$true)] [string] $CnsShortname,
    [Parameter(Mandatory=$true)] [string] $BastionHostname,
    [Parameter(Mandatory=$true)] [string] $MasterHostname,
    [Parameter(Mandatory=$true)] [string] $NodeHostname,
    [Parameter(Mandatory=$true)] [string] $InfraHostname,
    [Parameter(Mandatory=$true)] [string] $CnsHostname,
    [Parameter(Mandatory=$true)] [string] $AvailabilitySetPrefix,
    [Parameter(Mandatory=$true)] [string] $PublicIpPrefix,
    [Parameter(Mandatory=$false)] [string] $MasterCertCaFile,
    [Parameter(Mandatory=$false)] [string] $MasterCertCrtFile,
    [Parameter(Mandatory=$false)] [string] $MasterCertKeyFile,
    [Parameter(Mandatory=$false)] [string] $RoutingCertCaFile,
    [Parameter(Mandatory=$false)] [string] $RoutingCertCrtFile,
    [Parameter(Mandatory=$false)] [string] $RoutingCertKeyFile,
    [Parameter(Mandatory=$true)] [bool] $SanitizeLogs = $false,
    [Parameter(Mandatory=$false)] [string] $LogFile = "./deployment-output/do-deployment.ps1.log"
)

if ($PSVersionTable.PSVersion.Major -le "6")
{
    Write-Error "You must be running at least PowerShell Core 7"
    exit
}

try {
    # Import common files
    $importFiles = Get-ChildItem "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)\Common\*.ps1"
    if ($importFiles.Count -gt 0) {
        foreach ($file in $importFiles) {
            Write-Host "Importing common library [$($file.BaseName)]"
            . $file.FullName
        }
    } else {
        Write-Host "This script requires additional modules to be loaded.  Could not find any." -ForegroundColor Red
        Write-Host "Exiting script." -ForegroundColor Red
        exit(1)
    }

    # using now in upload and create, but can we further modularize for usage?
    # $azure_blob_endpoint=az storage account show --resource-group $infrastructureRGName --name $artifactSAName --query primaryEndpoints.blob --output tsv

    Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -LogFile $LogFile -ScriptArgs $MyInvocation.MyCommand.Parameters

    ./do-greeting.ps1

    Log-Information "Running in $DeploymentType. Configuring the cli."
    ./do-configure-azurecli.ps1 -DeploymentType $DeploymentType `
        -AzureCloud $AzureCloud `
        -AzureDomain $AzureDomain `
        -AzureProfile $AzureProfile

    Log-Information "Installing Az Copy"
    $AzCopyPath = "./azure-copy.zip"
    if ($IsLinux)
    {
        $AzCopyPath = "./azure-copy.tar.gz"
    }
    ./do-configure-azurecopy.ps1 -DeploymentType $DeploymentType `
        -AzCopyPath $AzCopyPath

    Log-Information "Confirm az cli login"
    ./do-confirm-login.ps1 -SubscriptionId $SubscriptionId `
        -TenantId $TenantId `
        -DeploymentType $DeploymentType

    Log-Information "Create resource group for deployment: $ResourceGroup"
    $retVal = Run-Command -Process "az" -Arguments "group create -l `"$AzureLocation`" -n $ResourceGroup -o table"

    Log-Information "Clean up any existing deployments"
    ./do-cleanup-deployments.ps1 -ResourceGroup $ResourceGroup

    if ($VirtualNetwork -eq "new") {
        .\do-create-subnets.ps1 -ResourceGroup $VirtualNetworkResourceGroup `
            -AddressPrefixes $AddressPrefixes `
            -MasterInfraSubnetName $MasterInfraSubnetName `
            -MasterInfraSubnetPrefix $MasterInfraSubnetPrefix `
            -NodeSubnetName $NodeSubnetName `
            -NodeSubnetPrefix $NodeSubnetPrefix `
            -VirtualNetworkName $VirtualNetworkName
    }

    if ($DeploymentType -eq [DeploymentType]::Connected) {
        $RepoIpAddress = "registry.access.redhat.com"
        $RegistryPortNumber = ""
    } else {
        if ($UploadRepo) {
            Log-Information "Upload repo machine image"
            ./do-deployment-vhd-upload.ps1 -DeploymentType $DeploymentType `
                -SubscriptionId $SubscriptionId `
                -TenantId $TenantId `
                -ResourceGroup $ResourceGroup `
                -AzureLocation $AzureLocation `
                -StorageAccount $SetupStorage `
                -Container $SetupBlobContainer `
                -VhdName $VhdName
        }
        if ($CreateRepo) {
            Log-Information "Create repo machine"
            ./do-deployment-repo-create.ps1 -AzureLocation $AzureLocation `
                -ResourceGroup $ResourceGroup `
                -DeploymentType $DeploymentType `
                -VmName $RepoVmName `
                -SshKey "$SshKey.pub" `
                -StorageAccount $SetupStorage `
                -Container $SetupBlobContainer `
                -VhdName $VhdName `
                -AdminUsername $AdminUsername `
                -VirtualNetworkResourceGroup $VirtualNetworkResourceGroup `
                -VirtualNetworkName $VirtualNetworkName `
                -SubscriptionId $SubscriptionId `
                -MasterInfraSubnetName $MasterInfraSubnetName
        }

        $RepoIpAddress=( az vm show -g $ResourceGroup -n $RepoVmName -d --query privateIps -o tsv )
        Log-Information "Repository Server IP Address: $RepoIpAddress"
        $RegistryPortNumber = ":5000"
    }

    $OpenShiftPassword = Get-RandomString -Size 12
    Log-Information "Setup KeyVault for post install reference"
    ./do-create-keyvault.ps1 -ResourceGroup $ResourceGroup `
        -AzureLocation $AzureLocation `
        -KeyVaultName $KeyVaultName `
        -OpenShiftPassword $OpenShiftPassword `
        -SshPrivateKey $SshKey `
        -RhsmPasswordOrActivationKey $RhsmPasswordOrActivationKey

    Log-Information "Create resource group for deployment: $ResourceGroup"
    Run-Command -Process "az" -Arguments "group create -l `"$AzureLocation`" -n $ResourceGroup -o table"

    $masterInfraSubnetReference = "/subscriptions/$SubscriptionId/resourceGroups/$VirtualNetworkResourceGroup/providers/Microsoft.Network/virtualNetworks/$VirtualNetworkName/subnets/$MasterInfraSubnetName"

    Log-Information "Setup the infrastructure"
    ./do-initial-framework.ps1 -DeploymentType $DeploymentType `
        -ResourceGroup $ResourceGroup `
        -ProductLine $ProductLine `
        -Environment $Environment `
        -RegionLocation $RegionLocation `
        -AzureLocation $AzureLocation `
        -DiagnosticsStorage $DiagnosticsStorage `
        -OpenShiftRegistry $OpenShiftRegistry `
        -BastionShortname $BastionShortname `
        -MasterShortname $MasterShortname `
        -NodeShortname $NodeShortname `
        -InfraShortname $InfraShortname `
        -CnsShortname $CnsShortname `
        -BastionHostname $BastionHostname `
        -MasterHostname $MasterHostname `
        -NodeHostname $NodeHostname `
        -InfraHostname $InfraHostname `
        -CnsHostname $CnsHostname `
        -ClusterType $ClusterType `
        -MasterPrivateClusterIp $MasterPrivateClusterIp `
        -RouterPrivateClusterIp $RouterPrivateClusterIp `
        -MasterInfraSubnetName $masterInfraSubnetReference `
        -FaultDomainCount $FaultDomainCount `
        -UpdateDomainCount $UpdateDomainCount `
        -EnableCns $EnableCns

    ./do-image-vhd.ps1 `
        -OsImageType $OsImageType `
        -UploadVhd $UploadVhd `
        -DeploymentType $DeploymentType `
        -SubscriptionId $SubscriptionId `
        -TenantId $TenantId `
        -ResourceGroup $ResourceGroup `
        -AzureLocation $AzureLocation `
        -SetupStorage $SetupStorage `
        -SetupBlobContainer $SetupBlobContainer `
        -VhdDiskName $VhdDiskName `
        -VhdImageName $VhdImageName

    ./do-vm-create-sets.ps1 `
        -AdminUsername $AdminUsername `
        -AzureLocation $AzureLocation `
        -DataDiskSize $DataDiskSize `
        -ResourceGroup $ResourceGroup `
        -DiagnosticsStorage $DiagnosticsStorage `
        -Environment $Environment `
        -MarketplaceOffer $MarketplaceOffer `
        -MarketplacePublisher $MarketplacePublisher `
        -MarketplaceSku $MarketplaceSku `
        -MarketplaceVersion $MarketplaceVersion `
        -RegionLocation $RegionLocation `
        -SshKey $SshKey `
        -MasterInfraSubnetReference $MasterInfraSubnetReference `
        -OsImageType $OsImageType `
        -VhdImageName $VhdImageName `
        -MasterInstanceCount $MasterInstanceCount `
        -InfraInstanceCount $InfraInstanceCount `
        -NodeInstanceCount $NodeInstanceCount `
        -CnsInstanceCount $CnsInstanceCount `
        -ClusterType $ClusterType `
        -MasterVmSize $MasterVmSize `
        -InfraVmSize $InfraVmSize `
        -NodeVmSize $NodeVmSize `
        -CnsVmSize $CnsVmSize `
        -BastionShortname $BastionShortname `
        -MasterShortname $MasterShortname `
        -NodeShortname $NodeShortname `
        -InfraShortname $InfraShortname `
        -CnsShortname $CnsShortname `
        -EnableCns $EnableCns `
        -CnsGlusterDiskSize $CnsGlusterDiskSize

    $BastionMachineName="$BastionHostname-001v"

    ./do-bastion-setup.ps1 `
        -ResourceGroup $ResourceGroup `
        -BastionMachineName $BastionMachineName

    if ($ClusterType -eq "public")
    {
        $MasterLbIpAddress = $(az network public-ip show --resource-group $ResourceGroup --name "$Environment-$RegionLocation-$MasterShortname-LB-PIP" --query "ipAddress" -o tsv)
        $InfraLbIpAddress = $(az network public-ip show --resource-group $ResourceGroup --name "$Environment-$RegionLocation-$InfraShortname-LB-PIP" --query "ipAddress" -o tsv)
    }

    ./do-vm-prep.ps1 `
        -ResourceGroup $ResourceGroup `
        -Environment $Environment `
        -RegionLocation $RegionLocation `
        -RhsmUsernameOrOrgId $RhsmUsernameOrOrgId `
        -RhsmPasswordOrActivationKey $RhsmPasswordOrActivationKey `
        -RhsmPoolId $RhsmPoolId `
        -RepoIpAddress $RepoIpAddress `
        -RegistryPortNumber $RegistryPortNumber `
        -MasterClusterDns $MasterClusterDns `
        -RoutingSubDomain $RoutingSubDomain `
        -DeploymentType $DeploymentType `
        -MasterInstanceCount $MasterInstanceCount `
        -InfraInstanceCount $InfraInstanceCount `
        -NodeInstanceCount $NodeInstanceCount `
        -CnsInstanceCount $CnsInstanceCount `
        -BastionShortname $BastionShortname `
        -MasterShortname $MasterShortname `
        -NodeShortname $NodeShortname `
        -InfraShortname $InfraShortname `
        -CnsShortname $CnsShortname `
        -EnableCns $EnableCns `
        -AdminUsername $AdminUsername `
        -MasterCertType $MasterCertType `
        -RoutingCertType $RoutingCertType `
        -OpenShiftMinorVersion $OpenShiftMinorVersion `
        -DomainName $DomainName `
        -MasterClusterDnsType $MasterClusterDnsType `
        -RoutingSubDomainType $RoutingSubDomainType `
        -MasterPrivateClusterIp $MasterPrivateClusterIp `
        -RouterPrivateClusterIp $RouterPrivateClusterIp `
        -MasterCertCaFile $MasterCertCaFile `
        -MasterCertCrtFile $MasterCertCrtFile `
        -MasterCertKeyFile $MasterCertKeyFile `
        -RoutingCertCaFile $RoutingCertCaFile `
        -RoutingCertCrtFile $RoutingCertCrtFile `
        -RoutingCertKeyFile $RoutingCertKeyFile `
        -MasterLbIpAddress $MasterLbIpAddress `
        -InfraLbIpAddress $InfraLbIpAddress

    ./do-deploy-ocp-3.ps1 `
        -DeploymentType $DeploymentType `
        -AdminUsername $AdminUsername `
        -OpenshiftPassword $OpenshiftPassword `
        -BastionMachineName $BastionMachineName `
        -MasterHostname $MasterHostname `
        -MasterClusterDns $MasterClusterDns `
        -MasterLbIpAddress $MasterLbIpAddress `
        -InfraLbIpAddress $InfraLbIpAddress `
        -InfraHostname $InfraHostname `
        -NodeHostname $NodeHostname `
        -nodeInstanceCount $nodeInstanceCount `
        -InfraInstanceCount $InfraInstanceCount `
        -MasterInstanceCount $MasterInstanceCount `
        -RoutingSubDomain $RoutingSubDomain `
        -EnableMetrics $EnableMetrics.ToString().ToLower() `
        -EnableLogging $EnableLogging.ToString().ToLower() `
        -TenantId $TenantId `
        -SubscriptionId $SubscriptionId `
        -AzureLocation $AzureLocation `
        -ResourceGroup $ResourceGroup `
        -EnableAzure $EnableAzure.ToString().ToLower() `
        -EnableCns $EnableCns.ToString().ToLower() `
        -CnsHostname $CnsHostname `
        -CnsInstanceCount $CnsInstanceCount `
        -OpenShiftRegistry $OpenShiftRegistry `
        -ClusterType $ClusterType `
        -MasterPrivateClusterIp $MasterPrivateClusterIp `
        -OpenShiftMinorVersion $OpenShiftMinorVersion `
        -RepoIpAddress $RepoIpAddress `
        -RegistryPortNumber $RegistryPortNumber `
        -InternalEndpoint $InternalEndpoint `
        -RoutingCertType $RoutingCertType `
        -MasterCertType $MasterCertType

    $scriptsPath = "$($(Get-Location).Path)/Ring-0/ocp.3.11/scripts"

    if ($DeploymentType -ne [DeploymentType]::Connected) {
        ./do-dnsmasq.ps1 `
            -ResourceGroup $ResourceGroup `
            -ScriptsPath $ScriptsPath `
            -MasterClusterDns $MasterClusterDns `
            -MasterPrivateClusterIp $MasterPrivateClusterIp `
            -RoutingSubDomain $RoutingSubDomain `
            -RouterPrivateClusterIp $RouterPrivateClusterIp `
            -MasterHostname $MasterHostname `
            -MasterInstanceCount $MasterInstanceCount `
            -InfraHostname $InfraHostname `
            -InfraInstanceCount $InfraInstanceCount `
            -NodeHostname $NodeHostname `
            -NodeInstanceCount $NodeInstanceCount `
            -EnableCns $EnableCns `
            -CnsHostname $CnsHostname `
            -CnsInstanceCount $CnsInstanceCount
    }

    if ($EnableCns)
    {
        Log-Information "Prepare gluster storageclass script for end of deployment"
        $glusterScript = "master_gluster_default_storageclass.sh"
New-Item -Path "$ScriptsPath/$glusterScript" -Force -ItemType file -Value @"
sudo kubectl patch storageclass glusterfs-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
"@

        $jsonFile = New-Base64EncodedJson -ScriptPath $ScriptsPath -ScriptFileName $glusterScript
        New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName "$MasterHostname-001v" -JsonFile $jsonFile
    }

    Log-Information "Deployment complete"

    Log-Information "Verifying install"
    ./do-verify-ocp-3.ps1 -ResourceGroup $ResourceGroup `
        -MasterOneHostname $MasterHostname-001v `
        -BastionOneHostname $BastionMachineName `
        -RoutingSubDomain $RoutingSubDomain

    Log-Information "Deployment Complete!"
    Write-Host "Your OpenShift console password is: $OpenShiftPassword"
    Write-Host "Please retain to be able to log into administrator the cluster"
    Read-Host "Press any key to close"
}
catch {

    ./do-entertain-user.ps1 -JohnnyType -1

    Log-Error $_
    Log-Error "There was an issue with the deployment. Please check the deployment-output folder for more details."
    Read-Host "Press any key to close"
}
finally {
    if ($SanitizeLogs)
    {
        ./do-sanitizelogs.ps1
    }

    Log-ScriptEnd
}
