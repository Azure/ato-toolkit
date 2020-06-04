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
2. Generate an ssh key
3. Create a certs folder in the root of this directory
4. Put the ssh key in the `./certs/` folder
5. Gather Red Hat Subscription Manager info:
   1. Username or Organization Id (ex. your email you use to log into the portal)
   2. Pool Id (ex. a random string of 32 characters)
   3. Broker Pool Id (ex. can be the exact same as the pool id)
   4. Password or Activation Key (ex. the password you use to log into the portal)

## Azure US Government Deployment

1. Change `deployment.vars.usgovernment.ps1`
2. Open the latest version of Powershell and run `install.ps1 -VariableFile deployment.vars.usgovernment.ps1`


