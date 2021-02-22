#Create empty hash table
$DepArgs = @{}

###!! AZ CLI Configuration !!###
################################
# This section is needed in order for the installer to configure the az cli to work.
# If you are already or can login to the az cli manually, then finding these values will be much easier.

# Possible Values: AzureCloud | AzureUSGovernment | [custom azure/stack config scheme](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-version-profiles-azurecli2?view=azs-2002#connect-to-azure-stack-hub)
#AzureSecretReplace
[string] $DepArgs.AzureCloud = "AzureUSGovernment"
# az account list-locations - Examples: eastus | westus | centralus
#AzureSecretReplace
[string] $DepArgs.AzureLocation = "US Gov Virginia"

# if custom AzureCloud configuration - Stack Example: ppe4.stackpoc.com
#AzureSecretReplace
[string] $DepArgs.AzureDomain = "core.windows.net"
# if custom configuration - Stack Example: 2018-03-01-hybrid
#AzureSecretReplace
[string] $DepArgs.AzureProfile = "latest"

# Azure Subscription ID
# Found: az account list -o table
# Example: f420e201-a02b-4dd2-af6b-f4b5d46ebe27
#AzureSecretReplace
[string] $DepArgs.SubscriptionId = ""

# If portal authenticated, then filling in the following url will show you the tenant id in the value for "token_endpoint"
# https://login.windows.net/[domain]/.well-known/openid-configuration
# Possible domain names:
#   - "yourcompany.com",
#   - "yourcompany.onmicrosoft.com",
# Example: f420e201-a02b-4dd2-af6b-f4b5d46ebe27
#AzureSecretReplace
[string] $DepArgs.TenantId = ""

####################################
###!! END AZ CLI Configuration !!###

###!! Cluster Configuration !!###
#################################

# If ClusterType is private, creates private IP addresses on LBs
# If ClusterType is public, creates public IP addresses on LBs
[string] $DepArgs.ClusterType = "private"

# Possible Values: default | custom
[string] $DepArgs.MasterClusterDnsType = "custom"

# Possible Values: nipio | custom
# if MasterClusterDnsType = "default", RoutingSubDomainType = "nipio"
# if MasterClusterDnsType = "custom", RoutingSubDomainType = "custom"
[string] $DepArgs.RoutingSubDomainType = "custom"

# If MasterClusterDnsType == "custom", then provide expected value below
$CurrentAzureDns = "dev-openshift.com"
[string] $DepArgs.MasterClusterDns = "console.$CurrentAzureDns"
[string] $DepArgs.RoutingSubDomain = "apps.$CurrentAzureDns"

# Possible Values: new | existing
[string] $DepArgs.VirtualNetwork = "new"

# Full vnet range CIDR Notation - Example: 10.1.0.0/16
#AzureSecretReplace
[string] $DepArgs.AddressPrefixes = "10.12.0.0/16"
# Example: OcpVNet
#AzureSecretReplace
[string] $DepArgs.VirtualNetworkName = "OcpVNet"
# Example: MasterInfraSubnet
[string] $DepArgs.MasterInfraSubnetName = "MasterInfraSubnet"
# Use CIDR Notation - Example: 10.1.101.0/24
#AzureSecretReplace
[string] $DepArgs.MasterInfraSubnetPrefix = "10.12.101.0/24"
# Example: NodeSubnet
[string] $DepArgs.NodeSubnetName = "NodeSubnet"
# Use CIDR Notataion - Example: 10.1.102.0/24
#AzureSecretReplace
[string] $DepArgs.NodeSubnetPrefix = "10.12.102.0/24"

# Load balancer IPs, if ClusterType = "private"
# Example: 10.3.101.100
#AzureSecretReplace
[string] $DepArgs.MasterPrivateClusterIp = "10.12.101.100"
# Example: 10.3.101.200
#AzureSecretReplace
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

# Possible Values: Marketplace | vhd
# > IF OsImageType = "Marketplace" and NOT stack then see "default values" for Marketplace values which _should_ work
# > IF OsImageType = "VHD" the VhdDiskName must exist in ./vhd-base/
[string] $DepArgs.OsImageType = "vhd"

# az vm list-sizes --location eastus -o table -> VM SKU info
# az vm list-skus --location eastus -o table -> Storage info
# az vm list-usage --location eastus -o table -> Quota info
# see link for specifics on these VMs
# https://docs.microsoft.com/en-us/azure/virtual-machines/dv2-dsv2-series
[string] $DepArgs.MasterVmSize = "Standard_DS2_v2"
[string] $DepArgs.InfraVmSize = "Standard_DS4_v2"
[string] $DepArgs.NodeVmSize = "Standard_DS4_v2"
[string] $DepArgs.CnsVmSize = "Standard_DS4_v2"

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

[string] $DepArgs.ProductLine = "FF".ToUpper()
[string] $DepArgs.Environment = "BETA".ToUpper()
[string] $DepArgs.RegionLocation = "EAST".ToUpper()

[string] $DepArgs.BastionShortname = "BSTN"
[string] $DepArgs.MasterShortname = "MSTR"
[string] $DepArgs.NodeShortname = "NODE"
[string] $DepArgs.InfraShortname = "INFA"
[string] $DepArgs.CnsShortname = "CNS"

$RandomName = (Get-RandomString -Size 5).ToUpper()
[string] $DepArgs.ResourceGroup = "$($DepArgs.ProductLine)-$($DepArgs.Environment)-$($RandomName)-OCP-RG01"
[string] $DepArgs.VirtualNetworkResourceGroup = "$($DepArgs.ResourceGroup)"

[string] $DepArgs.AvailabilitySetPrefix = "$($DepArgs.Environment)-$($DepArgs.RegionLocation)-$($RandomName)"
[string] $DepArgs.KeyVaultName = "$($DepArgs.AvailabilitySetPrefix)-KV"
[string] $DepArgs.SetupStorage = "$($DepArgs.Environment)$($DepArgs.RegionLocation)$($RandomName)ocpst1".ToLower()
[string] $DepArgs.SetupBlobContainer = "files$($RandomName)bl".ToLower()
$StorageAccountPrefix = "$($DepArgs.Environment)$($DepArgs.RegionLocation)$($RandomName)".ToLower()
[string] $DepArgs.DiagnosticsStorage = "$($StorageAccountPrefix)diagst1".ToLower()
[string] $DepArgs.OpenShiftRegistry = "$($StorageAccountPrefix)regst1".ToLower()

$VirtualMachinePrefix = "$($DepArgs.Environment)-$($DepArgs.RegionLocation)-$($RandomName)"
[string] $DepArgs.BastionHostname = "$($VirtualMachinePrefix)-$($DepArgs.BastionShortname)"
[string] $DepArgs.MasterHostname = "$($VirtualMachinePrefix)-$($DepArgs.MasterShortname)"
[string] $DepArgs.NodeHostname = "$($VirtualMachinePrefix)-$($DepArgs.NodeShortname)"
[string] $DepArgs.InfraHostname = "$($VirtualMachinePrefix)-$($DepArgs.InfraShortname)"
[string] $DepArgs.CnsHostname = "$($VirtualMachinePrefix)-$($DepArgs.CnsShortname)"
[string] $DepArgs.RepoVmName = "$($VirtualMachinePrefix)-SYDR-001v"

##################################
###!! END Naming Conventions !!###

###!! Default Values !!###
##########################

[string] $DepArgs.VhdName = "bravo-registry-osDisk.vhd"
[string] $DepArgs.VhdDiskName = "rhelbase77.vhd"
[string] $DepArgs.VhdImageName = "RHEL77"
[bool] $DepArgs.UploadVhd = $true

# Metrics/Logging for internal OCP instance of ELK
[bool] $DepArgs.EnableMetrics = $false
[bool] $DepArgs.EnableLogging = $false

# RedHat subscription manager config
[string] $DepArgs.RhsmUsernameOrOrgId = "NotUsedInDisconnected"
[string] $DepArgs.RhsmPoolId = "NotUsedInDisconnected"
[string] $DepArgs.RhsmBrokerPoolId = "NotUsedInDisconnected"
[string] $DepArgs.RhsmPasswordOrActivationKey = "NotUsedInDisconnected"

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
[string] $DepArgs.AdminUsername = "ocpadmin"

# Number of OpenShift masters. 1 is non HA. Choose 3 or 5 for HA
[int] $DepArgs.MasterInstanceCount = 3
# Number of OpenShift infra nodes. 1 is non HA. Choose 2 or 3 for HA
[int] $DepArgs.InfraInstanceCount = 3
# Number of OpenShift compute nodes
[int] $DepArgs.NodeInstanceCount = 3
# Number of OpenShift OCS (Storage) nodes. 4 is the default per ref arch
[int] $DepArgs.CnsInstanceCount = 4

[int] $DepArgs.DataDiskSize = 128 # $dataDiskSize = "1024"

# this is the default value
[int] $DepArgs.FaultDomainCount = 2
# If unspecified, the server will pick the most optimal number like 5. 0 won't set it
[int] $DepArgs.UpdateDomainCount = 0

#!! GlusterFS !!#
[bool] $DepArgs.EnableCns = $true # currently azure disks aren't known to work with sequoia and gluster is our only other option
[int] $DepArgs.CnsGlusterDiskSize = 256 # $cnsGlusterDiskSize = "1024"
# If CNS is false, then azure storage blob registry is configured in deployOpenShift.sh
# Possible Values: core.windows.net | core.microsoft.scloud | [other configuration] Example: ppe4.stackpoc.com
[string] $DepArgs.InternalEndpoint = "core.microsoft.scloud"
#!! END GlusterFS !!#

# Possible Values: Connected | Disconnected | DisconnectedStack | DisconnectedLite
[DeploymentType] $DepArgs.DeploymentType = [DeploymentType]::Disconnected
[int] $DepArgs.OpenShiftMinorVersion = 157
[bool] $DepArgs.UploadRepo = $true
[bool] $DepArgs.CreateRepo = $true
[bool] $DepArgs.GenerateSshKey = $false
[bool] $DepArgs.SanitizeLogs = $false

# unless you have a specific reason, don't touch. This will get generated when the artifacts are created
# [string] $DepArgs.SshKey = "please don't touch"

[string] $DepArgs.SshKey = "cfs-gPfAo"





# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUASZg3wkyIww4gRXtAVzNeJP3
# pdugggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
# AQsFADAYMRYwFAYDVQQDDA1KZXJlbXlPbGFjaGVhMB4XDTIwMDgzMTIxMTUxMFoX
# DTIxMDgzMTIxMjQ1OVowGDEWMBQGA1UEAwwNSmVyZW15T2xhY2hlYTCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBAJu5Y9YhmKGhwU+/kj7dsj1OvrliwUCe
# kdPsfdTAPh9peuKKF+ye8U3l3UT8luf5nCYlG/eKe5YxI3pBYhfZwy7yKZpsx5Tn
# ST7t38owgktj0W6YYfoDgfR4zwLtRk3taNWiZeyHu/UhszNs4d3L9wl6Ei/otfRt
# jyz1UO40361YWriD43jbnsCLjVpIfiwW2LH1H9cVoCLnbMZ217rpVxDiTlFPBGeW
# Bk2pxPn5Z2Ly1j6q/SlliEOKDXXrPQZz+sSc3L/ZXBl7D2/ua4+xJmDw/XE1GUBA
# Pldde/IHAzmp6lHHgdQLjCaks//cucDeYBzVTD8XZo8T9WIWU6o6I6SRzGKSIHcX
# SoKVy1hjaW14wJHImw/nlnCgDLMcBBpnRFo6UHAAUzpWlcgqCC+johdXVSa62+hP
# bLwgqfm6uty0rJRwkhbm1Qi0w6HOUZiIkBIz/5Q83t9nLhWL+uWndKIe9BiVfl1f
# x0p5Ax5hzWD5PV1rjrXSQLpL9PRLKcEAy7EoXa/5VGGKSAOrUZdey39vL3AOct0w
# i3vh49DTfWXuxxHbiWz2VEIZqNWQu/rIi9uiCvzaFUo19DwSZrv1ac+OOmZsloqB
# yDugGWFmxiQjEFWtGxEqwDXPDsJE/gKEPvUha37YCI6iQTtcwiwJpnPfGWODqUHH
# 0/NuToVp4ci5AgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
# BgEFBQcDAzAdBgNVHQ4EFgQU16Rx2qHCuXNeExsbMFbSE/Io0NYwDQYJKoZIhvcN
# AQELBQADggIBAG+8jfz9QCzSUK5WGIW0gnEK3rN8oxmSax7C6HJfGPMLXHBEWtBt
# ZCeD8XXkTMu8fhvQDseGgxJ4NmRR+s1d8YtnVgtDbEhO/FHSpOPonTvIx13t37Uz
# Tbvq0ZLeB6z55noAOIhXBs9or1pzxio71sDNfYpIB6s41X5/m1UZk8toxcPDqQGL
# Kg3C3xqgg9+2kQ16flYKvZh2UoK5Y0EyEb8rMc+6AFH3GgcP7yoUsUENP9vkLbXm
# 2VRMIzd/Tee7oKQK50K1GxtlWLUUjuAUMCQh+9K/JyAUro9jfMNHCGcPTaayXBvl
# kaCOjb1IrKgtsS/c2p7mgbssdFHHGPBlbggogGFxYof+6SDI2YB8AqT3RYJdJH4c
# 6StsYUka1faCYcZfz+DIm2+avSCKdliOb285WT8yqoh7P2qN6bLt2au0IsfUKR+d
# EgSL3waCmT+xUI6BI6mpnSjgA0/Hr6I/wkxHu/hk0G0q4OdBpXpSzCzurKPdQWB+
# K/PaQSCyEGk4IGqFrHMx863mtW+mlm6jCM/5/b5ugAmF4XoNkVzdmfFhepqq4h0v
# ioKE+1sLxgq2lFtKAZMjpJB7HZ9KVQcb/hSYlgms/mG6P+4GIhf7ZfvlI2LsCdbV
# 42kEAfDVDuHcCqWyJr43vm+vY6xzjDRnNmaqVJgH1sZO0kwajDOKkm/JMYICzTCC
# AskCAQEwLDAYMRYwFAYDVQQDDA1KZXJlbXlPbGFjaGVhAhAVrGjoMQw2rkF3eYcz
# j/kHMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqG
# SIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3
# AgEVMCMGCSqGSIb3DQEJBDEWBBT1mWW3aK8t2VGu5Hd7AE12xV+JyjANBgkqhkiG
# 9w0BAQEFAASCAgBFoOLkrVV8Z8NmtV6h2ev4Fa6MAs2u1yIGH+t2FRDAtz9IIcuH
# IuEh2wAzVb+G5xNP8hDnJ2HEpj5KVH4jaqmuMP/9p8fcPnBZw5JyN0ueC0LLdzl4
# zaiypfxKZdjtaQLC+aAsgSqS4eEN7l1jszvyTuSHTvQjX1ASnm3c4klgs1lmdfYr
# //UCo+Lkwl4pTxS7X8+9UExVRjb4CWlLqYB9e0RZ52hHI9CdIRrt3S52y8RBFrIO
# LGApHNG5NPyKMd3bKa1Ze2BuQmrT2MNJtkKWC7O/T0zjhYffPnJwSjoEK3LLkdcD
# HSSvoNOjp8Te8WT5dM5VQWbEFgQdN14ERLziMrtH6TYOqjjOGDzWvm3V+r1wayRA
# e4SouxNIPrDJ/hfGeq3XPjYOCqKklSgzpUEUmRdhcroVZjGYeFrdCX+b7taignUv
# s8BzJn1MNrCtVaGSfJU7cfuaDtB0YI1eKaxPihcZtc5cJnM2Q558p3dtxF9g5mY0
# /2wAXjLnmZLHpqu2/M9iKmp/NBTi0cgm3G2oLsH8+AtXIreq/d/OFPKIjlBO40mp
# QUViXsNDpWbLE1sWoMUc3N8mDwBvChyXcbVMkxW3qCRd9+HfKzUCX/ptUX6VD6/G
# iE0XNSuFSNkdYQbkfOekTRrSaU3K65mVtO6LmT+vEWy1sYz3+ANUni02tQ==
# SIG # End signature block
