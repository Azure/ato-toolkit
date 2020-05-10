# Instructions

Following are the instructions to deploy artifacts included in the package, they may include-

* Azure Policy and Policy-Set assignments. [More on Azure policies](https://docs.microsoft.com/en-us/azure/governance/policy/overview)

* Azure RBAC (Role Based Access Control) assignments. [More on Azure RBAC](https://docs.microsoft.com/en-us/azure/role-based-access-control/overview)

* Resource Groups and Resources. [Learn more](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/overview#terminology)

## Prerequisites

1. An Azure subscription (this is where audit policies and other resources will be created).
2. Owner level permissions on the management group and subscription. Keep ManagementGroupId or SubscriptionId handy.
3. All the files and sub directories in current directory.

## Azure Blueprint

More on Azure Blueprint can be found [here](https://docs.microsoft.com/en-us/azure/governance/blueprints/concepts/lifecycle). In order to customize and assign blueprint we first need to import it into Azure subscription, follow these steps to do so.

### Import via Azure CloudShell

    > [!TIP]
    > Alternatively you can execute same steps via PowerShell shell (min version 7.0.0) installed on local computer by connecting to target Azure Cloud environment and subscription context. [Learn how to](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-3.6.1)

1. Open CloudShell in Azure Portal. [Learn how to](https://docs.microsoft.com/en-us/azure/cloud-shell/overview)

2. Launch PowerShell in Azure CloudShell. [Learn how to](https://docs.microsoft.com/en-us/azure/cloud-shell/overview#choice-of-preferred-shell-experience)
    > [!NOTE]
    > If you don't have any storage mounted, Azure CloudShell requires an Azure file share to persist files. This will create a new storage account. Click "Create Storage".

3. Run following command to clone the Azure ato-toolkit repository to clouddrive.
    ```powershell
    git clone https://github.com/Azure/ato-toolkit.git $HOME/clouddrive/ato-toolkit

    ```

    > [!TIP]
    > Run `dir $HOME/clouddrive` to verify content of directory.

4. Run following command to import artifacts as blueprint and save it within the specified subscription or management group.
    ```powershell
    Import-AzBlueprintWithArtifact -Name "YourBlueprintName" -SubscriptionId "00000000-1111-0000-1111-000000000000" -InputPath "$HOME/clouddrive/ato-toolkit/automation/zero-trust-architecture/blueprint"

    ```

    > [!NOTE]
    > The input path must point to the folder where blueprint.json file is placed.

5. From Azure Portal, browse to Azure Blueprint service tab and select "Blueprint definitions". You can review newly imported blueprint in there and follow instructions to edit, publish and assign blueprint. [Learn how to](https://docs.microsoft.com/en-us/azure/governance/blueprints/create-blueprint-portal#edit-a-blueprint)

## Post blueprint assignment steps

Azure resources deployed by the Zero Trust blueprint are locked inside virtual network using [Virtual Network service endpoints](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview) and are not accessible from outside the virtual network. All the passwords and secrets for virtual machines are auto generated and stored securely in [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/).

Blueprint creates a JumpBox/Bastion host, (by default Windows, but can be changed to Linux operating systems during blueprint assignment) with pre-configured firewall rule to enable entry into the the secure Zero Trust environment created by the blueprint. Use following instructions or as applicable to connect to the environment.

### Connect from internet

1. From Azure portal, search for key vault with name "\*-sharedsvcs-kv" and configure it to allow access from specific network or from internet via firewall. [More info](https://docs.microsoft.com/en-us/azure/key-vault/general/network-security)
    * This is required to retrieve JumpBox VM password from the key vault secrets. [More info](https://docs.microsoft.com/en-us/azure/key-vault/secrets/about-secrets)

    > [!IMPORTANT]
    > Do not forget to revert the changes back after retrieving the password to lock down key vault to intended networks only.

2. From Azure portal, search for Azure Firewall name "\*-sharedsvcs-az-fw". Firewall is pre-configured with rule to allow access to JumpBox VM. Use firewall's public ip to connect to JumpBox VM to gain access to the environment. Default admin user name, unless changed during blueprint assignment, is 'jb-admin-user' and password retrieved in previous step.

## Feedback

For more information, questions, or feedback please [contact us](https://aka.ms/zerotrust-blueprint-feedback).
