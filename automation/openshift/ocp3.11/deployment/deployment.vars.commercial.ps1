#Create empty hash table
$DepArgs = @{}

# input the ssh key (without the .pub) that you generated
[string] $DepArgs.SshKey = "your-ssh-key"

# RedHat Subscription Manager config
# https://access.redhat.com/products/red-hat-subscription-management
[string] $DepArgs.RhsmUsernameOrOrgId = "email used to login"
[string] $DepArgs.RhsmPoolId = "random string of 32 characters"
[string] $DepArgs.RhsmBrokerPoolId = "can be the exact same as the pool id"
[string] $DepArgs.RhsmPasswordOrActivationKey = "password used to login"

###!! AZ CLI Configuration !!###
################################
# This section is needed in order for the installer to configure the az cli to work.
# If you are already or can login to the az cli manually, then finding these values will be much easier.

# az account list-locations - Examples: usgovvirginia | usgoviowa | usdodeast | usdodcentral | usgovtexas | usgovarizona
[string] $DepArgs.AzureLocation = "eastus"

# Azure Subscription ID
# Found: az account list -o table
# Example: f420e201-a02b-4dd2-af6b-f4b5d46ebe27
[string] $DepArgs.SubscriptionId = "12345678-1234-1234-1234-1234567890ab"

# If portal authenticated, then filling in the following url will show you the tenant id in the value for "token_endpoint"
# https://login.windows.net/[domain]/.well-known/openid-configuration
# Possible domain names:
#   - "yourcompany.com",
#   - "yourcompany.onmicrosoft.com",
# Example: f420e201-a02b-4dd2-af6b-f4b5d46ebe27
[string] $DepArgs.TenantId = "12345678-1234-1234-1234-1234567890ab"

####################################
###!! END AZ CLI Configuration !!###

###!! Cluster Configuration !!###
#################################

# If ClusterType is private, creates private IP addresses on LBs
# If ClusterType is public, creates public IP addresses on LBs
[string] $DepArgs.ClusterType = "public"

# Possible Values: default | custom
[string] $DepArgs.MasterClusterDnsType = "default"

# Possible Values: nipio | custom
# if MasterClusterDnsType = "default", RoutingSubDomainType = "nipio"
# if MasterClusterDnsType = "custom", RoutingSubDomainType = "custom"
[string] $DepArgs.RoutingSubDomainType = "nipio"

# If MasterClusterDnsType == "custom", then provide expected value below
$CurrentAzureDns = "dev-openshift.com"
[string] $DepArgs.MasterClusterDns = "console.$CurrentAzureDns"
[string] $DepArgs.RoutingSubDomain = "apps.$CurrentAzureDns"

# Possible Values: new | existing
[string] $DepArgs.VirtualNetwork = "new"

# Full vnet range CIDR Notation - Example: 10.1.0.0/16
[string] $DepArgs.AddressPrefixes = "10.12.0.0/16"
# Example: OcpVNet
[string] $DepArgs.VirtualNetworkName = "OcpVNet"
# Example: MasterInfraSubnet
[string] $DepArgs.MasterInfraSubnetName = "MasterInfraSubnet"
# Use CIDR Notation - Example: 10.1.101.0/24
[string] $DepArgs.MasterInfraSubnetPrefix = "10.12.101.0/24"
# Example: NodeSubnet
[string] $DepArgs.NodeSubnetName = "NodeSubnet"
# Use CIDR Notataion - Example: 10.1.102.0/24
[string] $DepArgs.NodeSubnetPrefix = "10.12.102.0/24"

# Load balancer IPs, if ClusterType = "private"
# Example: 10.3.101.100
[string] $DepArgs.MasterPrivateClusterIp = "10.12.101.100"
# Example: 10.3.101.200
[string] $DepArgs.RouterPrivateClusterIp = "10.12.101.200"

# Possible Values: selfsigned | custom
[string] $DepArgs.RoutingCertType = "selfsigned"
# if RoutingCertType = "custom", then provide values here.
# Files need to exist under .\certs\ folder
# Extensions expected are: .ca-bundle & .crt & .key
[string] $DepArgs.RoutingCertCaFile = ".ca-bundle"
[string] $DepArgs.RoutingCertCrtFile = ".crt"
[string] $DepArgs.RoutingCertKeyFile = ".key"

# Possible Values: selfsigned | custom
[string] $DepArgs.MasterCertType = "selfsigned"
# if MasterCertType = "custom", then provide values here.
# Files need to exist under .\certs\ folder
# Extensions expected are: .ca-bundle & .crt & .key
[string] $DepArgs.MasterCertCaFile = ".ca-bundle"
[string] $DepArgs.MasterCertCrtFile = ".crt"
[string] $DepArgs.MasterCertKeyFile = ".key"

# az vm list-sizes --location eastus -o table -> VM SKU info
# az vm list-skus --location eastus -o table -> Storage info
# az vm list-usage --location eastus -o table -> Quota info
# see link for specifics on these VMs
# https://docs.microsoft.com/en-us/azure/virtual-machines/dv2-dsv2-series
[string] $DepArgs.MasterVmSize = "Standard_DS2_v2"
[string] $DepArgs.InfraVmSize = "Standard_DS2_v2"
[string] $DepArgs.NodeVmSize = "Standard_DS2_v2"
[string] $DepArgs.CnsVmSize = "Standard_DS2_v2"


# Number of OpenShift masters. 1 is non HA. Choose 3 or 5 for HA
[int] $DepArgs.MasterInstanceCount = 3
# Number of OpenShift infra nodes. 1 is non HA. Choose 2 or 3 for HA
[int] $DepArgs.InfraInstanceCount = 3
# Number of OpenShift compute nodes
[int] $DepArgs.NodeInstanceCount = 3

[int] $DepArgs.DataDiskSize = 128 # $dataDiskSize = "1024"


####!! GlusterFS !!####

# Number of OpenShift OCS (Storage) nodes. 4 is the default per ref arch
[int] $DepArgs.CnsInstanceCount = 4

[bool] $DepArgs.EnableCns = $false # currently azure disks aren't known to work with sequoia and gluster is our only other option
[int] $DepArgs.CnsGlusterDiskSize = 256 # $cnsGlusterDiskSize = "1024"
# If CNS is false, then azure storage blob registry is configured in deployOpenShift.sh
# Possible Values: core.windows.net | [other configuration] Example: endpoint.stackpoc.com
[string] $DepArgs.InternalEndpoint = "core.windows.net"

####!! END GlusterFS !!####

#####################################
###!! END Cluster Configuration !!###

###!! Naming Conventions !!###
##############################

# Change to your naming conventions.  The following config will create
# <ProductLine>-<Environment>-<RegionLocation>
# EXAMPLEs:
# ResourceGroup: STK-S2-RLOC-OCP-RG01
# Availability set: S2-RLOC-MSTR-AS01
# Load balancer: S2-RLOC-MSTR-LB
# VM: S2-RLOC-BSTN-001v
# Disk: S2-RLOC-BSTN-001v-DOCKER-POOL
# Disk: S2-RLOC-BSTN-001v-OSDISK
# Network interface: S2-RLOC-BSTN-001v-NIC-001
# Public IP address: S2-RLOC-BSTN-LB-PIP
# Network Security Group: S2-RLOC-BSTN-NSG
# Storage account: s2rlocregst001
# Key vault: STK-S2-RLOC-RG01-KV

[string] $DepArgs.ProductLine = "DEMO".ToUpper()
[string] $DepArgs.Environment = "ZTA".ToUpper()
[string] $DepArgs.RegionLocation = "GOV".ToUpper()

[string] $DepArgs.BastionShortname = "BSTN"
[string] $DepArgs.MasterShortname = "MSTR"
[string] $DepArgs.NodeShortname = "NODE"
[string] $DepArgs.InfraShortname = "INFA"
[string] $DepArgs.CnsShortname = "CNS"

[string] $DepArgs.ResourceGroup = "$($DepArgs.ProductLine)-$($DepArgs.Environment)-OCP3-RG01"
[string] $DepArgs.VirtualNetworkResourceGroup = "$($DepArgs.ResourceGroup)"

[string] $DepArgs.AvailabilitySetPrefix = "$($DepArgs.Environment)-$($DepArgs.RegionLocation)"
[string] $DepArgs.PublicIpPrefix = "$($DepArgs.Environment)$($DepArgs.RegionLocation)".ToLower()
[string] $DepArgs.KeyVaultName = "$($DepArgs.ResourceGroup)-KV"
[string] $DepArgs.SetupStorage = "$($DepArgs.Environment)$($DepArgs.RegionLocation)`ocpst002".ToLower()
[string] $DepArgs.SetupBlobContainer = "filesbl"
$StorageAccountPrefix = "$($DepArgs.Environment)$($DepArgs.RegionLocation)".ToLower()
[string] $DepArgs.DiagnosticsStorage = "$($StorageAccountPrefix)`diagst001".ToLower()
[string] $DepArgs.OpenShiftRegistry = "$($StorageAccountPrefix)regst001".ToLower()

$VirtualMachinePrefix = "$($DepArgs.Environment)-$($DepArgs.RegionLocation)"
[string] $DepArgs.BastionHostname = "$($VirtualMachinePrefix)-$($DepArgs.BastionShortname)"
[string] $DepArgs.MasterHostname = "$($VirtualMachinePrefix)-$($DepArgs.MasterShortname)"
[string] $DepArgs.NodeHostname = "$($VirtualMachinePrefix)-$($DepArgs.NodeShortname)"
[string] $DepArgs.InfraHostname = "$($VirtualMachinePrefix)-$($DepArgs.InfraShortname)"
[string] $DepArgs.CnsHostname = "$($VirtualMachinePrefix)-$($DepArgs.CnsShortname)"
[string] $DepArgs.RepoVmName = "$($VirtualMachinePrefix)-SYDR-001v"

##################################
###!! END Naming Conventions !!###



[bool] $DepArgs.SanitizeLogs = $false

# Metrics/Logging for internal OCP instance of ELK
[bool] $DepArgs.EnableMetrics = $false
[bool] $DepArgs.EnableLogging = $false

[string] $DepArgs.AdminUsername = "ocpadmin"



###!! Do Not Touch !!###
########################

# Possible Values: AzureCloud | AzureUSGovernment | [custom azure/stack config scheme](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-version-profiles-azurecli2?view=azs-2002#connect-to-azure-stack-hub)
[string] $DepArgs.AzureCloud = "AzureCloud"
# if custom AzureCloud configuration - Stack Example: endpoint.stackpoc.com
[string] $DepArgs.AzureDomain = "core.windows.net"
# if custom configuration - Stack Example: 2018-03-01-hybrid
[string] $DepArgs.AzureProfile = "latest"

# Possible Values: Marketplace | vhd
# > IF OsImageType = "Marketplace" and NOT stack then see "default values" for Marketplace values which _should_ work
# > IF OsImageType = "VHD" the VhdDiskName must exist in ./vhd-base/
[string] $DepArgs.OsImageType = "Marketplace"

[string] $DepArgs.VhdName = "registry-osDisk.vhd"
[string] $DepArgs.VhdDiskName = "rhelbase77.vhd"
[string] $DepArgs.VhdImageName = "RHEL77"
[bool] $DepArgs.UploadVhd = $false

# You can find values for RHEL 7.7 by running:
# az vm image list --all --offer "RHEL" --output table
[string] $DepArgs.MarketplacePublisher = "RedHat"
[string] $DepArgs.MarketplaceOffer = "RHEL"
[string] $DepArgs.MarketplaceSku = "7-RAW"
[string] $DepArgs.MarketplaceVersion = "latest"

# This value only matters for stack deployments. Used for az cli
[string] $DepArgs.DomainName = "none"
[bool] $DepArgs.EnableAzure = $false

# SshKeyPath is path to cert files on local/deployment machine
[string] $DepArgs.SshKeyPath = "./certs/"

# this is the default value
[int] $DepArgs.FaultDomainCount = 2
# If unspecified, the server will pick the most optimal number like 5. 0 won't set it
[int] $DepArgs.UpdateDomainCount = 0

# Possible Values: Connected | Disconnected | DisconnectedStack | DisconnectedLite
[DeploymentType] $DepArgs.DeploymentType = [DeploymentType]::Connected
[int] $DepArgs.OpenShiftMinorVersion = 157
[bool] $DepArgs.UploadRepo = $false
[bool] $DepArgs.CreateRepo = $false
[bool] $DepArgs.GenerateSshKey = $false
