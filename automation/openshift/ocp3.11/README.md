## OpenShift 3.11 automated install solution on Azure Government, Azure Stack, and Azure Secret clouds

This install is a secure deployment of RedHat OpenShift on Azure. The deployment is unique as its automated and has hardening baked-in.

## Prerequisites

* Download [az-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
* Download [Powershell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7)
* Download [openssh](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_overview) for using [ssh-keygen] to create a ssh key
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
* Red Hat Subscription information

## Steps

1. Change between lines 5-25 of parameters in deploy-vars.ps1
2. Run install.ps1
3. Wait for install to complete
