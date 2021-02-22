# Logstash

**Estimated Time:**

- Smart Hands Preparation Time: 20 mins
- Deployment Time: 30 mins

## Prerequisites

* These instructions assume running in windows
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) - included in install bits
* Latest version of [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7) - included in install bits
* Access to your Azure subscription to create a resources such as:
  * Availability Set
  * Managed Disk
  * Key Vault
  * Load Balancers
  * Network Interfaces
  * Network Security Groups
  * Public IP Address
  * Storage Account
  * Virtual Machine
  * Resource Group

## Deployment (testing) Instructions

Running the deployment will connect to Azure using the cli, deploy the needed resources, prepare the virtual machines for deployment, and deploy Logstash.

1. Open `./deployment/deployment.vars.ps1` in a text editor. We're going to change a few variable values before starting the deployment.

2. In the `AZ CLI Configuration` section, update the following values:
    ```powershell
    [string] $DepArgs.AzureLocation = "usgovvirginia"

    [string] $DepArgs.SubscriptionId = ""

    [string] $DepArgs.TenantId = ""
    ```

3. Set the ip address ranges to something unique. (they should not be the same as OCP or elastic)
    ```powershell
    [string] $DepArgs.VnetRange = "172.17.0.0/16"
    [string] $DepArgs.ClusterSubnetRange = "172.17.6.0/24"
    ```
4.  Update the following vm size SKU if this one is not available.
    ```powershell
    [string] $DepArgs.VmSize = "Standard_DS2_v2"
    ```
5. Edit the "Peering and OCP vars section at the bottom of the page.  If you are using defaults, you will only have to edit the OCPResourceGroup (if you are not using the defaults for elastic, you may have to change the elastic values as well)
    ```powershell
    [string] $DepArgs.VnetPeeringName = "logstash2elastic"
    [string] $DepArgs.ElasticVnetName = "elastic"
    [string] $DepArgs.OCPResourceGroup = "$($ProductLine)-$($Environment)-UMGFD-OCP-RG01"
    ```
    ```powershell
    ##### Elastic Values
    [string] $ElasticMasterShortname = "ESNM"
    [string] $DepArgs.ElasticResourceGroup = "$($ProductLine)-$($Environment)-ELK-RG01"
    [string] $DepArgs.ElasticMasterLoadBalancer = "$($Prefix)-$($ElasticMasterShortname)-LB-PIP"
    [string] $DepArgs.ElasticMasterHostname = "$($Prefix)-$($ElasticMasterShortname)"
    [string] $DepArgs.ElasticKeyVault = "$($ProductLine)-$($Environment)-ELK-RG01-KV" 
    ##### End Elastic Values
    ```
    
6.  If you care about `naming conventions`, then find that section and make changes. No changes are needed there to have a successful deployment. Changing this naming can impact other deployments that rely on the keyvault values.
7.  To begin the deployment:
    1. Open `pwsh.lnk` from the root of this repo
    2. Navigate to the `deployment` folder beside these instructions
    3. Run the following command to execute install file and start the deployment
    ```powershell
    ./install.ps1
    ```

## Post Deployment Steps (success criteria)

When the installation completes, the output should say that it is successful and there should be resources in the named resource group. There is no further validation needed as the deployment does the basic validation.

## Troubleshooting Guide (error mitigation plan)

All installation logs are output to the `./deployment/deployment-output/` folder. Look there first for any issues. There are otherwise no known issues.
