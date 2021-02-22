# OpenShift 3.11

**Estimated Time:**

- Smart Hands Preparation Time: 30 mins
- Deployment Time: 90 mins

## Prerequisites

* These instructions assume running in windows
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) - included in install bits
* Latest version of [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7) - included in install bits
* Access to your Azure subscription to create a resources such as:
  * Resource Group
  * Virtual Machine
  * Storage Account
  * Availability Set
  * Managed Disk
  * Image
  * Key Vault
  * Load Balancers
  * Network Interfaces
  * Network Security Groups

## Deployment (testing) Instructions

Running the deployment will connect to Azure using the cli, deploy the needed resources, prepare the virtual machines for deployment, and deploy an OCP 3.11.

1. Download the [SYDR (streamlined yum docker repository) VHD](https://thesearemyfilesthankyou.blob.core.windows.net/deploy/bravo-registry-osDisk.vhd?sv=2019-02-02&st=2020-07-27T17%3A40%3A08Z&se=2020-09-28T17%3A40%3A00Z&sr=b&sp=r&sig=ATtx%2F2iDO%2BcX%2FuDmbeH6xCnKeIgdLj3YIoRYUasvIWs%3D).
2. Place it into the `./deployment/repo/` folder.
3. Download the [RHEL77 base VHD](https://thesearemyfilesthankyou.blob.core.windows.net/deploy/rhelbase77.vhd.zip?sv=2019-10-10&st=2020-09-15T13%3A09%3A17Z&se=2020-10-16T13%3A09%3A00Z&sr=b&sp=r&sig=7la8PQ6KYeu%2BAbg4SqFvJtL%2FHe0NwHdSzQaflRdRkVM%3D).
4. Place it into the `./deployment/vhd-base/` folder.
5. Open `./deployment/deployment.vars.ps1` in a text editor. We're going to change a few variable values before starting the deployment.
6. In the `AZ CLI Configuration` section, update the following values:
    ```powershell
    [string] $DepArgs.AzureCloud = "AzureUSGovernment"

    [string] $DepArgs.AzureLocation = "usgovvirginia"

    [string] $DepArgs.AzureDomain = "core.windows.net"

    [string] $DepArgs.AzureProfile = "latest"

    [string] $DepArgs.SubscriptionId = ""

    [string] $DepArgs.TenantId = ""
    ```

7. Set the cluster type value. If it is set to private, then the load balancers that expose the cluster console and applications will use private ip addresses. However, if public, then public ip addresses will be used.
    ```powershell
    [string] $DepArgs.ClusterType = "public"
    ```
8. Set the Azure DNS, if any. If there is not any then you can leave the value. It will then require host file entries to access the cluster console and applications.
    ```powershell
    $CurrentAzureDns = "dev-openshift.com"
    ```
9. Determine if you want to create a new virtual network for the deployment. `New` is the default choice here. If you need the cluster to exist in a specific virtual network, then set this to existing.
    ```powershell
    [string] $DepArgs.VirtualNetwork = "new"
    ```
   1. If the virtual network is set to `new` both `[string] $DepArgs.MasterInfraSubnetName` and `[string] $DepArgs.NodeSubnetName` can be left alone.
   2. If the virtual network is set to `existing`
      1. Change the `[string] $DepArgs.VirtualNetworkName` to the name of the virtual network you want to use that already exists.
      2. Scroll down the file and find `[string] $DepArgs.VirtualNetworkResourceGroup`. Change this value to the resource group where the virtual network being used is deployed.
      3. Both `[string] $DepArgs.MasterInfraSubnetName` and `[string] $DepArgs.NodeSubnetName` should already exist on the virtual network. If they do not, then they need to be created.
10. Set the address prefixes. This will be the range that the cluster is deployed into. If using an existing virtual network from above, make sure the range here works for that virtual network.
    ```powershell
    [string] $DepArgs.AddressPrefixes = "10.12.0.0/16"
    [string] $DepArgs.MasterInfraSubnetPrefix = "10.12.101.0/24"
    [string] $DepArgs.NodeSubnetPrefix = "10.12.102.0/24"
    ```
11. If the cluster type above is set to private, then the following settings need to be part of `$DepArgs.MasterInfraSubnetPrefix`.
    ```powershell
    [string] $DepArgs.MasterPrivateClusterIp = "10.12.101.100"
    [string] $DepArgs.RouterPrivateClusterIp = "10.12.101.200"
    ```
12. Update the following vm size SKUs if these are not available.
    ```powershell
    [string] $DepArgs.MasterVmSize = "Standard_DS2_v2"
    [string] $DepArgs.InfraVmSize = "Standard_DS4_v2"
    [string] $DepArgs.NodeVmSize = "Standard_DS4_v2"
    [string] $DepArgs.CnsVmSize = "Standard_DS4_v2"
    ```
13. If you care about `naming conventions`, then find that section and make changes. No changes are needed there to have a successful deployment. If you chose to make changes, it will impact the changes needed when deploying other applications.
14. To begin the deployment:
    1. Open `./pwsh.lnk` from the root of this repo
    2. Navigate to the `deployment` folder beside these instructions
    3. Run the following command to execute install file and start the deployment
    ```powershell
    ./install.ps1
    ```

## Post Deployment Steps (success criteria)

When the installation completes, the password to access the OpenShift Console will be output to the console window. The default user is `ocpadmin`. The installation uses self signed certificates by default. The means that when opening the OpenShift Console, you will have to chose to continue past an untrusted certificate because the issuer is not know. However, we know that we can trust the certificate because we just completed the install.

> [!TIP]
> If you lose the OpenShift Console password, then it can be found in the KeyVault created in the deployment.

Assessing the OpenShift Console will depend on the value you set in step #6. By default it uses `dev-openshift.com` and therefore the link will be `https://console.dev-openshift.com/`. Depending on if you have DNS, you may have to create a host file entry to point `console.dev-openshift.com` at the ip address of `MasterPrivateClusterIp` (which defaults to `10.12.101.100`) from step #9 before you can access the console.

## Troubleshooting Guide (error mitigation plan)

All installation logs are output to the `./deployment/deployment-output/` folder. Look there first for any issues.

1. If you get a naming conflict error then you might have to adjust how resources get named in the `./deployment/deployment.vars.*.ps1` file. Look for the `Naming Conventions` section.
2. The install occasionally has trouble deploying the ansible playbooks. A typical installation during the `deploy openshift` step takes at least 40 minutes. If you see a deployment hang, then fail you can usually delete the deployment and start again. This is part of the ansible playbooks used to deploy OCP 3.11 and not something this tool is intended to correct.
3. The `deploy openshift` step can fail if you do not have the correct RedHat subscription. You should see an error similar to: `ERROR! the playbook: /usr/share/ansible/openshift-ansible/playbooks/openshift-node/network_manager.yml could not be found`. You should confirm your subscription supports an OpenShift deployment.
4. If you have any issues during the `deploy openshift` step you can ssh to the bastion virtual machine using the ssh key you generated. Then run the following command to see what ansible did: `sudo cat /var/lib/waagent/custom-script/download/0/stdout`
5. **Azure Stack Hub** - The VM sizes you use, number of VMs, and disk sizes are all dependant upon the resources your installation have available. If you have any resource issues during installation, they could be caused by this.
