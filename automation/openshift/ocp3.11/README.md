## OpenShift 3.11 automated install solution on Azure Government, Azure Stack, and Azure Secret clouds

This install is a secure deployment of RedHat OpenShift on Azure. The deployment is unique as its automated and has hardening baked-in.

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

## Deployment

Running the deployment will connect to Azure using the cli, deploy the needed resources, prepare the virtual machines for deployment, and deploy an OCP 3.11.

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

## Troubleshooting

All installation logs are output to the `./deployment/deployment-output/` folder. Look there first for any issues.

1. If you get a naming conflict error then you might have to adjust how resources get named in the `./deployment/deployment.vars.*.ps1` file. Look for the `Naming Conventions` section.
2. The install occasionally has trouble deploying the ansible playbooks. A typical installation during the `deploy openshift` step takes at least 40 minutes. If you see a deployment hang, then fail you can usually delete the deployment and start again. This is part of the ansible playbooks used to deploy OCP 3.11 and not something this tool is intended to correct.
3. The `deploy openshift` step can fail if you do not have the correct RedHat subscription. You should see an error similar to: `ERROR! the playbook: /usr/share/ansible/openshift-ansible/playbooks/openshift-node/network_manager.yml could not be found`. You should confirm your subscription supports an OpenShift deployment.
4. If you have any issues during the `deploy openshift` step you can ssh to the bastion virtual machine using the ssh key you generated. Then run the following command to see what ansible did: `sudo cat /var/lib/waagent/custom-script/download/0/stdout`

## Further Help

Contact [CloudFit](https://www.cloudfitsoftware.com/) @ getfit@cloudfitsoftware.com

> While this installation only covers OpenShift 3.11, Microsoft Azure and CloudFit are actively working on OpenShift 4.x support.
