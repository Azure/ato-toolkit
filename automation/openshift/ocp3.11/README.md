## OpenShift 3.11 automated install solution across Azure fabrics (preview)

This install is a secure deployment of RedHat OpenShift on Azure. The deployment is unique as its automated and has hardening baked-in.

Environments include:
- [Azure Commercial (Connected)](#azure-commercial-connected)
- [Azure US Government (Connected)](#azure-us-government-connected)
- [Azure Stack Hub (Connected)](#azure-stack-hub-connected)
- [Azure Secret (Disconnected)](#azure-secret-disconnected)

## Prerequisites

* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
* Latest version of [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7)
* [openssh](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_overview) for using `ssh-keygen` to create an ssh key
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
* [Red Hat Subscription Manager](https://access.redhat.com/products/red-hat-subscription-management) information

## Preparation

1. Clone repo or download this folder
2. Generate an ssh key [Learn how to](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys)
3. Create a `certs` folder in the `deployment` folder
4. Put the public and private ssh keys in the `./deployment/certs/` folder
5. Gather Red Hat Subscription Manager info:
   1. Username or Organization Id (ex. your email you use to log into the portal)
   2. Pool Id (ex. a random string of 32 characters)
   3. Broker Pool Id (ex. can be the exact same as the pool id)
   4. Password or Activation Key (ex. the password you use to log into the portal)

## ZTA Adjustment

The current implementation of Zero Trust includes a DNS server. This breaks the deployment of OCP 3.11 inside of it. Because of this, we must adjust the Virtual Network deployed by the blueprint to use Azure DNS. Follow these instructions to complete that.

1. Navigate to the Virtual Network named `contest-sharedsvcs-vnet`
2. In the left hand navigation menu, select `DNS servers`
3. Select `Default (Azure-provided)`
4. Save the changes and wait for them to complete before starting any deployment

## Deployment Environments

Running the deployment will connect to Azure using the cli, deploy the needed resources, prepare the virtual machines for deployment, and deploy an OCP 3.11.

> Note: Any **connected** deployment will deploy as a public cluster using [nip.io](https://nip.io/) as dns and use a self-signed certificate. It will be configured to be highly available. Metrics and logging will not be installed by default. The minor version will be 157. The urls will be [https://[insert-load-balancer-ip].nip.io]() for the console and apps.

### Azure Commercial (Connected)

1. Open `./deployment/deployment.vars.commercial.ps1` in [your favorite editor](https://code.visualstudio.com/download). We're going to change a few variable values at the top before starting the deployment.
2. Update SshKey with the one you generated
    ```powershell
    [string] $DepArgs.SshKey = "your-ssh-key"
    ```
3. Update your RedHat Subscription manager information
    ```powershell
    [string] $DepArgs.RhsmUsernameOrOrgId = "email used to login"
    [string] $DepArgs.RhsmPoolId = "random string of 32 characters"
    [string] $DepArgs.RhsmBrokerPoolId = "can be the exact same as the pool id"
    [string] $DepArgs.RhsmPasswordOrActivationKey = "password used to login"
    ```
4. Input the Azure location you would like to use. [Learn how to](https://docs.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest#az-account-list-locations)
    ```powershell
    [string] $DepArgs.AzureLocation = "eastus"
    ```

    > [!TIP]
    > Examples include: eastus | westus | centralus | northcentralus

5. Input the Azure Subscription Id you wish to use. [Learn how to](https://docs.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest#az-account-list)
    ```powershell
    [string] $DepArgs.SubscriptionId = "12345678-1234-1234-1234-1234567890ab"
    ```
6. Input the Azure Tenant Id you wish to use. [Learn how to](https://microsoft.github.io/AzureTipsAndTricks/blog/tip153.html)
    ```powershell
    [string] $DepArgs.TenantId = "12345678-1234-1234-1234-1234567890ab"
    ```
7. To begin the deployment, open the latest version of Powershell, navigate to the `deployment` folder, and run: 
    ```powershell
    ./install.ps1 -VariableFile deployment.vars.commercial.ps1
    ```

### Azure US Government (Connected)

1. Open `./deployment/deployment.vars.usgovernment.ps1` in [your favorite editor](https://code.visualstudio.com/download). We're going to change a few variable values at the top before starting the deployment.
2. Update SshKey with the one you generated
    ```powershell
    [string] $DepArgs.SshKey = "your-ssh-key"
    ```
3. Update your RedHat Subscription manager information
    ```powershell
    [string] $DepArgs.RhsmUsernameOrOrgId = "email used to login"
    [string] $DepArgs.RhsmPoolId = "random string of 32 characters"
    [string] $DepArgs.RhsmBrokerPoolId = "can be the exact same as the pool id"
    [string] $DepArgs.RhsmPasswordOrActivationKey = "password used to login"
    ```
4. Input the Azure location you would like to use. [Learn how to](https://docs.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest#az-account-list-locations)
    ```powershell
    [string] $DepArgs.AzureLocation = "usgovvirginia"
    ```

    > [!TIP]
    > Examples include: usgovvirginia | usgoviowa | usgovtexas | usgovarizona

5. Input the Azure Subscription Id you wish to use. [Learn how to](https://docs.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest#az-account-list)
    ```powershell
    [string] $DepArgs.SubscriptionId = "12345678-1234-1234-1234-1234567890ab"
    ```
6. Input the Azure Tenant Id you wish to use. [Learn how to](https://microsoft.github.io/AzureTipsAndTricks/blog/tip153.html)
    ```powershell
    [string] $DepArgs.TenantId = "12345678-1234-1234-1234-1234567890ab"
    ```
7. To begin the deployment, open the latest version of Powershell, navigate to the `deployment` folder, and run: 
    ```powershell
    ./install.ps1 -VariableFile deployment.vars.usgovernment.ps1
    ```

### Azure Stack Hub (Connected)

1. Open `./deployment/deployment.vars.stack.ps1` in [your favorite editor](https://code.visualstudio.com/download). We're going to change a few variable values at the top before starting the deployment.
2. Update SshKey with the one you generated
    ```powershell
    [string] $DepArgs.SshKey = "your-ssh-key"
    ```
3. Update your RedHat Subscription manager information
    ```powershell
    [string] $DepArgs.RhsmUsernameOrOrgId = "email used to login"
    [string] $DepArgs.RhsmPoolId = "random string of 32 characters"
    [string] $DepArgs.RhsmBrokerPoolId = "can be the exact same as the pool id"
    [string] $DepArgs.RhsmPasswordOrActivationKey = "password used to login"
    ```
4. Input the Azure location you would like to use. This location will be based on your installation of Azure Stack Hub. [Learn how to](https://docs.microsoft.com/en-us/azure-stack/user/authenticate-azure-stack-hub?view=azs-2002)
    ```powershell
    [string] $DepArgs.AzureLocation = "my-stack"
    ```
5. Input the Azure Cloud you would like to use. This location will be based on your installation of Azure Stack Hub. [Learn how to](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-version-profiles-azurecli2?view=azs-2002#connect-to-azure-stack-hub)
    ```powershell
    [string] $DepArgs.AzureCloud = "my-stack-config"
    ```
6. Input the Azure Domain you would like to use. This domain will be based on your installation of Azure Stack Hub. [Learn how to](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-version-profiles-azurecli2?view=azs-2002#connect-to-azure-stack-hub)
    ```powershell
    [string] $DepArgs.AzureDomain = "my-stack.domain.com"
    ```
7. Input the Azure Profile you would like to use. This will be based on your installation of Azure Stack Hub. [Learn how to](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-version-profiles-azurecli2?view=azs-2002#connect-to-azure-stack-hub)
    ```powershell
    [string] $DepArgs.AzureProfile = "2018-03-01-hybrid"
    ```
8. Input the Azure Subscription Id you wish to use. [Learn how to](https://docs.microsoft.com/en-us/azure-stack/user/authenticate-azure-stack-hub?view=azs-2002#get-the-subscription-id)
    ```powershell
    [string] $DepArgs.SubscriptionId = "12345678-1234-1234-1234-1234567890ab"
    ```
9. Input the Azure Tenant Id you wish to use. [Learn how to](https://docs.microsoft.com/en-us/azure-stack/user/authenticate-azure-stack-hub?view=azs-2002#get-the-tenant-id)
    ```powershell
    [string] $DepArgs.TenantId = "12345678-1234-1234-1234-1234567890ab"
    ```
10. Depending on your Azure Stack installation, you may not have a RHEL v7 image to use for install. You will want to query the vm image list to determine if you have one by running `az vm image list --all --offer "RHEL" --output table`. If you do, then make sure the output values match the Marketplace values below. If you do not, you will need a RedHat image installed into your Azure Stack Marketplace to be used. [Learn how to](https://docs.microsoft.com/en-us/azure-stack/operator/azure-stack-add-vm-image?view=azs-2002)
    ```powershell
    [string] $DepArgs.MarketplacePublisher = "RedHat"
    [string] $DepArgs.MarketplaceOffer = "RHEL"
    [string] $DepArgs.MarketplaceSku = "7-RAW"
    [string] $DepArgs.MarketplaceVersion = "latest"
    ```
11. For Azure Stack Hub, there are other considerations to be made based on your installation. [Learn how to](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-version-profiles-azurecli2?view=azs-2002)
12. To begin the deployment, open the latest version of Powershell, navigate to the `deployment` folder, and run: 
    ```powershell
    ./install.ps1 -VariableFile deployment.vars.stack.ps1
    ```

### Azure Secret (Disconnected)

> coming

## Troubleshooting

All installation logs are output to the `./deployment/deployment-output/` folder. Look there first for any issues.

1. If you get a naming conflict error then you might have to adjust how resources get named in the `./deployment/deployment.vars.*.ps1` file. Look for the `Naming Conventions` section.
2. The install occasionally has trouble deploying the ansible playbooks. A typical installation during the `deploy openshift` step takes at least 40 minutes. If you see a deployment hang, then fail you can usually delete the deployment and start again. This is part of the ansible playbooks used to deploy OCP 3.11 and not something this tool is intended to correct.
3. The `deploy openshift` step can fail if you do not have the correct RedHat subscription. You should see an error similar to: `ERROR! the playbook: /usr/share/ansible/openshift-ansible/playbooks/openshift-node/network_manager.yml could not be found`. You should confirm your subscription supports an OpenShift deployment.
4. If you have any issues during the `deploy openshift` step you can ssh to the bastion virtual machine using the ssh key you generated. Then run the following command to see what ansible did: `sudo cat /var/lib/waagent/custom-script/download/0/stdout`
5. **Azure Stack Hub** - The VM sizes you use, number of VMs, and disk sizes are all dependant upon the resources your installation have available. If you have any resource issues during installation, they could be caused by this.

## Further Help

Contact [CloudFit](https://www.cloudfitsoftware.com/) @ getfit@cloudfitsoftware.com

> While this installation only covers OpenShift 3.11, Microsoft Azure and CloudFit are actively working on OpenShift 4.x support.
